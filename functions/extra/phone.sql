------------------------------------------------------------------------------------------------------------------------
drop table if exists phone_code;

create table phone_code (
    calling_code int primary key,
    main_region text not null check (main_region != '' and trim(main_region) = main_region),
    extra_regions text[] check (cardinality(extra_regions) = cardinality(array_unique(extra_regions))),
    national_prefix text check (national_prefix != '' and trim(national_prefix) = national_prefix),
    idd_prefix      text check (idd_prefix != '' and trim(idd_prefix) = idd_prefix),
    timezone        text check (timezone != '' and trim(timezone) = timezone)
);

------------------------------------------------------------------------------------------------------------------------
truncate phone_code restart identity;

insert into phone_code (calling_code, main_region, extra_regions, national_prefix, idd_prefix, timezone)
select
    p[1]::int as calling_code,
    p[2] as main_region,
    string_to_array(p[3], ',') as extra_regions,
    p[4] as national_prefix,
    p[5] as idd_prefix,
    p[6] as timezone
from csv_parse(
-- https://github.com/google/libphonenumber/tree/master/metadata/metadata.zip/metadata/metadata.csv
             $$
Calling Code ; Main Region ; Extra Regions                                                             ; National Prefix   ; IDD Prefix ; Timezone                                              ; Mobile Portable Regions                                          ; Extension Prefix
1            ; "U.S"       ; "AG,AI,AS,BB,BM,BS,CA,DM,DO,GD,GU,JM,KN,KY,LC,MP,MS,PR,SX,TC,TT,VC,VG,VI" ; "1"               ; "011"      ;                                                       ; "AG,AI,BB,BM,BS,CA,DM,DO,GD,JM,KN,KY,LC,MS,PR,SX,TC,TT,US,VC,VG"
20           ; "EG"        ;                                                                           ; "0"               ; "00"       ; "Africa/Cairo"                                        ; "EG"
211          ; "SS"        ;                                                                           ; "0"               ; "00"       ; "Africa/Nairobi"
212          ; "MA"        ; "EH"                                                                      ; "0"               ; "00"       ; "Atlantic/Canary"                                     ; "MA"
213          ; "DZ"        ;                                                                           ; "0"               ; "00"       ; "Europe/Paris"
216          ; "TN"        ;                                                                           ;                   ; "00"       ; "Africa/Tunis"
218          ; "LY"        ;                                                                           ; "0"               ; "00"       ; "Europe/Bucharest"
220          ; "GM"        ;                                                                           ;                   ; "00"       ; "Africa/Banjul"
221          ; "SN"        ;                                                                           ;                   ; "00"       ; "Africa/Dakar"
222          ; "MR"        ;                                                                           ;                   ; "00"       ; "Africa/Nouakchott"
223          ; "ML"        ;                                                                           ;                   ; "00"       ; "Africa/Bamako"
224          ; "GN"        ;                                                                           ;                   ; "00"       ; "Africa/Conakry"
225          ; "CI"        ;                                                                           ;                   ; "00"       ; "Africa/Abidjan"
226          ; "BF"        ;                                                                           ;                   ; "00"       ; "Africa/Ouagadougou"
227          ; "NE"        ;                                                                           ;                   ; "00"       ; "Africa/Niamey"
228          ; "TG"        ;                                                                           ;                   ; "00"       ; "Africa/Lome"
229          ; "BJ"        ;                                                                           ;                   ; "00"       ; "Africa/Porto-Novo"
230          ; "MU"        ;                                                                           ;                   ; "020"      ; "Indian/Mauritius"
231          ; "LR"        ;                                                                           ; "0"               ; "00"       ; "Atlantic/Reykjavik"
232          ; "SL"        ;                                                                           ; "0"               ; "00"       ; "Africa/Freetown"
233          ; "GH"        ;                                                                           ; "0"               ; "00"       ; "Africa/Accra"                                        ; "GH"
234          ; "NG"        ;                                                                           ; "0"               ; "009"      ; "Africa/Lagos"                                        ; "NG"
235          ; "TD"        ;                                                                           ;                   ; "00"       ; "Africa/Ndjamena"
236          ; "CF"        ;                                                                           ;                   ; "00"       ; "Africa/Bangui"
237          ; "CM"        ;                                                                           ;                   ; "00"       ; "Africa/Douala"                                       ; "CM"
238          ; "CV"        ;                                                                           ;                   ; "0"        ; "Atlantic/Cape_Verde"
239          ; "ST"        ;                                                                           ;                   ; "00"       ; "Africa/Sao_Tome"
240          ; "GQ"        ;                                                                           ;                   ; "00"       ; "Africa/Malabo"
241          ; "GA"        ;                                                                           ;                   ; "00"       ; "Africa/Libreville"
242          ; "CG"        ;                                                                           ;                   ; "00"       ; "Africa/Brazzaville"
243          ; "CD"        ;                                                                           ; "0"               ; "00"
244          ; "AO"        ;                                                                           ;                   ; "00"       ; "Africa/Luanda"
245          ; "GW"        ;                                                                           ;                   ; "00"       ; "Atlantic/Reykjavik"
246          ; "IO"        ;                                                                           ;                   ; "00"       ; "Indian/Chagos"
247          ; "AC"        ;                                                                           ;                   ; "00"       ; "Atlantic/St_Helena"
248          ; "SC"        ;                                                                           ;                   ; "00"       ; "Indian/Mahe"
249          ; "SD"        ;                                                                           ; "0"               ; "00"       ; "Africa/Khartoum"
250          ; "RW"        ;                                                                           ; "0"               ; "00"       ; "Africa/Kigali"
251          ; "ET"        ;                                                                           ; "0"               ; "00"       ; "Africa/Addis_Ababa"
252          ; "SO"        ;                                                                           ; "0"               ; "00"       ; "Africa/Mogadishu"
253          ; "DJ"        ;                                                                           ;                   ; "00"       ; "Africa/Djibouti"
254          ; "KE"        ;                                                                           ; "0"               ; "000"      ; "Africa/Nairobi"                                      ; "KE"
255          ; "TZ"        ;                                                                           ; "0"               ;            ; "Africa/Dar_es_Salaam"
256          ; "UG"        ;                                                                           ; "0"               ;            ; "Africa/Kampala"
257          ; "BI"        ;                                                                           ;                   ; "00"       ; "Africa/Bujumbura"
258          ; "MZ"        ;                                                                           ;                   ; "00"       ; "Africa/Maputo"
260          ; "ZM"        ;                                                                           ; "0"               ; "00"       ; "Africa/Lusaka"
261          ; "MG"        ;                                                                           ; "0"               ; "00"       ; "Indian/Antananarivo"
262          ; "RE"        ; "YT"                                                                      ; "0"               ; "00"
263          ; "ZW"        ;                                                                           ; "0"               ; "00"       ; "Africa/Harare"
264          ; "NA"        ;                                                                           ; "0"               ; "00"       ; "Africa/Windhoek"
265          ; "MW"        ;                                                                           ; "0"               ; "00"       ; "Africa/Blantyre"
266          ; "LS"        ;                                                                           ;                   ; "00"       ; "Africa/Maseru"
267          ; "BW"        ;                                                                           ;                   ; "00"       ; "Africa/Gaborone"
268          ; "SZ"        ;                                                                           ;                   ; "00"       ; "Africa/Mbabane"
269          ; "KM"        ;                                                                           ;                   ; "00"       ; "Indian/Comoro"
27           ; "ZA"        ;                                                                           ; "0"               ; "00"       ; "Africa/Johannesburg"                                 ; "ZA"
290          ; "SH"        ; "TA"                                                                      ;                   ; "00"       ; "Atlantic/St_Helena"
291          ; "ER"        ;                                                                           ; "0"               ; "00"       ; "Africa/Asmera"
297          ; "AW"        ;                                                                           ;                   ; "00"       ; "America/Aruba"
298          ; "FO"        ;                                                                           ;                   ; "00"       ; "Atlantic/Faeroe"
299          ; "GL"        ;                                                                           ;                   ; "00"
30           ; "GR"        ;                                                                           ;                   ; "00"       ; "Europe/Athens"                                       ; "GR"
31           ; "NL"        ;                                                                           ; "0"               ; "00"       ; "Europe/Amsterdam"                                    ; "NL"
32           ; "BE"        ;                                                                           ; "0"               ; "00"       ; "Europe/Brussels"                                     ; "BE"
33           ; "FR"        ;                                                                           ; "0"               ; "00"       ; "Europe/Paris"                                        ; "FR"
34           ; "ES"        ;                                                                           ;                   ; "00"       ;                                                       ; "ES"
350          ; "GI"        ;                                                                           ;                   ; "00"       ; "Europe/Gibraltar"                                    ; "GI"
351          ; "PT"        ;                                                                           ;                   ; "00"       ;                                                       ; "PT"
352          ; "LU"        ;                                                                           ;                   ; "00"       ; "Europe/Luxembourg"                                   ; "LU"
353          ; "IE"        ;                                                                           ; "0"               ; "00"       ; "Europe/Dublin"                                       ; "IE"
354          ; "IS"        ;                                                                           ;                   ; "00"       ; "Atlantic/Reykjavik"                                  ; "IS"
355          ; "AL"        ;                                                                           ; "0"               ; "00"       ; "Europe/Tirane"                                       ; "AL"
356          ; "MT"        ;                                                                           ;                   ; "00"       ; "Europe/Malta"                                        ; "MT"
357          ; "CY"        ;                                                                           ;                   ; "00"       ; "Asia/Nicosia"                                        ; "CY"
358          ; "FI"        ; "AX"                                                                      ; "0"               ; "00"       ;                                                       ; "FI"
359          ; "BG"        ;                                                                           ; "0"               ; "00"       ; "Europe/Sofia"                                        ; "BG"
36           ; "HU"        ;                                                                           ; "06"              ; "00"       ; "Europe/Budapest"                                     ; "HU"
370          ; "LT"        ;                                                                           ; "8,0"             ; "00"       ; "Europe/Bucharest"                                    ; "LT"
371          ; "LV"        ;                                                                           ;                   ; "00"       ; "Europe/Bucharest"                                    ; "LV"
372          ; "EE"        ;                                                                           ;                   ; "00"       ; "Europe/Bucharest"                                    ; "EE"
373          ; "MD"        ;                                                                           ; "0"               ; "00"       ; "Europe/Bucharest"                                    ; "MD"
374          ; "AM"        ;                                                                           ; "0"               ; "00"       ; "Asia/Yerevan"                                        ; "AM"
375          ; "BY"        ;                                                                           ; "8,0,80"          ; "8~10"     ; "Europe/Moscow"                                       ; "BY"
376          ; "AD"        ;                                                                           ;                   ; "00"       ; "Europe/Andorra"
377          ; "MC"        ;                                                                           ; "0"               ; "00"       ; "Europe/Monaco"
378          ; "SM"        ;                                                                           ;                   ; "00"       ; "Europe/San_Marino"
380          ; "UA"        ;                                                                           ; "0"               ; "0~0"      ; "Europe/Bucharest"
381          ; "RS"        ;                                                                           ; "0"               ; "00"       ; "Europe/Belgrade"                                     ; "RS"
382          ; "ME"        ;                                                                           ; "0"               ; "00"       ; "Europe/Podgorica"
383          ; "XK"        ;                                                                           ; "0"               ; "00"       ; "Europe/Belgrade"
385          ; "HR"        ;                                                                           ; "0"               ; "00"       ; "Europe/Zagreb"                                       ; "HR"
386          ; "SI"        ;                                                                           ; "0"               ; "00"       ; "Europe/Ljubljana"                                    ; "SI"
387          ; "BA"        ;                                                                           ; "0"               ; "00"       ; "Europe/Sarajevo"                                     ; "BA"
389          ; "MK"        ;                                                                           ; "0"               ; "00"       ; "Europe/Skopje"                                       ; "MK"
39           ; "IT"        ; "VA"                                                                      ;                   ; "00"       ;                                                       ; "IT,VA"
40           ; "RO"        ;                                                                           ; "0"               ; "00"       ; "Europe/Bucharest"                                    ; "RO"                                                             ; """ int """
41           ; "CH"        ;                                                                           ; "0"               ; "00"       ; "Europe/Zurich"                                       ; "CH"
420          ; "CZ"        ;                                                                           ;                   ; "00"       ; "Europe/Prague"                                       ; "CZ"
421          ; "SK"        ;                                                                           ; "0"               ; "00"       ; "Europe/Bratislava"                                   ; "SK"
423          ; "LI"        ;                                                                           ; "0"               ; "00"       ; "Europe/Vaduz"
43           ; "AT"        ;                                                                           ; "0"               ; "00"       ; "Europe/Vienna"                                       ; "AT"
44           ; "GB"        ; "GG,IM,JE"                                                                ; "0"               ; "00"       ;                                                       ; "GB"                                                             ; """ x"""
45           ; "DK"        ;                                                                           ;                   ; "00"       ; "Europe/Copenhagen"                                   ; "DK"
46           ; "SE"        ;                                                                           ; "0"               ; "00"       ; "Europe/Stockholm"                                    ; "SE"
47           ; "NO"        ; "SJ"                                                                      ;                   ; "00"       ;                                                       ; "NO"
48           ; "PL"        ;                                                                           ;                   ; "00"       ; "Europe/Warsaw"                                       ; "PL"
49           ; "DE"        ;                                                                           ; "0"               ; "00"       ; "Europe/Berlin"                                       ; "DE"
500          ; "FK"        ;                                                                           ;                   ; "00"       ; "Atlantic/Stanley"
501          ; "BZ"        ;                                                                           ;                   ; "00"       ; "America/Belize"
502          ; "GT"        ;                                                                           ;                   ; "00"       ; "America/Guatemala"
503          ; "SV"        ;                                                                           ;                   ; "00"       ; "America/El_Salvador"
504          ; "HN"        ;                                                                           ;                   ; "00"       ; "America/Tegucigalpa"
505          ; "NI"        ;                                                                           ;                   ; "00"       ; "America/Chicago"
506          ; "CR"        ;                                                                           ;                   ; "00"       ; "America/Costa_Rica"
507          ; "PA"        ;                                                                           ;                   ; "00"       ; "America/Panama"                                      ; "PA"
508          ; "PM"        ;                                                                           ; "0"               ; "00"       ; "America/Miquelon"
509          ; "HT"        ;                                                                           ;                   ; "00"       ; "America/Port-au-Prince"
51           ; "PE"        ;                                                                           ; "0"               ;            ; "America/Lima"                                        ; "PE"                                                             ; """ Anexo """
52           ; "MX"        ;                                                                           ; "01,02,044,045,1" ; "00"       ;                                                       ; "MX"
53           ; "CU"        ;                                                                           ; "0"               ; "119"      ; "America/Havana"
54           ; "AR"        ;                                                                           ; "0"               ; "00"       ; "America/Buenos_Aires"                                ; "AR"
55           ; "BR"        ;                                                                           ; "0"               ;            ;                                                       ; "BR"
56           ; "CL"        ;                                                                           ;                   ;            ;                                                       ; "CL"
57           ; "CO"        ;                                                                           ; "0"               ;            ; "America/Bogota"                                      ; "CO"
58           ; "VE"        ;                                                                           ; "0"               ; "00"       ; "America/Caracas"
590          ; "GP"        ; "BL,MF"                                                                   ; "0"               ; "00"       ; "America/Guadeloupe"                                  ; "BL,GP,MF"
591          ; "BO"        ;                                                                           ; "0"               ;            ; "America/La_Paz"
592          ; "GY"        ;                                                                           ;                   ; "001"      ; "America/Guyana"
593          ; "EC"        ;                                                                           ; "0"               ; "00"       ;                                                       ; "EC"
594          ; "GF"        ;                                                                           ; "0"               ; "00"       ; "America/Cayenne"                                     ; "GF"
595          ; "PY"        ;                                                                           ; "0"               ; "00"       ; "America/Asuncion"                                    ; "PY"
596          ; "MQ"        ;                                                                           ; "0"               ; "00"       ; "America/Martinique"                                  ; "MQ"
597          ; "SR"        ;                                                                           ;                   ; "00"       ; "America/Paramaribo"
598          ; "UY"        ;                                                                           ; "0"               ; "00"       ; "America/Montevideo"                                  ;                                                                  ; """ int. """
599          ; "CW"        ; "BQ"                                                                      ;                   ; "00"
60           ; "MY"        ;                                                                           ; "0"               ; "00"       ; "Asia/Kuching"                                        ; "MY"
61           ; "AU"        ; "CC,CX"                                                                   ; "0"               ; "0011"     ;                                                       ; "AU"
62           ; "ID"        ;                                                                           ; "0"
63           ; "PH"        ;                                                                           ; "0"               ; "00"       ; "Asia/Manila"
64           ; "NZ"        ;                                                                           ; "0"               ; "00"       ;                                                       ; "NZ"
65           ; "SG"        ;                                                                           ;                   ;            ; "Asia/Singapore"                                      ; "SG"
66           ; "TH"        ;                                                                           ; "0"               ;            ; "Asia/Bangkok"                                        ; "TH"
670          ; "TL"        ;                                                                           ;                   ; "00"       ; "Asia/Dili"
672          ; "NF"        ;                                                                           ;                   ; "00"       ; "Pacific/Norfolk"
673          ; "BN"        ;                                                                           ;                   ; "00"       ; "Asia/Brunei"
674          ; "NR"        ;                                                                           ;                   ; "00"       ; "Pacific/Nauru"
675          ; "PG"        ;                                                                           ;                   ; "00"       ; "Pacific/Port_Moresby"
676          ; "TO"        ;                                                                           ;                   ; "00"       ; "Pacific/Tongatapu"
677          ; "SB"        ;                                                                           ;                   ;            ; "Pacific/Guadalcanal"
678          ; "VU"        ;                                                                           ;                   ; "00"       ; "Pacific/Efate"
679          ; "FJ"        ;                                                                           ;                   ; "00"       ; "Pacific/Fiji"
680          ; "PW"        ;                                                                           ;                   ;            ; "Pacific/Palau"
681          ; "WF"        ;                                                                           ;                   ; "00"       ; "Pacific/Wallis"
682          ; "CK"        ;                                                                           ;                   ; "00"       ; "Pacific/Rarotonga"
683          ; "NU"        ;                                                                           ;                   ; "00"       ; "Pacific/Niue"
685          ; "WS"        ;                                                                           ;                   ; "0"        ; "Pacific/Apia"
686          ; "KI"        ;                                                                           ; "0"               ; "00"       ; "Pacific/Enderbury&Pacific/Kiritimati&Pacific/Tarawa"
687          ; "NC"        ;                                                                           ;                   ; "00"       ; "Pacific/Noumea"
688          ; "TV"        ;                                                                           ;                   ; "00"       ; "Pacific/Funafuti"
689          ; "PF"        ;                                                                           ;                   ; "00"
690          ; "TK"        ;                                                                           ;                   ; "00"       ; "Pacific/Fakaofo"
691          ; "FM"        ;                                                                           ;                   ; "00"
692          ; "MH"        ;                                                                           ; "1"               ; "011"      ; "Pacific/Majuro"
7            ; "RU"        ; "KZ"                                                                      ; "8"               ; "8~10"
800          ; "001"
808          ; "001"
81           ; "JP"        ;                                                                           ; "0"               ; "010"      ; "Asia/Tokyo"                                          ; "JP"
82           ; "KR"        ;                                                                           ; "0"               ;            ; "Asia/Seoul"                                          ; "KR"
84           ; "VN"        ;                                                                           ; "0"               ; "00"       ; "Asia/Bangkok"
850          ; "KP"        ;                                                                           ; "0"               ;            ; "Asia/Seoul"
852          ; "HK"        ;                                                                           ;                   ; "00"       ; "Asia/Hong_Kong"                                      ; "HK"
853          ; "MO"        ;                                                                           ;                   ; "00"       ; "Asia/Shanghai"
855          ; "KH"        ;                                                                           ; "0"               ;            ; "Asia/Phnom_Penh"
856          ; "LA"        ;                                                                           ; "0"               ; "00"       ; "Asia/Vientiane"
86           ; "CN"        ;                                                                           ; "0"               ; "00"
870          ; "001"
878          ; "001"
880          ; "BD"        ;                                                                           ; "0"               ; "00"       ; "Asia/Dhaka"
881          ; "001"
882          ; "001"
883          ; "001"
886          ; "TW"        ;                                                                           ; "0"               ;            ; "Asia/Taipei"                                         ; "TW"                                                             ; "#"
888          ; "001"
90           ; "TR"        ;                                                                           ; "0"               ; "00"       ; "Europe/Istanbul"                                     ; "TR"
91           ; "IN"        ;                                                                           ; "0"               ; "00"       ; "Asia/Calcutta"                                       ; "IN"
92           ; "PK"        ;                                                                           ; "0"               ; "00"       ; "Asia/Karachi"                                        ; "PK"
93           ; "AF"        ;                                                                           ; "0"               ; "00"       ; "Asia/Kabul"
94           ; "LK"        ;                                                                           ; "0"               ; "00"       ; "Asia/Colombo"
95           ; "MM"        ;                                                                           ; "0"               ; "00"       ; "Asia/Rangoon"
960          ; "MV"        ;                                                                           ;                   ; "00"       ; "Indian/Maldives"
961          ; "LB"        ;                                                                           ; "0"               ; "00"       ; "Asia/Beirut"
962          ; "JO"        ;                                                                           ; "0"               ; "00"       ; "Asia/Amman"                                          ; "JO"
963          ; "SY"        ;                                                                           ; "0"               ; "00"       ; "Asia/Damascus"
964          ; "IQ"        ;                                                                           ; "0"               ; "00"       ; "Asia/Baghdad"
965          ; "KW"        ;                                                                           ;                   ; "00"       ; "Asia/Kuwait"                                         ; "KW"
966          ; "SA"        ;                                                                           ; "0"               ; "00"       ; "Asia/Riyadh"                                         ; "SA"
967          ; "YE"        ;                                                                           ; "0"               ; "00"       ; "Asia/Aden"
968          ; "OM"        ;                                                                           ;                   ; "00"       ; "Asia/Muscat"                                         ; "OM"
970          ; "PS"        ;                                                                           ; "0"               ; "00"       ; "Europe/Bucharest"
971          ; "AE"        ;                                                                           ; "0"               ; "00"       ; "Asia/Dubai"
972          ; "IL"        ;                                                                           ; "0"               ;            ; "Asia/Jerusalem"                                      ; "IL"
973          ; "BH"        ;                                                                           ;                   ; "00"       ; "Asia/Bahrain"                                        ; "BH"
974          ; "QA"        ;                                                                           ;                   ; "00"       ; "Asia/Qatar"                                          ; "QA"
975          ; "BT"        ;                                                                           ;                   ; "00"       ; "Asia/Thimphu"
976          ; "MN"        ;                                                                           ; "0"               ; "001"
977          ; "NP"        ;                                                                           ; "0"               ; "00"       ; "Asia/Katmandu"
979          ; "001"
98           ; "IR"        ;                                                                           ; "0"               ; "00"       ; "Asia/Tehran"                                         ; "IR"
992          ; "TJ"        ;                                                                           ; "8"               ; "8~10"     ; "Asia/Dushanbe"
993          ; "TM"        ;                                                                           ; "8"               ; "8~10"     ; "Asia/Ashgabat"
994          ; "AZ"        ;                                                                           ; "0"               ; "00"       ; "Asia/Baku"                                           ; "AZ"
995          ; "GE"        ;                                                                           ; "0"               ; "00"       ; "Asia/Tbilisi"                                        ; "GE"
996          ; "KG"        ;                                                                           ; "0"               ; "00"       ; "Asia/Bishkek"
998          ; "UZ"        ;                                                                           ; "8"               ; "8~10"     ; "Asia/Tashkent"
$$, ';', true) as p;

------------------------------------------------------------------------------------------------------------------------
create or replace function regexp_class_digits_optimize(s text)
    returns text
    stable
    returns null on null input
    parallel safe
    language plpgsql
as
$$
declare
    i smallint;
begin
    for i in 0..7
        loop
            s := regexp_replace(s, format('(?<=[\-%s])%s(?=[\-%s])', i, i+1, i+2), '-', 'g');
        end loop;
    s := regexp_replace(s, '-+', '-', 'g');
    s := regexp_replace(s, '\[(\d)\]', '\1', 'g');
    s := replace(s, '[0-9]', '\d');
    return s;
end;
$$;

--TEST
do $$
    begin
        assert regexp_class_digits_optimize('[0123456789]') = '\d';
        assert regexp_class_digits_optimize('[123456789]') = '[1-9]';
        assert regexp_class_digits_optimize('[0135679]') = '[0135-79]';
    end;
$$;

------------------------------------------------------------------------------------------------------------------------
-- для функции phone_parse() генерирует регулярное выражение для захвата телефонного кода страны

with t3 as (
    select calling_code::text as n
    from phone_code as d
    order by n
)
--select * from t3;
   , t2 as (
    select left(n, 2) as n,
           '[' || string_agg(nullif(substr(n, 3, 1), ''), '') || ']' as r
    from t3
    group by 1
    order by 1
)
--select * from t2;
   , t1 as (
    select left(n, 1) as d1,
           '[' || string_agg(nullif(substr(n, 2, 1), ''), '') || ']' as r1,
           r as r2
    from t2
    group by 1, 3
    order by 1, 2
)
   , t as (
    select d1, '(?:' || nullif(string_agg(concat_ws('', r1, r2), '|'), '') || ')' as r
    from t1
    group by d1
    order by 2 desc, d1
)
--select * from t order by d1, r;
   , s as (
    select concat_ws('', '[' || string_agg(d1, '') || ']', r) as r
    from t
    group by r
    order by r
)
select regexp_class_digits_optimize(
           --r
               string_agg(r, e'\n|')
           )
from s;
