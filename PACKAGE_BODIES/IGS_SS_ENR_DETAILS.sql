--------------------------------------------------------
--  DDL for Package Body IGS_SS_ENR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_ENR_DETAILS" AS
/* $Header: IGSSS05B.pls 120.21 2006/04/12 23:02:49 snambaka ship $ */

g_tba_desc CONSTANT igs_lookup_values.meaning%TYPE  := get_meaning('SCHEDULE_TYPE', 'TBA');
g_nsd_desc CONSTANT igs_lookup_values.meaning%TYPE := get_meaning('LEGACY_TOKENS','NO_SET_DAY');

FUNCTION get_location_bldg_room ( p_uoo_id IN NUMBER ) RETURN VARCHAR2
 ------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  -- Purpose:
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- kkillams    15-04-2003      Modified c_igs_ps_usec_occurs cursor as part of performance bug 2749732
  ------------------------------------------------------------------------------
IS
lv_location VARCHAR2(2000) ;
CURSOR c_igs_ps_usec_occurs(p_uoo_id IN NUMBER) IS
SELECT
 uoo_id,
 NVL(d.description,'-')||'<BR>'||NVL(b.description,'-')||'<BR>'||NVL(c.description,'-') location_description,
 NVL(b.location_cd,'-')||'<BR>'||NVL(b.building_cd,'-')||'<BR>'||NVL(c.room_cd,'-') location_cd
 FROM igs_ps_usec_occurs a,
     igs_ad_building b,
     igs_ad_room c,
     igs_ad_location d
 WHERE
     a.building_code = b.building_id(+) AND
     a.room_code = c.room_id(+) AND
     b.location_cd = d.location_cd(+) AND
     a.uoo_id = p_uoo_id
ORDER BY
    b.location_cd,b.building_id,c.room_id;
BEGIN
        FOR c_occurs_data IN c_igs_ps_usec_occurs(p_uoo_id)
            LOOP
                 IF lv_location IS NOT NULL
                 THEN
                       lv_location := lv_location||'<BR><BR>'||c_occurs_data.location_description ;
                 ELSE
                         lv_location := c_occurs_data.location_description ;
                 END IF ;
            END LOOP ;
            RETURN lv_location ;
END get_location_bldg_room;


FUNCTION get_instructor_day_time(p_uoo_id IN NUMBER ) RETURN VARCHAR2 IS
 ------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  -- Purpose:
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- kkillams    15-04-2003      Modified c_igs_ps_usec_occurs cursor as part of performance bug 2749732
  ------------------------------------------------------------------------------
lv_instructor varchar2(2000);
CURSOR c_igs_ps_usec_occurs(p_uoo_id IN NUMBER)
IS
SELECT
 uoo_id,
 NVL(DECODE(a.monday,  'Y',  'Mon',  NULL)||
 DECODE(a.tuesday,  'Y',  'Tue',  NULL)||
 DECODE(a.wednesday,  'Y',  'Wed',  NULL)||
 DECODE(a.thursday,  'Y',  'Thu',  NULL)||
 DECODE(a.friday,  'Y',  'Fri',  NULL)||
 DECODE(a.saturday,  'Y',  'Sat',  NULL)||
 DECODE(a.sunday,  'Y',  'Sun',  NULL),'-')||'<BR>'||
 TO_CHAR(a.start_time,  'hh:miam')||'-'|| TO_CHAR(a.end_time,  'hh:miam')||'<BR>'||
 LTRIM(f.person_last_name||', '||f.person_first_name||' '||f.person_middle_name) instructor_name
 FROM igs_ps_usec_occurs a,
      igs_ad_building b,
      hz_parties f
 WHERE
     a.building_code = b.building_id(+) AND
     a.instructor_id = f.party_id(+) AND
     a.uoo_id = p_uoo_id ORDER BY
     location_cd,building_id ,room_code;
BEGIN
        FOR c_occurs_data IN c_igs_ps_usec_occurs(p_uoo_id)
            LOOP
                 IF lv_instructor IS NOT NULL
                 THEN
                       lv_instructor := lv_instructor||'<BR><BR>'||c_occurs_data.instructor_name ;
                 ELSE
                   lv_instructor := c_occurs_data.instructor_name ;
                 END IF ;
            END LOOP ;
            RETURN lv_instructor ;
END get_instructor_day_time;

FUNCTION get_programs
(
p_person_id in number
) return varchar2
is
cursor c_igs_ps_course(p_person_id in number)
is
select
a.course_attempt_status,
a.course_cd,
b.title,
a.course_cd||'-'||b.title program,
a.person_id
from igs_en_stdnt_ps_att a,igs_ps_ver b
where a.course_cd = b.course_cd
and a.version_number = b.version_number
and a.person_id = p_person_id
and nvl(a.course_attempt_status,' ') not in ('INACTIVE');
lv_program varchar2(2000) ;
begin
        for c_igs_ps_course_data in c_igs_ps_course(p_person_id)
            loop
                 if lv_program is not null
                 then
                       lv_program := lv_program ||','||c_igs_ps_course_data.program ;
                 else
                   lv_program := c_igs_ps_course_data.program ;
                 end if ;
            end loop ;
            return lv_program ;
end get_programs;
FUNCTION get_occur_desc_details
(p_uoo_id IN NUMBER) RETURN VARCHAR2
 ------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  -- Purpose:
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- kkillams    15-04-2003      Modified c_igs_ps_usec_occurs cursor as part of performance bug 2749732
  ------------------------------------------------------------------------------
is
lv_occurence_details varchar2(32000) ;
lv_location_details varchar2(32000) ;
CURSOR c_igs_ps_usec_occurs(p_uoo_id in number)
IS
SELECT
 uoo_id,
 DECODE(a.monday,  'Y',  'Mon',  NULL)||
 DECODE(a.tuesday,  'Y',  'Tue',  NULL)||
 DECODE(a.wednesday,  'Y',  'Wed',  NULL)||
 DECODE(a.thursday,  'Y',  'Thu',  NULL)||
 DECODE(a.friday,  'Y',  'Fri',  NULL)||
 DECODE(a.saturday,  'Y',  'Sat',  NULL)||
 DECODE(a.sunday,  'Y',  'Sun',  NULL) CLASS_DAY,
 TO_CHAR(a.start_time,  'hh:miam')||'-'||TO_CHAR(a.end_time,  'hh:miam') CLASS_TIME,
 DECODE(a.monday,  'Y',  'Mon',  NULL)||
 DECODE(a.tuesday,  'Y',  'Tue',  NULL)||
 DECODE(a.wednesday,  'Y',  'Wed',  NULL)||
 DECODE(a.thursday,  'Y',  'Thu',  NULL)||
 DECODE(a.friday,  'Y',  'Fri',  NULL)||
 DECODE(a.saturday,  'Y',  'Sat',  NULL)||
 DECODE(a.sunday,  'Y',  'Sun',  NULL)||' '||
 TO_CHAR(a.start_time,  'hh:miam')||'-'|| TO_CHAR(a.end_time,  'hh:miam')||'<BR>'||
 NVL(d.description,'-')||'<BR>'||
 NVL(b.description,'-')||'  '||
 NVL(c.description,'')||'<BR>'||
 LTRIM(f.person_last_name||', '||f.person_first_name||' '||f.person_middle_name) location
 FROM igs_ps_usec_occurs a,
     igs_ad_building b,
     igs_ad_room c,
     igs_ad_location d,
     hz_parties f
 WHERE
     a.building_code = b.building_id(+) AND
     a.room_code = c.room_id(+) AND
     a.instructor_id = f.party_id(+) AND
     b.location_cd = d.location_cd(+) AND
     a.uoo_id = p_uoo_id
 ORDER BY
     class_day,class_time;
BEGIN
        FOR c_occurs_data in c_igs_ps_usec_occurs(p_uoo_id)
        LOOP
            IF lv_location_details IS NOT NULL THEN
                       lv_location_details := lv_location_details ||'<BR><BR>'||c_occurs_data.location ;
            ELSE
                         lv_location_details := c_occurs_data.location ;
            END IF ;
        END LOOP ;
                lv_occurence_details := lv_location_details ;
        RETURN lv_occurence_details ;
END get_occur_desc_details;
FUNCTION get_occur_cd_details(p_uoo_id IN NUMBER) RETURN VARCHAR2
  ------------------------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  -- Purpose: To return the meeting pattern details,
  -- for a unit section
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- prgoyal     14-Oct-2001     Modifed the function to fetch the instructors from
  --                             table igs_ps_uso_instrctrs
  -- kamohan    1/15/02          Modified for ENCR014
  --                             Added Start_date, End_date and TBA
  -- kkillams    15-04-2003      Modified c_igs_ps_usec_occurs cursor as part of performance bug 2749732
  ------------------------------------------------------------------------------
IS
        lv_occurence_details VARCHAR2(32000) ;
        lv_location_details VARCHAR2(32000) ;
        CURSOR c_igs_ps_usec_occurs(p_uoo_id IN NUMBER)
        IS SELECT
                 uoo_id,
                 unit_section_occurrence_id usec_id,
                 start_date,
                 end_date,
                 DECODE(a.monday,  'Y',  'Mon',  NULL)
                 || DECODE(a.tuesday,  'Y',  'Tue',  NULL)
                 || DECODE(a.wednesday,  'Y',  'Wed',  NULL)
                 || DECODE(a.thursday,  'Y',  'Thu',  NULL)
                 || DECODE(a.friday,  'Y',  'Fri',  NULL)
                 || DECODE(a.saturday,  'Y',  'Sat',  NULL)
                 || DECODE(a.sunday,  'Y',  'Sun',  NULL) class_day,
                 TO_CHAR(a.start_time,  'hh:miam')||'-'||TO_CHAR(a.end_time, 'hh:miam') class_time,
                 DECODE(a.monday,  'Y',  'Mon',  NULL)
                 || DECODE(a.tuesday,  'Y',  'Tue',  NULL)
                 || DECODE(a.wednesday,  'Y',  'Wed',  NULL)
                 || DECODE(a.thursday,  'Y',  'Thu',  NULL)
                 || DECODE(a.friday,  'Y',  'Fri',  NULL)
                 || DECODE(a.saturday,  'Y',  'Sat',  NULL)
                 || DECODE(a.sunday,  'Y',  'Sun',  NULL) ||' '
                 || TO_CHAR(a.start_time,'hh:miam')||'-'||TO_CHAR(a.end_time, 'hh:miam')
                 ||'<BR>'||NVL(b.location_cd,' ')||'<BR>'||NVL(b.building_cd,' ') ||' '||NVL(c.room_cd,' ') location
                 FROM igs_ps_usec_occurs a,
                      igs_ad_building b,
                      igs_ad_room c
                 WHERE
                     a.building_code = b.building_id(+) AND
                     a.room_code = c.room_id(+) AND
                     a.uoo_id = p_uoo_id
                 ORDER BY class_day,class_time;

                cursor c_get_uso_instructor ( p_unit_section_occurence_id  igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE)
                IS
                SELECT
                        person_Last_name ||', '||Person_first_name||' '|| person_middle_name  instructor_name
                FROM
                        hz_parties hz,
                        igs_ps_uso_instrctrs usoi
                WHERE
                        hz.party_id = usoi.instructor_id AND
                        usoi.unit_section_occurrence_id = p_unit_section_occurence_id;

                lv_instructor   VARCHAR2(4000);
                cstMeetingTimes VARCHAR2(20);
                l_announce      BOOLEAN := FALSE;
                l_display       BOOLEAN := TRUE;
BEGIN

        FOR c_occurs_data in c_igs_ps_usec_occurs(p_uoo_id) LOOP
                IF c_occurs_data.start_date IS NULL AND c_occurs_data.end_date IS NULL THEN
                        l_announce := TRUE;
                        l_display := FALSE;
                END IF;

                IF l_display THEN

                    IF lv_location_details IS NOT NULL THEN
                            lv_location_details := lv_location_details ||'<BR>'||c_occurs_data.location ;
                    ELSE
                            lv_location_details := c_occurs_data.location ;
                    END IF ;

                    lv_instructor := NULL;
                    FOR r_get_uso_instructor IN c_get_uso_instructor(c_occurs_data.usec_id)
                    LOOP
                            IF r_get_uso_instructor.instructor_name IS NOT NULL
                            THEN
                              IF lv_instructor IS NOT NULL THEN
                                lv_instructor := lv_instructor || '<BR>' || r_get_uso_instructor.instructor_name || '<BR>';
                              ELSE
                                lv_instructor := r_get_uso_instructor.instructor_name || '<BR>';
                              END IF;
                            END IF;
                    END LOOP;
                    lv_location_details := lv_location_details || lv_instructor || '<BR>';
                END IF;
                l_display := TRUE;
        END LOOP;
        lv_occurence_details := lv_location_details;


        IF lv_occurence_details IS NOT NULL THEN
          IF l_announce THEN
            fnd_message.set_name('IGS','IGS_EN_TO_BE_ANNOUNCED');
            cstMeetingTimes := fnd_message.get;
            lv_occurence_details := lv_occurence_details || '<BR>' || cstMeetingTimes;
          END IF;
          RETURN lv_occurence_details;
        ELSE
            IF l_announce THEN
                fnd_message.set_name('IGS','IGS_EN_TO_BE_ANNOUNCED');
                cstMeetingTimes := fnd_message.get;
                RETURN cstMeetingTimes;
            END IF;
        END IF;

        RETURN NULL;

END get_occur_cd_details;

FUNCTION get_occur_details_no_location(p_uoo_id IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------------------
--Created by  :
--Date created:
--
-- Purpose:
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-- Who         When            What
-- kkillams    15-04-2003      Modified c_igs_ps_usec_occurs cursor as part of performance bug 2749732
------------------------------------------------------------------------------
lv_occurence_details varchar2(2000) ;
CURSOR c_igs_ps_usec_occurs(p_uoo_id IN NUMBER)
IS
SELECT
 uoo_id,
 DECODE(a.monday,  'Y',  'Mon',  NULL)||
 DECODE(a.tuesday,  'Y',  'Tue',  NULL)||
 DECODE(a.wednesday,  'Y',  'Wed',  NULL)||
 DECODE(a.thursday,  'Y',  'Thu',  NULL)||
 DECODE(a.friday,  'Y',  'Fri',  NULL)||
 DECODE(a.saturday,  'Y',  'Sat',  NULL)||
 DECODE(a.sunday,  'Y',  'Sun',  NULL)||' '||
 TO_CHAR(a.start_time,  'hh:miam')||'-'||
 TO_CHAR(a.end_time,  'hh:miam')||'<BR>'||
 LTRIM(f.person_last_name||', '||f.person_first_name||' '||f.person_middle_name) occurence
 FROM igs_ps_usec_occurs a,
     igs_ad_building b,
     hz_parties f
 WHERE
     a.building_code = b.building_id(+) AND
     a.instructor_id = f.party_id(+) AND
     a.uoo_id = p_uoo_id ORDER BY
     location_cd,building_id ,room_code;
BEGIN
        FOR c_occurs_data in c_igs_ps_usec_occurs(p_uoo_id)
            LOOP
                 IF lv_occurence_details IS NOT NULL
                 THEN
                       lv_occurence_details := lv_occurence_details ||'<BR><BR>'||c_occurs_data.occurence ;
                 ELSE
                   lv_occurence_details := c_occurs_data.occurence ;
                 END IF ;
            END LOOP ;
            RETURN lv_occurence_details ;
end get_occur_details_no_location;

 FUNCTION get_usec_ref_cd (
   p_uoo_id IN NUMBER
 ) RETURN VARCHAR2 IS

    lv_ref_cd VARCHAR2(32000) ;

    CURSOR c_usec_ref_cd (cp_uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
      SELECT a.reference_code||' - '||a.reference_code_desc ref_cd
      FROM igs_ps_us_req_ref_cd a, igs_ps_usec_ref b
      WHERE b.uoo_id = cp_uoo_id
      AND a.unit_section_reference_id = b.unit_section_reference_id
      ORDER BY 1 ;

    CURSOR c_unit_ref_cd (cp_uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
      SELECT unitref.REFERENCE_CODE || ' - ' || unitref.REFERENCE_CODE_DESC  ref_cd
      FROM igs_ps_unitreqref_cd unitref,
          igs_ps_unit_ofr_opt uoo
      WHERE uoo.uoo_id = cp_uoo_id
      AND   uoo.unit_cd = unitref.unit_cd
      AND   uoo.version_number = unitref.version_number
      ORDER BY 1;

    v_usec_record_exists BOOLEAN;

  BEGIN

    v_usec_record_exists := FALSE;

    FOR c_usec_ref_cd_data IN c_usec_ref_cd(p_uoo_id)
    LOOP

      v_usec_record_exists :=TRUE;

      IF lv_ref_cd IS NOT NULL THEN
        lv_ref_cd := lv_ref_cd ||' , '||c_usec_ref_cd_data.ref_cd ;
      ELSE
        lv_ref_cd := c_usec_ref_cd_data.ref_cd;
      END IF;

    END LOOP ;

    IF NOT v_usec_record_exists THEN
      FOR c_unit_ref_cd_data IN c_unit_ref_cd(p_uoo_id)
      LOOP

        v_usec_record_exists :=TRUE;

        IF lv_ref_cd IS NOT NULL THEN
          lv_ref_cd := lv_ref_cd ||' , '||c_unit_ref_cd_data.ref_cd ;
        ELSE
          lv_ref_cd := c_unit_ref_cd_data.ref_cd;
        END IF;

      END LOOP ;
    END IF;

    RETURN lv_ref_cd ;

  END get_usec_ref_cd;


  FUNCTION get_usec_occurs_ref_cd (p_uoo_id IN NUMBER)
  RETURN VARCHAR2 IS

    lv_ref_cd   VARCHAR2(32000) := NULL;

    -- The parameter value passed into the function
    -- and to the cursor will be the unit_section_occurrence_id
    -- and not uoo_id
    CURSOR c_usec_occurs_ref_cd IS
      SELECT reference_code ||' - '|| reference_code_description ref_cd
      FROM  igs_ps_usec_ocur_ref_v
      WHERE unit_section_occurrence_id = p_uoo_id
      ORDER BY 1 ;

    BEGIN

      FOR c_usec_occurs_ref_cd_data in c_usec_occurs_ref_cd
      LOOP
        IF lv_ref_cd IS NOT NULL THEN
          lv_ref_cd := lv_ref_cd ||'<BR>'||c_usec_occurs_ref_cd_data.ref_cd ;
        ELSE
          lv_ref_cd := c_usec_occurs_ref_cd_data.ref_cd;
        END IF ;
      END LOOP ;

     RETURN lv_ref_cd ;

  END get_usec_occurs_ref_cd;


function get_unit_note
(
p_unit_cd in varchar2,
p_version_number in number
) return varchar2
is
lv_unit_note varchar2(32000) ;
cursor c_unit_note is
select
a.note_text,
b.crs_note_type
from igs_ge_note a, igs_ps_unit_ver_note b
where a.reference_number = b.reference_number
and b.unit_cd = p_unit_cd
and b.version_number = p_version_number
order by crs_note_type ;
begin
        for c_unit_note_data in c_unit_note
            loop
                 if lv_unit_note is not null
                 then
                       lv_unit_note := lv_unit_note||' , '||c_unit_note_data.note_text ;
                 else
                             lv_unit_note := c_unit_note_data.note_text ;
                 end if ;
            end loop ;

            return lv_unit_note;
end get_unit_note;

function get_usec_note
(
p_uoo_id in number
) return varchar2
is
lv_usec_note varchar2(32000) ;
cursor c_usec_note is
select
a.note_text,
b.crs_note_type
from igs_ge_note a,igs_ps_unt_ofr_opt_n b
where a.reference_number = b.reference_number
and b.uoo_id = p_uoo_id
order by crs_note_type ;
begin
        for c_usec_note_data in c_usec_note
            loop
                 if lv_usec_note is not null
                 then
                       lv_usec_note := lv_usec_note||' , '||c_usec_note_data.note_text ;
                 else
                             lv_usec_note := c_usec_note_data.note_text ;
                 end if ;
            end loop ;

            return lv_usec_note;
end get_usec_note;
/*
| Added for November 2001 |
*/

 ------------------------------------------------------------------------------------
  --Created by  :  ( Oracle IDC)
  --Date created:
  --
  --Purpose: To get the title and subtitle from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
  -- level
  -- To be used only in self service as then fields are seperated by <BR> tag
  -- and this is to be used only in SS.
  --Change History:
  --Who           When            What
  -- prgoyal      8-NOV-2001      Added description, comments for procedure,
  --                              modifed procedure for input parameters and where clause
  --                              of cursor for student level
     ------------------------------------------------------------------------------

FUNCTION get_title_section
(
        p_person_id       IN NUMBER,
        p_uoo_id          IN NUMBER,
        p_unit_cd         IN VARCHAR2,
        p_version_number  IN NUMBER,
        p_course_cd       IN VARCHAR2
)RETURN VARCHAR2 AS
        -- To fetch the deatils from student level
        CURSOR stdnt_subtitle_dtls IS
        SELECT
                alternative_title title,
                subtitle
        FROM
                igs_en_su_attempt
        WHERE
                person_id = p_person_id AND
                course_cd = p_course_cd AND
                uoo_id = p_uoo_id;

        -- To fetch the deatils from section level
        CURSOR usec_subtitle_dtls IS
        SELECT
                uref.title,
                usub.subtitle
        FROM
                igs_ps_usec_ref uref,
                igs_ps_unit_subtitle usub
        WHERE
                uref.uoo_id = p_uoo_id AND
                uref.subtitle_id = usub.subtitle_id(+);

        -- To fetch the deatils from unit level level
        CURSOR uv_title_dtls (cp_unit_cd igs_ps_unit_ofr_opt.unit_cd%TYPE,
                  cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE)
      IS
        SELECT
                uv.title,
                usub.subtitle
        FROM
                igs_ps_unit_ver        uv ,
                igs_ps_unit_subtitle  usub
        WHERE
                uv.unit_cd = cp_unit_cd AND
                uv.version_number  = cp_version_number AND
                uv.subtitle_id = usub.subtitle_id(+);

        CURSOR cur_fetch_unit_dtls(cp_uoo_id NUMBER) IS
        select unit_cd , version_number
        from igs_ps_unit_ofr_opt
        where uoo_id = cp_uoo_id;

        title_subtitle_dtls_rec usec_subtitle_dtls%ROWTYPE;
        l_stdnt_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_stdnt_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_usec_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_usec_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_uv_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_uv_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_unit_cd igs_ps_unit_ver.unit_cd%TYPE;
        l_unit_ver  igs_ps_unit_ver.version_number%TYPE;
BEGIN
      IF p_unit_cd IS NULL THEN
          OPEN cur_fetch_unit_dtls(p_uoo_id);
          FETCH cur_fetch_unit_dtls into l_unit_cd, l_unit_ver;
          CLOSE cur_fetch_unit_dtls;
      ELSE
          l_unit_cd := p_unit_cd;
          l_unit_ver := p_version_number;
      END IF;


      -- first check if title  and subtitle exists at student level
        OPEN stdnt_subtitle_dtls;
        FETCH stdnt_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_stdnt_title := title_subtitle_dtls_rec.title;
        l_stdnt_subtitle := title_subtitle_dtls_rec.subtitle;
        CLOSE stdnt_subtitle_dtls;

        -- Details are found at student level hence return the value
        -- and no processing further in the procedure
        IF ( l_stdnt_title IS NOT NULL AND l_stdnt_subtitle IS NOT NULL)
        THEN
                RETURN ( l_stdnt_title || '-' || '<BR>' || l_stdnt_subtitle);
        END IF;

        -- No details at student level hence now check at the unit section level
        OPEN usec_subtitle_dtls;
        FETCH usec_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_usec_title := title_subtitle_dtls_rec.title;
        l_usec_subtitle := title_subtitle_dtls_rec.subtitle;
        -- Either no record exists or one of the values is null
        -- hence check at unit level
        IF ( usec_subtitle_dtls%NOTFOUND) OR ( ( l_usec_title IS NULL) OR ( l_usec_subtitle IS NULL)) THEN
                CLOSE usec_subtitle_dtls;
               -- check at unit level
                OPEN uv_title_dtls(l_unit_cd,l_unit_ver);
                FETCH uv_title_dtls INTO title_subtitle_dtls_rec;
                l_uv_title := title_subtitle_dtls_rec.title;
                l_uv_subtitle := title_subtitle_dtls_rec.subtitle;
                CLOSE uv_title_dtls;
        ELSE
            CLOSE usec_subtitle_dtls;
        END IF;

        IF ( NVL ( NVL ( l_stdnt_subtitle, l_usec_subtitle) , l_uv_subtitle)) IS NULL THEN
                RETURN ( NVL ( NVL ( l_stdnt_title, l_usec_title) , l_uv_title));
        ELSE
                -- Return the concatenation of title abd subtitle
                RETURN ( NVL ( NVL ( l_stdnt_title, l_usec_title) , l_uv_title) || '-' || '<BR>' || NVL ( NVL ( l_stdnt_subtitle, l_usec_subtitle) , l_uv_subtitle));
        END IF;
END get_title_section;


FUNCTION get_title
(
        p_person_id       IN NUMBER,
        p_uoo_id          IN NUMBER,
        p_unit_cd         IN VARCHAR2,
        p_version_number  IN NUMBER,
        p_course_cd       IN VARCHAR2
)RETURN VARCHAR2 AS
        -- To fetch the deatils from student level
        CURSOR stdnt_subtitle_dtls IS
        SELECT
                alternative_title title,
                subtitle
        FROM
                igs_en_su_attempt
        WHERE
                person_id = p_person_id AND
                course_cd = p_course_cd AND
                uoo_id = p_uoo_id;
        -- To fetch the deatils from section level
        CURSOR usec_subtitle_dtls IS
        SELECT
                uref.title,
                usub.subtitle
        FROM
                igs_ps_usec_ref uref,
                igs_ps_unit_subtitle usub
        WHERE
                uref.uoo_id = p_uoo_id AND
                uref.subtitle_id = usub.subtitle_id(+);

        -- To fetch the deatils from unit level level
        CURSOR uv_title_dtls IS
        SELECT
                uv.title,
                usub.subtitle
        FROM
                igs_ps_unit_ver        uv ,
                igs_ps_unit_subtitle  usub
        WHERE
                uv.unit_cd = p_unit_cd AND
                uv.version_number  = p_version_number AND
                uv.subtitle_id = usub.subtitle_id(+);
        title_subtitle_dtls_rec usec_subtitle_dtls%ROWTYPE;
        l_stdnt_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_stdnt_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_usec_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_usec_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_uv_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_uv_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
BEGIN
      -- first check if title  and subtitle exists at student level
        OPEN stdnt_subtitle_dtls;
        FETCH stdnt_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_stdnt_title := title_subtitle_dtls_rec.title;
        l_stdnt_subtitle := title_subtitle_dtls_rec.subtitle;
        CLOSE stdnt_subtitle_dtls;

        -- Details are found at student level hence return the value
        -- and no processing further in the procedure
        IF ( l_stdnt_title IS NOT NULL AND l_stdnt_subtitle IS NOT NULL)
        THEN
                RETURN ( l_stdnt_title || '<BR>' || l_stdnt_subtitle);
        END IF;

        -- No details at student level hence now check at the unit section level
        OPEN usec_subtitle_dtls;
        FETCH usec_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_usec_title := title_subtitle_dtls_rec.title;
        l_usec_subtitle := title_subtitle_dtls_rec.subtitle;
        -- Either no record exists or one of the values is null
        -- hence check at unit level
        IF ( usec_subtitle_dtls%NOTFOUND) OR ( ( l_usec_title IS NULL) OR ( l_usec_title IS NULL)) THEN
                CLOSE usec_subtitle_dtls;
               -- check at unit level
                OPEN uv_title_dtls;
                FETCH uv_title_dtls INTO title_subtitle_dtls_rec;
                l_uv_title := title_subtitle_dtls_rec.title;
                l_uv_subtitle := title_subtitle_dtls_rec.subtitle;
                CLOSE uv_title_dtls;
        END IF;
        RETURN ( NVL ( NVL ( l_stdnt_title, l_usec_title) , l_uv_title));

END get_title;

FUNCTION get_subtitle
(
        p_person_id       IN NUMBER,
        p_uoo_id          IN NUMBER,
        p_unit_cd         IN VARCHAR2,
        p_version_number  IN NUMBER,
        p_course_cd       IN VARCHAR2
)RETURN VARCHAR2 AS
        -- To fetch the deatils from student level
        CURSOR stdnt_subtitle_dtls IS
        SELECT
                alternative_title title,
                subtitle
        FROM
                igs_en_su_attempt
        WHERE
                person_id = p_person_id AND
                course_cd = p_course_cd AND
                uoo_id = p_uoo_id;
        -- To fetch the deatils from section level
        CURSOR usec_subtitle_dtls IS
        SELECT
                uref.title,
                usub.subtitle
        FROM
                igs_ps_usec_ref uref,
                igs_ps_unit_subtitle usub
        WHERE
                uref.uoo_id = p_uoo_id AND
                uref.subtitle_id = usub.subtitle_id(+);

        -- To fetch the deatils from unit level level
        CURSOR uv_title_dtls IS
        SELECT
                uv.title,
                usub.subtitle
        FROM
                igs_ps_unit_ver        uv ,
                igs_ps_unit_subtitle  usub
        WHERE
                uv.unit_cd = p_unit_cd AND
                uv.version_number  = p_version_number AND
                uv.subtitle_id = usub.subtitle_id(+);
        title_subtitle_dtls_rec usec_subtitle_dtls%ROWTYPE;
        l_stdnt_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_stdnt_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_usec_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_usec_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
        l_uv_title igs_ps_unit_ver.title%TYPE DEFAULT NULL;
        l_uv_subtitle igs_ps_unit_subtitle.subtitle%TYPE DEFAULT NULL;
BEGIN
      -- first check if title  and subtitle exists at student level
        OPEN stdnt_subtitle_dtls;
        FETCH stdnt_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_stdnt_title := title_subtitle_dtls_rec.title;
        l_stdnt_subtitle := title_subtitle_dtls_rec.subtitle;
        CLOSE stdnt_subtitle_dtls;

        -- Details are found at student level hence return the value
        -- and no processing further in the procedure
        IF ( l_stdnt_title IS NOT NULL AND l_stdnt_subtitle IS NOT NULL)
        THEN
                RETURN ( l_stdnt_title || '<BR>' || l_stdnt_subtitle);
        END IF;

        -- No details at student level hence now check at the unit section level
        OPEN usec_subtitle_dtls;
        FETCH usec_subtitle_dtls INTO title_subtitle_dtls_rec;
        l_usec_title := title_subtitle_dtls_rec.title;
        l_usec_subtitle := title_subtitle_dtls_rec.subtitle;
        -- Either no record exists or one of the values is null
        -- hence check at unit level
        IF ( usec_subtitle_dtls%NOTFOUND) OR ( ( l_usec_title IS NULL) OR ( l_usec_title IS NULL)) THEN
                CLOSE usec_subtitle_dtls;
               -- check at unit level
                OPEN uv_title_dtls;
                FETCH uv_title_dtls INTO title_subtitle_dtls_rec;
                l_uv_title := title_subtitle_dtls_rec.title;
                l_uv_subtitle := title_subtitle_dtls_rec.subtitle;
                CLOSE uv_title_dtls;
        END IF;
        RETURN  NVL ( NVL ( l_stdnt_subtitle, l_usec_subtitle) , l_uv_subtitle);

END get_subtitle;

 ------------------------------------------------------------------------------------
  --Created by  :  ( Oracle IDC)
  --Date created:
  --
  --Purpose: To get the grading schema from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
  --Change History:
  --Who           When            What
  -- prgoyal      8-NOV-2001      Added description, comments for procedure,
  --                              modifed procedure for input parameters and where clause
  --                              of cursor for student level
     ------------------------------------------------------------------------------
FUNCTION get_grading_schema
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2 AS
         -- to get grading schema at student level
        CURSOR stdnt_usec_grd_sch IS
        SELECT
                sua.grading_schema_code
        FROM
                igs_en_su_attempt sua
        WHERE
                sua.person_id = p_person_id AND
                sua.uoo_id = p_uoo_id AND
                sua.course_cd = p_course_cd;

         -- to get grading schema at section level
        CURSOR usec_grd_sch IS
        SELECT
                usgr.grading_schema_code
        FROM
                igs_ps_usec_grd_schm usgr
        WHERE
                usgr.uoo_id = p_uoo_id AND
                usgr.default_flag = 'Y';

        -- to get grading schema at unit level
        CURSOR unit_grd_sch IS
        SELECT
                grading_schema_code
        FROM
                igs_ps_unit_grd_schm uvgr
        WHERE
                uvgr.unit_code = p_unit_cd AND
                uvgr.unit_version_number =  p_version_number AND
                uvgr.default_flag = 'Y';

        l_usec_grd_sch igs_en_su_attempt.grading_schema_code%TYPE DEFAULT NULL;
        l_stdnt_usec_grd_sch igs_en_su_attempt.grading_schema_code%TYPE DEFAULT NULL;
        l_unit_grd_sch igs_en_su_attempt.grading_schema_code%TYPE DEFAULT NULL;
BEGIN
        -- get the grading schema at student level
        OPEN stdnt_usec_grd_sch;
        FETCH stdnt_usec_grd_sch INTO l_stdnt_usec_grd_sch;
        CLOSE stdnt_usec_grd_sch;
        -- if found then return the value else lok one level above at section level
        IF l_stdnt_usec_grd_sch IS NOT NULL THEN
                RETURN l_stdnt_usec_grd_sch;
        END IF;

        -- get the grading schema at section level
        OPEN usec_grd_sch;
        FETCH usec_grd_sch INTO l_usec_grd_sch;

        -- Not found at section level hence look at the unit level
        IF usec_grd_sch%NOTFOUND OR l_usec_grd_sch IS NULL THEN
                OPEN unit_grd_sch;
                FETCH unit_grd_sch INTO l_unit_grd_sch;
                CLOSE unit_grd_sch;
        END IF;
        CLOSE usec_grd_sch;
        RETURN ( NVL( l_usec_grd_sch, l_unit_grd_sch));
END get_grading_schema;

 ------------------------------------------------------------------------------------
  --Created by  :  ( Oracle IDC)
  --Date created:
  --
  --Purpose: To get the grading schema from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- if person id is null then only the unit section and unit level would be seen
  --Change History:
  --Who           When            What
  -- msrinivi      8-NOV-2001      Added description, comments for procedure,
  --                              modifed procedure for input parameters and where clause
  --                              of cursor for student level
     ------------------------------------------------------------------------------
FUNCTION get_grading_schema_ver
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN NUMBER AS
         -- to get grading schema at student level
        CURSOR stdnt_usec_grd_sch IS
        SELECT
                sua.gs_version_number
        FROM
                igs_en_su_attempt sua
        WHERE
                sua.person_id = p_person_id AND
                sua.uoo_id = p_uoo_id AND
                sua.course_cd = p_course_cd;

         -- to get grading schema at section level
        CURSOR usec_grd_sch IS
        SELECT
                usgr.grd_schm_version_number
        FROM
                igs_ps_usec_grd_schm usgr
        WHERE
                usgr.uoo_id = p_uoo_id AND
                usgr.default_flag = 'Y';

        -- to get grading schema at unit level
        CURSOR unit_grd_sch IS
        SELECT
                grd_schm_version_number
        FROM
                igs_ps_unit_grd_schm uvgr
        WHERE
                uvgr.unit_code = p_unit_cd AND
                uvgr.unit_version_number =  p_version_number AND
                uvgr.default_flag = 'Y';

        l_usec_grd_sch_ver igs_en_su_attempt.gs_version_number%TYPE DEFAULT NULL;
        l_stdnt_usec_grd_sch_ver igs_en_su_attempt.gs_version_number%TYPE DEFAULT NULL;
        l_unit_grd_sch_ver igs_en_su_attempt.gs_version_number%TYPE DEFAULT NULL;
BEGIN
        -- get the grading schema at student level
        OPEN stdnt_usec_grd_sch;
        FETCH stdnt_usec_grd_sch INTO l_stdnt_usec_grd_sch_ver;
        CLOSE stdnt_usec_grd_sch;
        -- if found then return the value else lok one level above at section level
        IF l_stdnt_usec_grd_sch_ver IS NOT NULL THEN
                RETURN l_stdnt_usec_grd_sch_ver;
        END IF;

        -- get the grading schema at section level
        OPEN usec_grd_sch;
        FETCH usec_grd_sch INTO l_usec_grd_sch_ver;

        -- Not found at section level hence look at the unit level
        IF usec_grd_sch%NOTFOUND OR l_usec_grd_sch_ver IS NULL THEN
                OPEN unit_grd_sch;
                FETCH unit_grd_sch INTO l_unit_grd_sch_ver;
                CLOSE unit_grd_sch;
        END IF;
        CLOSE usec_grd_sch;
        RETURN ( NVL( l_usec_grd_sch_ver, l_unit_grd_sch_ver));
END get_grading_schema_ver;

FUNCTION get_grading_schema_desc
(
        p_person_id  IN NUMBER,
        p_uoo_id     IN NUMBER,
        p_unit_cd    IN VARCHAR2,
        p_version_number  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2 AS

	 -- to get grading schema at student level
        CURSOR stdnt_usec_grd_sch (cp_n_person_id IN NUMBER,
	                           cp_n_uoo_id IN NUMBER,
				   cp_c_course_cd IN VARCHAR2) IS
        SELECT
                sua.grading_schema_code,
		sua.gs_version_number
        FROM
                igs_en_su_attempt sua
        WHERE
                sua.person_id = cp_n_person_id AND
                sua.uoo_id = cp_n_uoo_id AND
                sua.course_cd = p_course_cd;

         -- to get grading schema at section level
        CURSOR usec_grd_sch (cp_n_uoo_id IN NUMBER) IS
        SELECT
                usgr.grading_schema_code,
		usgr.grd_schm_version_number
        FROM
                igs_ps_usec_grd_schm usgr
        WHERE
                usgr.uoo_id = cp_n_uoo_id AND
                usgr.default_flag = 'Y';

        -- to get grading schema at unit level
        CURSOR unit_grd_sch (cp_c_unit_cd IN VARCHAR2,
	                     cp_n_ver_num IN NUMBER) IS
        SELECT
                uvgr.grading_schema_code,
		uvgr.grd_schm_version_number
        FROM
                igs_ps_unit_grd_schm uvgr
        WHERE
                uvgr.unit_code = cp_c_unit_cd AND
                uvgr.unit_version_number =  cp_n_ver_num AND
                uvgr.default_flag = 'Y';

        -- to get grading schema description
	CURSOR c_grd_desc(cp_grd_schm IN VARCHAR2,
	                  cp_ver_num IN NUMBER) IS
	SELECT description
	FROM   igs_as_grd_schema
	WHERE  grading_schema_cd = cp_grd_schm
	AND    version_number = cp_ver_num;

        l_grd_schm igs_as_grd_schema.grading_schema_cd%TYPE;
	l_grd_schm_ver igs_as_grd_schema.version_number%TYPE;
	l_grd_desc igs_as_grd_schema.description%TYPE;

BEGIN

   -- Get the grading schema code and version from SUA level.
   OPEN stdnt_usec_grd_sch(p_person_id,p_uoo_id,p_course_cd);
   FETCH stdnt_usec_grd_sch INTO l_grd_schm,l_grd_schm_ver;
   IF l_grd_schm IS NULL THEN

      -- if does not exists at SUA level then get it from Unit Section Level.
      OPEN usec_grd_sch(p_uoo_id);
      FETCH usec_grd_sch INTO l_grd_schm,l_grd_schm_ver;
      IF l_grd_schm IS NULL THEN

	 -- if does not exists at Unit Section level also then get it from Unit Version Level.
         OPEN unit_grd_sch(p_unit_cd, p_version_number);
	 FETCH unit_grd_sch INTO l_grd_schm,l_grd_schm_ver;
	 CLOSE unit_grd_sch;

      END IF;
      CLOSE usec_grd_sch;

   END IF;
   CLOSE stdnt_usec_grd_sch;

   -- Get the description of grading schema code and version number
   OPEN c_grd_desc (l_grd_schm,l_grd_schm_ver);
   FETCH c_grd_desc INTO l_grd_desc;
   CLOSE c_grd_desc;

   RETURN l_grd_desc;

END get_grading_schema_desc;


FUNCTION get_grading_cd_ver
(
        p_person_id  IN NUMBER,
        p_uoo_id  IN NUMBER,
        p_unit_cd  IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd IN VARCHAR2
)RETURN VARCHAR2 AS

	-- to get grading schema at student level
        CURSOR stdnt_usec_grd_sch (cp_n_person_id IN NUMBER,
	                           cp_n_uoo_id IN NUMBER,
				   cp_c_course_cd IN VARCHAR2) IS
        SELECT
                sua.grading_schema_code,
		sua.gs_version_number
        FROM
                igs_en_su_attempt sua
        WHERE
                sua.person_id = cp_n_person_id AND
                sua.uoo_id = cp_n_uoo_id AND
                sua.course_cd = p_course_cd;

        -- to get grading schema at section level
        CURSOR usec_grd_sch (cp_n_uoo_id IN NUMBER) IS
        SELECT
                usgr.grading_schema_code,
		usgr.grd_schm_version_number
        FROM
                igs_ps_usec_grd_schm usgr
        WHERE
                usgr.uoo_id = cp_n_uoo_id AND
                usgr.default_flag = 'Y';

        -- to get grading schema at unit level
        CURSOR unit_grd_sch (cp_c_unit_cd IN VARCHAR2,
	                     cp_n_ver_num IN NUMBER) IS
        SELECT
                uvgr.grading_schema_code,
		uvgr.grd_schm_version_number
        FROM
                igs_ps_unit_grd_schm uvgr
        WHERE
                uvgr.unit_code = cp_c_unit_cd AND
                uvgr.unit_version_number =  cp_n_ver_num AND
                uvgr.default_flag = 'Y';

        l_grd_schm igs_as_grd_schema.grading_schema_cd%TYPE;
	l_grd_schm_ver igs_as_grd_schema.version_number%TYPE;

BEGIN

   -- Get the grading schema code and version from SUA level.
   OPEN stdnt_usec_grd_sch(p_person_id,p_uoo_id,p_course_cd);
   FETCH stdnt_usec_grd_sch INTO l_grd_schm,l_grd_schm_ver;
   IF l_grd_schm IS NULL THEN

      -- if does not exists at SUA level then get it from Unit Section Level.
      OPEN usec_grd_sch(p_uoo_id);
      FETCH usec_grd_sch INTO l_grd_schm,l_grd_schm_ver;
      IF l_grd_schm IS NULL THEN

	 -- if does not exists at Unit Section level also then get it from Unit Version Level.
         OPEN unit_grd_sch(p_unit_cd, p_version_number);
	 FETCH unit_grd_sch INTO l_grd_schm,l_grd_schm_ver;
	 CLOSE unit_grd_sch;

      END IF;
      CLOSE usec_grd_sch;

   END IF;
   CLOSE stdnt_usec_grd_sch;

   RETURN l_grd_schm || ',' || l_grd_schm_ver;

END get_grading_cd_ver;

 ------------------------------------------------------------------------------------
  --Created by  :  ( Oracle IDC)
  --Date created:
  --
   -- Purpose: To get the overrid enrolled credit points from student level. If not available
  -- at student level then from unit section level and if not avialble at
  -- section level then from unit level
  -- at unit level if the variable credit poins indicator is checked then
  -- the achievable credit points is not null at section level then fetch that value
  -- if that is null or the indiactor is not set then get the enrolled credit points
  -- at the unit level
  -- this is because it is assumed that at section level if variable credit points are
  -- to be defined then it would be  stored in achievable credit points field as enrolled
  -- credit points are not stored at section level

  --Change History:
  --Who           When            What
  -- prgoyal      8-NOV-2001      Added description, comments for procedure,
  --                              modifed procedure for input parameters and where clause
  --                              of cursor for student level
  --                              added the section level check
     ------------------------------------------------------------------------------
FUNCTION get_credit_points
(
        p_person_id       IN NUMBER,
        p_uoo_id          IN NUMBER,
        p_unit_cd         IN VARCHAR2,
        p_version_NUMBER  IN NUMBER,
        p_course_cd       IN VARCHAR2
)RETURN NUMBER AS

       -- get credit points at unit level
        CURSOR unit_credit_pts IS
        SELECT
                NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) credit_points
        FROM
                igs_ps_unit_ofr_opt uoo,
                igs_ps_usec_cps cps,
                igs_ps_unit_ver uv
        WHERE
                uoo.uoo_id=cps.uoo_id(+) AND
                uoo.uoo_id=p_uoo_id  AND
                uoo.unit_cd=uv.unit_cd AND
                uoo.version_number=uv.version_number ;


        -- get the credit points at student level
        CURSOR stdnt_credit_pts IS
        SELECT
                sua.override_enrolled_cp
        FROM
                igs_en_su_attempt     sua
        WHERE
                sua.person_id = p_person_id AND
                sua.uoo_id = p_uoo_id AND
                sua.course_cd= p_course_cd;

        l_unit_credit_pts  igs_ps_unit_ver.enrolled_credit_points%TYPE DEFAULT NULL;
        l_stdnt_credit_pts igs_ps_unit_ver.enrolled_credit_points%TYPE DEFAULT NULL;

BEGIN
        -- verify at student level and return if value found
        IF p_person_id IS NOT NULL THEN
                OPEN stdnt_credit_pts;
                FETCH stdnt_credit_pts INTO l_stdnt_credit_pts;
                CLOSE stdnt_credit_pts;
                IF l_stdnt_credit_pts IS NOT NULL THEN
                        RETURN l_stdnt_credit_pts;
                END IF;
        END IF;
        -- fetch at unit level..
        OPEN unit_credit_pts;
        FETCH unit_credit_pts INTO l_unit_credit_pts;
        CLOSE unit_credit_pts;

        RETURN l_unit_credit_pts;

END get_credit_points;

 ------------------------------------------------------------------------------------
  --Created by  : prgoyal ( Oracle IDC)
  --Date created: 14-OCT-2001
  --
  --Purpose: To be used in self service to return the primary program,
  -- version and list of program for the career for a student.
  -- The program list has primary program first followed by the other
  -- enrolled progrmas for the career
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta      25-NOV-2003     Changed get_primary_prgm_dtls and get_secondary_prgm_dtls cursors
  --                            to check for term records while retrieving program_version and
  --                            primary program. BUG #2829263
  ------------------------------------------------------------------------------

PROCEDURE enrp_get_prgm_for_career
(
p_primary_program OUT NOCOPY VARCHAR2,
p_primary_program_version OUT NOCOPY NUMBER,
p_programlist OUT NOCOPY VARCHAR2,
p_person_id IN NUMBER,
p_carrer IN VARCHAR2,
p_term_cal_type IN VARCHAR2,
p_term_sequence_number IN NUMBER
) AS

CURSOR get_primary_prgm_dtls IS
SELECT
      pv.course_cd,
      pv.version_number,
      pv.title
FROM IGS_EN_STDNT_PS_ATT_ALL sca,
     IGS_PS_VER_ALL pv
WHERE pv.course_cd = sca.course_cd
AND   pv.version_number = igs_en_spa_terms_api.get_spat_program_version(sca.person_id, sca.course_cd, p_term_cal_type,
           p_term_sequence_number)
AND   sca.course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT')
AND sca.person_id = p_person_id
AND pv.course_type = p_carrer
AND  igs_en_spa_terms_api.get_spat_primary_prg(sca.person_id, sca.course_cd, p_term_cal_type,
           p_term_sequence_number) = 'PRIMARY';



CURSOR get_secondary_prgm_dtls (p_course_code igs_en_stdnt_ps_att.course_cd%TYPE)IS
SELECT pv.title
FROM   IGS_EN_STDNT_PS_ATT_ALL sca,
       IGS_PS_VER_ALL pv
WHERE  pv.course_cd = sca.course_cd
AND    pv.version_number = sca.version_number
AND    sca.course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT')
AND    sca.person_id = p_person_id
AND    pv.course_type = p_carrer
AND    sca.course_cd <> p_course_code;
-- Returns all programs which are not the primary program for that career using the passed in primary course_cd.
l_all_program_title VARCHAR2(2000);
l_primary_program_dtls get_primary_prgm_dtls%ROWTYPE;

BEGIN
   -- Get the Primary Program Details
   Open get_primary_prgm_dtls;
   FETCH get_primary_prgm_dtls INTO l_primary_program_dtls ;
   -- If there is No Primary program set NULL to OUT NOCOPY parameters and Return
   IF get_primary_prgm_dtls%NOTFOUND THEN
      CLOSE get_primary_prgm_dtls;
      p_primary_program := NULL;
      p_primary_program_version := NULL;
      p_programlist := NULL;
      RETURN;
   END IF;
   CLOSE get_primary_prgm_dtls;

   -- Concatenate Titles of the Secondary Programs for the given Career
   FOR r_dtls IN get_secondary_prgm_dtls(l_primary_program_dtls.course_cd)
   LOOP
     l_all_program_title := l_all_program_title || ' , ' || r_dtls.title ;
   END LOOP;

   --Concatenate the Primary Program Title with All Secondary program's Titles

   l_all_program_title :=  l_primary_program_dtls.title || l_all_program_title;

   p_primary_program := l_primary_program_dtls.course_cd;
   p_primary_program_version:= l_primary_program_dtls.version_number;
   p_programlist := l_all_program_title;

END enrp_get_prgm_for_career;

FUNCTION enrp_val_subttl_chg (  p_person_id IN NUMBER,
                                p_uoo_id             IN   NUMBER
                              ) RETURN CHAR IS
CURSOR c_sua_chg_alwd IS
SELECT NVL(subtitle_modifiable_flag,'N')
FROM igs_ps_usec_ref
WHERE
uoo_id      = p_uoo_id;

l_sua_chg_alwd igs_ps_usec_ref.subtitle_modifiable_flag%TYPE;

BEGIN

OPEN c_sua_chg_alwd;
FETCH c_sua_chg_alwd INTO l_sua_chg_alwd;
CLOSE c_sua_chg_alwd;

RETURN NVL(l_sua_chg_alwd,'N');

END enrp_val_subttl_chg;


FUNCTION get_allowable_cp_range
(
 p_uoo_id IN NUMBER
 ) RETURN VARCHAR2 IS

CURSOR c_get_unit_cd_ver (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT unit_cd,version_number
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = p_uoo_id;

CURSOR c_usec_cp IS
SELECT
       minimum_credit_points,
       maximum_credit_points,
       variable_increment
FROM igs_ps_usec_cps
WHERE uoo_id = p_uoo_id;

CURSOR c_unit_cp(p_unit_cd igs_ps_unit_ver.unit_cd%TYPE,p_unit_ver igs_ps_unit_ver.version_number%TYPE) IS
SELECT
        POINTS_MIN             ,
        POINTS_MAX             ,
        points_increment
FROM igs_ps_unit_ver
WHERE unit_cd = p_unit_cd
AND version_number = p_unit_ver;

CURSOR c_enr_cp IS
SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points
FROM
igs_ps_unit_ofr_opt uoo,
igs_ps_usec_cps cps,
igs_ps_unit_ver uv
WHERE
uoo.uoo_id = cps.uoo_id(+) AND
uoo.uoo_id=p_uoo_id  AND
uoo.unit_cd=uv.unit_cd AND
uoo.version_number = uv.version_number;

l_cp_range      VARCHAR2(10000);

l_usec_min_cp   igs_ps_usec_cps.minimum_credit_points%TYPE;
l_usec_max_cp   igs_ps_usec_cps.maximum_credit_points%TYPE;
l_usec_var      igs_ps_usec_cps.variable_increment%TYPE;

l_unit_min_cp   igs_ps_unit_ver.points_min%TYPE;
l_unit_max_cp   igs_ps_unit_ver.points_max%TYPE;
l_unit_var      igs_ps_unit_ver.points_increment%TYPE;
l_enr_cr_points igs_ps_unit_ver.enrolled_credit_points%TYPE;

l_unit_cd       igs_ps_unit_ver.unit_cd%TYPE;
l_unit_ver      igs_ps_unit_ver.version_number%TYPE;

l_count         NUMBER(6,3) DEFAULT 0;
l_return_val    VARCHAR2(10000);

BEGIN

OPEN c_get_unit_cd_ver(p_uoo_id);
FETCH c_get_unit_cd_ver INTO l_unit_cd,l_unit_ver;
CLOSE c_get_unit_cd_ver;

OPEN  c_usec_cp;
FETCH c_usec_cp INTO l_usec_min_cp,l_usec_max_cp,l_usec_var;

IF c_usec_cp%NOTFOUND THEN
   OPEN c_unit_cp(l_unit_cd,l_unit_ver);
   FETCH c_unit_cp INTO l_unit_min_cp,l_unit_max_cp,l_unit_var;
     l_count := l_unit_min_cp;

     WHILE l_count <= l_unit_max_cp LOOP
       l_cp_range := l_cp_range||','||TO_CHAR(l_count);
       l_count    := l_count  +  l_unit_var;
     END LOOP;
   CLOSE c_unit_cp;

ELSE
     l_count := l_usec_min_cp;
     WHILE l_count <= l_usec_max_cp  LOOP
       l_cp_range := l_cp_range||','||TO_CHAR(l_count);
       l_count    := l_count  +  l_usec_var;
     END LOOP;
END IF;

CLOSE c_usec_cp;


l_return_val := SUBSTR(l_cp_range,2,LENGTH(l_cp_range));

IF l_return_val IS NULL THEN
   OPEN c_enr_cp;
   FETCH c_enr_cp INTO l_enr_cr_points;
   CLOSE c_enr_cp;
   l_return_val := l_enr_cr_points;
END IF;

RETURN l_return_val;


END;


FUNCTION get_notification(
    p_person_type           VARCHAR2,
    p_enrollment_category   VARCHAR2,
    p_comm_type             VARCHAR2,
    p_enr_method_type       VARCHAR2,
    p_step_group_type       VARCHAR2,
    p_step_type             VARCHAR2,
    p_person_id             NUMBER,
    p_message           OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2
AS
/* Change History
   Who         When            What
   Nishikant   01NOV2002      SEVIS Build, Enh bug#2641905.
                              p_person_id and p_message added in the signature. The new functionality is to check any validation setup existing
                              at Person ID Group level before considering base(Enrollment Category Validation Setup) level.
   ayedubat    11-APR-2002    Changed the cursor statement of cur_program_steps to add an extra 'OR'
                              condition(eru.s_student_comm_type = 'ALL') for s_student_comm_type as part of the bug fix: 2315245
   nalkumar    14-May-2002    Modified the cur_program_steps cursor as per the bug# 2364461.
   smaddali    15-oct-2004    Modified the ref cursor cur_program_steps for bug#3944353. Removed the join with lookups .
*/
  CURSOR cur_person_types
  IS
  SELECT system_type
  FROM   igs_pe_person_types
  WHERE  person_type_code = p_person_type;


 TYPE l_program_steps_rec IS RECORD (
                                       notification_flag       igs_en_cpd_ext.notification_flag%TYPE
                                     );
  TYPE cur_ref_program_steps IS REF CURSOR  RETURN l_program_steps_rec;
  cur_program_steps    cur_ref_program_steps;

 l_cur_program_steps  cur_program_steps%ROWTYPE;
 l_cur_person_types        cur_person_types%ROWTYPE;
 l_notification_flag igs_en_cpd_ext.notification_flag%TYPE;
 l_system_person_type igs_pe_person_types.system_type%TYPE;
 l_pig_deny_warn  igs_en_cpd_ext.notification_flag%TYPE;
 l_message        fnd_new_messages.message_name%TYPE;

BEGIN

OPEN  cur_person_types;
FETCH cur_person_types INTO l_cur_person_types;
CLOSE cur_person_types;

 l_system_person_type := l_cur_person_types.system_type;

 -- Calling the below function to get the notification flag of the Step Type if defined at Person ID Group level.
 l_pig_deny_warn := igs_en_val_pig.get_pig_notify_flag (p_step_type, p_person_id,l_message);
 IF l_message IS NOT NULL THEN
    p_message := l_message;
    RETURN NULL;
 END IF;

 IF l_system_person_type = 'STUDENT' THEN
    OPEN cur_program_steps FOR SELECT DECODE (l_pig_deny_warn, NULL, eru.notification_flag, l_pig_deny_warn) notification_flag
                               FROM   igs_en_cpd_ext  eru,
                                      igs_lookups_view lkup
                               WHERE  eru.s_enrolment_step_type    =  lkup.lookup_code           AND
                                      eru.enrolment_cat            =  p_enrollment_category      AND
                                     (eru.s_student_comm_type      =  p_comm_type      OR
                                      eru.s_student_comm_type      =  'ALL'               )      AND
                                      eru.enr_method_type          =  p_enr_method_type          AND
                                      lkup.lookup_type             =  'ENROLMENT_STEP_TYPE_EXT'  AND
                                      lkup.step_group_type         =  p_step_group_type          AND
                                      eru.s_enrolment_step_type    =  p_step_type;
 ELSE
--ijeddy modified the cursor for bug 3724930
        -- smaddali modified the cursor for bug#3944353 to revert the changes made by bug 3724930,
        -- removed equi join between lookups and uact as lookups is already joined to eru
        OPEN cur_program_steps FOR SELECT DECODE (uact.deny_warn,
                                       'WARN', 'WARN',
                                       'DENY', 'DENY',
                                       NULL, DECODE (l_pig_deny_warn, NULL, eru.notification_flag, l_pig_deny_warn)
                                     ) notification_flag
                        FROM   igs_en_cpd_ext_all eru,
                               igs_pe_usr_aval_all uact,
                               igs_lookups_view lkup
                        WHERE  eru.s_enrolment_step_type = lkup.lookup_code
                        AND    eru.enrolment_cat = p_enrollment_category
                        AND    eru.enr_method_type = p_enr_method_type
                        AND    (eru.s_student_comm_type = p_comm_type
                               OR eru.s_student_comm_type = 'ALL')
                        AND    lkup.lookup_type = 'ENROLMENT_STEP_TYPE_EXT'
                        AND    lkup.step_group_type = p_step_group_type
                        AND    eru.s_enrolment_step_type = uact.VALIDATION(+)
                        AND    uact.person_type(+) = p_person_type
                        AND    NVL (uact.override_ind, 'N') = 'N'
                        AND    eru.s_enrolment_step_type = p_step_type;
 END IF;
 LOOP
    FETCH cur_program_steps INTO l_cur_program_steps;
    EXIT WHEN cur_program_steps%NOTFOUND;
    l_notification_flag := l_cur_program_steps.notification_flag;
 END LOOP;
 CLOSE cur_program_steps ;
 RETURN l_notification_flag;

END get_notification;

FUNCTION get_usec_eff_dates(
    x_unit_cd VARCHAR2,
    x_version NUMBER,
    x_cal_type VARCHAR2,
    x_ci_seq_number NUMBER,
    x_location_cd VARCHAR2,
    x_unit_class VARCHAR2) RETURN VARCHAR2 IS

  CURSOR c_usec_dates IS
  SELECT  TO_CHAR(UNIT_SECTION_START_DATE) ||'  -  '||
          TO_CHAR(UNIT_SECTION_END_DATE  )
  FROM    igs_ps_unit_ofr_opt
  WHERE   unit_cd        = x_unit_cd
  AND     version_number = x_version
  AND     cal_type       = x_cal_type
  AND     ci_sequence_number = x_ci_seq_number
  AND     location_cd        = x_location_cd
  AND     unit_class         = x_unit_class ;

  CURSOR c_cal_dates IS
  SELECT TO_CHAR(START_DT)       || '  -  ' ||
         TO_CHAR(END_DT)
  FROM   igs_ca_inst
  WHERE  cal_type  = x_cal_type
  AND    sequence_number = x_ci_seq_number;

  l_eff_date VARCHAR2(50) DEFAULT NULL;

BEGIN

  OPEN c_usec_dates;
  FETCH c_usec_dates INTO l_eff_date;
   IF  l_eff_date = '  -  ' THEN
      OPEN c_cal_dates;
      FETCH c_cal_dates INTO l_eff_date;
      CLOSE c_cal_dates;
    END IF;
 CLOSE c_usec_dates;


  RETURN l_eff_date;

END;

PROCEDURE get_enrollment_limits(p_uooid NUMBER,
p_unitcode VARCHAR2,p_version  NUMBER,p_actenrolled  OUT NOCOPY NUMBER,
p_maxlimit OUT NOCOPY NUMBER ,p_minlimit  OUT NOCOPY NUMBER )
AS
--Cursor to fetch the actual enrolled from Unit Offering Option
CURSOR cur_get_actual IS
SELECT enrollment_actual
FROM   igs_ps_unit_ofr_opt
WHERE  uoo_id=p_uooid;
--Cursor to fetch the limits from Unit Section
CURSOR cur_get_usec_maxmin_limits IS
SELECT enrollment_minimum,enrollment_maximum
FROM   igs_ps_usec_lim_wlst_v
WHERE  uoo_id =p_uooid;
--Cursor to fetch the limits for Unit Code
CURSOR cur_get_unit_maxmin_limits IS
SELECT enrollment_minimum,enrollment_maximum
FROM   igs_ps_unit_ver_v
WHERE  unit_cd=p_unitcode
AND    version_number=p_version;

BEGIN

-- Actual Enrolled can be got from Unit offering Option Section Setup only
   --  as the Unit Setup will not have this information
     OPEN cur_get_actual;
     FETCH cur_get_actual INTO p_actenrolled;
     CLOSE cur_get_actual;
-- Max and Min Enrollment Limits from UnitSection
   OPEN cur_get_usec_maxmin_limits;
   FETCH cur_get_usec_maxmin_limits INTO p_minlimit,p_maxlimit ;
    IF cur_get_usec_maxmin_limits%NOTFOUND THEN
-- Max and Min Enrollment Limits from Unit
    BEGIN
          OPEN cur_get_unit_maxmin_limits;
          FETCH cur_get_unit_maxmin_limits INTO   p_minlimit,p_maxlimit;
          CLOSE cur_get_unit_maxmin_limits;
    END;
    END IF;
   CLOSE cur_get_usec_maxmin_limits;
END get_enrollment_limits;

 ------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 09-Jan-2002
  --
  --Purpose: To Get the latest term calendar info for the given person/program,
  --         in which at least one ENROLLED unit attempt exist
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------------------
PROCEDURE enrp_get_enr_term
(
p_person_id IN NUMBER,
p_course_cd IN VARCHAR2,
p_cal_type OUT NOCOPY VARCHAR2,
p_sequence_number OUT NOCOPY NUMBER,
p_term_desc OUT NOCOPY VARCHAR2
) AS

--ijeddy modified the cursor for bug 3724930
CURSOR c_term_info_ccd IS
SELECT  ttl.load_cal_type, ttl.load_ci_sequence_number, ttl.load_description
    FROM igs_ca_teach_to_load_v ttl, igs_en_su_attempt_all sua
   WHERE ttl.teach_cal_type = sua.cal_type
     AND ttl.teach_ci_sequence_number = sua.ci_sequence_number
     AND sua.unit_attempt_status = 'ENROLLED'
     AND sua.person_id = p_person_id
     AND sua.course_cd = p_course_cd
ORDER BY ttl.load_start_dt DESC;


CURSOR c_term_info IS
SELECT  ttl.load_cal_type, ttl.load_ci_sequence_number, ttl.load_description
    FROM igs_ca_teach_to_load_v ttl, igs_en_su_attempt_all sua
   WHERE ttl.teach_cal_type = sua.cal_type
     AND ttl.teach_ci_sequence_number = sua.ci_sequence_number
     AND sua.unit_attempt_status = 'ENROLLED'
     AND sua.person_id = p_person_id
ORDER BY ttl.load_start_dt DESC;


l_term_info c_term_info%ROWTYPE;

BEGIN

  IF (p_course_cd IS NULL) THEN
          OPEN c_term_info;
          FETCH c_term_info INTO l_term_info;
          CLOSE c_term_info;
  ELSE
          OPEN c_term_info_ccd;
          FETCH c_term_info_ccd INTO l_term_info;
          CLOSE c_term_info_ccd;
  END IF;

  p_cal_type := l_term_info.load_cal_type;
  p_sequence_number := l_term_info.load_ci_sequence_number;
  p_term_desc := l_term_info.load_description;

END enrp_get_enr_term;

/* This Function returns Lead Instructor of a Unit Section if it exists otherwise returns NULL */
FUNCTION get_lead_instructor_name(
p_uoo_id IN NUMBER
) RETURN VARCHAR2 AS
CURSOR cur_lead_instr_info IS
SELECT  first_name || ' ' || last_name  Instructor_Name
FROM igs_pe_person_base_v  a,
     igs_ps_usec_tch_resp b
WHERE b.uoo_id = p_uoo_id AND
b.INSTRUCTOR_ID = a.person_id AND
b.LEAD_INSTRUCTOR_FLAG = 'Y';

l_lead_instr_info cur_lead_instr_info%ROWTYPE;
l_instructor_name varchar2(301);

BEGIN
  OPEN cur_lead_instr_info;
  FETCH cur_lead_instr_info INTO l_lead_instr_info;
  IF cur_lead_instr_info%FOUND THEN
    l_instructor_name := l_lead_instr_info.Instructor_Name;
  ELSE
    l_instructor_name := NULL;
  END IF;
  CLOSE cur_lead_instr_info;
  RETURN l_instructor_name;

END get_lead_instructor_name;


-------------------------------------------------------------------------------
--Created by  : kkillams ( Oracle IDC)
--Date created: 22-MAY-2002
--
--Purpose: This function returns the max waitlist defined at organization level
--         for teaching calendar
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------
FUNCTION get_max_std_wait_org_level(
                                    p_owner_org_unit_cd IN VARCHAR2,
                                    p_cal_type          IN VARCHAR2,
                                    p_sequence_number   IN NUMBER
) RETURN NUMBER AS
CURSOR cur_org IS SELECT max_stud_per_wlst FROM  igs_en_or_unit_wlst
                                            WHERE org_unit_cd     = p_owner_org_unit_cd  AND
                                                  cal_type        = p_cal_type           AND
                                                  sequence_number = p_sequence_number;
lv_max_stud_per_wlst  igs_en_or_unit_wlst.max_stud_per_wlst%TYPE DEFAULT NULL;
BEGIN
 OPEN cur_org;
 FETCH cur_org INTO lv_max_stud_per_wlst;
 IF cur_org%NOTFOUND THEN
    close cur_org;
    RETURN NULL;
 ELSE
    close cur_org;
    RETURN lv_max_stud_per_wlst;
 END IF;
END get_max_std_wait_org_level;

-------------------------------------------------------------------------------
--Created by  : TNATARAJ
--Date created: 19-JUL-2002
--
--Purpose: This function returns the Name(s) of the Instructor(s)
--         associated for the given Uoo_id. If multiple instructors
--         are associated , the names of all the instructors are concatenated
--         and the concatenated string is returned- bug # 2446078
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------
FUNCTION get_usec_instructor_names
(
p_uoo_id in number
) return varchar2
is

lv_instr_names varchar2(32000) ;
CURSOR c_usec_instructor_names
IS
SELECT hz.person_last_name || ', '||hz.person_first_name || ' '||hz.person_middle_name instructor_name
FROM
hz_parties hz,
igs_ps_uso_instrctrs a
WHERE a.instructor_id(+) = hz.party_id
AND   a.unit_section_occurrence_id = p_uoo_id
ORDER BY 1 ;

BEGIN
        FOR c_usec_instructor_names_data in c_usec_instructor_names
            LOOP
                 IF lv_instr_names IS NOT NULL
                 THEN
                       lv_instr_names  := lv_instr_names ||'<BR>'||c_usec_instructor_names_data.instructor_name ;
                 ELSE
                             lv_instr_names  := c_usec_instructor_names_data.instructor_name;
                 END IF ;
            END LOOP ;
            RETURN lv_instr_names ;

END get_usec_instructor_names ;

PROCEDURE  Enrp_Get_Usec_Group (
     p_uoo_id           igs_ps_unit_ofr_opt.uoo_id%TYPE,
     p_return_status    OUT NOCOPY VARCHAR2,
     p_group_type       OUT NOCOPY igs_lookups_view.meaning%TYPE,
     p_group_name       OUT NOCOPY igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE
   ) AS

   ------------------------------------------------------------------------------------
    --Created by  : pradhakr
    --Date created: 27-Oct-2002
    --
    --Purpose:
    --  Procedure added to get the Group Name and Group Type of the passed Unit Section,
    --  if it belongs to any cross-listed / meet with group.
    --  Added as part of Cross List / Meet With DLD. bug# 2599929
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --
    -------------------------------------------------------------------------------------


  -- Cursor to get the enrollment maximum in cross listed group
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.usec_x_listed_group_name
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;


  -- Cursor to get the enrollment maximum in Meet with class group
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.class_meet_group_name
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;

   -- Cursor to get the meaning for the lookup_code 'CROSS_LIST' / 'MEET_WITH'
   CURSOR c_group_type(l_lookup_code  igs_lookups_view.lookup_code%type) IS
   SELECT meaning
   FROM igs_lookups_view
   WHERE lookup_type = 'IGS_PS_USEC_GROUPS'
   AND lookup_code = l_lookup_code;

  l_cross_listed_row c_cross_listed%ROWTYPE;
  l_meet_with_cls_row c_meet_with_cls%ROWTYPE;


  BEGIN

    p_return_status := 'N';

    -- Check whether the unit section belongs to any cross listed group If yes, return the status as Y
    -- and get the group name and type.

    OPEN c_cross_listed(p_uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row;

    IF c_cross_listed%FOUND THEN
      p_return_status := 'Y';
      p_group_name := l_cross_listed_row.usec_x_listed_group_name;

      OPEN c_group_type('CROSS_LIST');
      fetch c_group_type INTO p_group_type;
      CLOSE c_group_type;

    ELSE

      -- Check whether the Unit Section belongs to Meet with class. If yes, return the status as Y
      -- and get the group name and type.

      OPEN c_meet_with_cls(p_uoo_id);
      FETCH c_meet_with_cls INTO l_meet_with_cls_row;

      IF c_meet_with_cls%FOUND THEN
         p_return_status := 'Y';
         p_group_name := l_meet_with_cls_row.class_meet_group_name;

         -- Cursor to get the group type
         OPEN c_group_type('MEET_WITH');
         fetch c_group_type INTO p_group_type;
         CLOSE c_group_type;
      ELSE
        -- If the Unit Section doesn't belongs to any group then retunr the status as N
        p_return_status := 'N';
        p_group_type := NULL;
        p_group_name := NULL;
      END IF;
      CLOSE c_meet_with_cls;
    END IF;
    CLOSE c_cross_listed;

  END Enrp_Get_Usec_Group;


  FUNCTION Enrp_Get_Enr_Max_Act (
         p_uoo_id               igs_ps_unit_ofr_opt.uoo_id%TYPE
  ) RETURN VARCHAR2 IS

  ------------------------------------------------------------------------------------
    --Created by  : pradhakr
    --Date created: 27-Oct-2002
    --
    --Purpose:
    --  The following function returns the concatenated value of Enrollment Maximum and
    --  Actual Enrollment if the passed unit section belongs to any cross-listed / meet with group.
    --  Added as part of Cross List / Meet With DLD. bug# 2599929
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -- pradhakr   30-Dec-02       Changed the data type of the variable l_max from
    --                            igs_ps_usec_x_grp.max_enr_group to
    --                            igs_ps_usec_lim_wlst.enrollment_maximum.
    -------------------------------------------------------------------------------------

  -- Cursor to get the enrollment maximum in cross listed group
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grpmem.usec_x_listed_group_id
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;


  -- Cursor to get the enrollment maximum in Meet with class group
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, ucm.class_meet_group_id
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;

   -- Cursor to get the actual enrollment of all the unit sections that belong
   -- to this class listed group.
  CURSOR c_actual_enr_crs_lst(l_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_usec_x_grpmem ugrp
  WHERE  uoo.uoo_id = ugrp.uoo_id
  AND    ugrp.usec_x_listed_group_id = l_usec_x_listed_group_id;


  -- Cursor to get the actual enrollment of all the unit sections that belong
  -- to this meet with class group.
  CURSOR c_actual_enr_meet_cls(l_class_meet_group_id igs_ps_uso_clas_meet.class_meet_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_uso_clas_meet ucls
  WHERE  uoo.uoo_id = ucls.uoo_id
  AND    ucls.class_meet_group_id = l_class_meet_group_id;


   -- Cursor to get the meaning for the lookup_code 'CROSS_LIST' / 'MEET_WITH'
   CURSOR c_group_type(l_lookup_code  igs_lookups_view.lookup_code%type) IS
   SELECT meaning
   FROM igs_lookups_view
   WHERE lookup_type = 'IGS_PS_USEC_GROUPS'
   AND lookup_code = l_lookup_code;

  -- Cursor to fetch the enrollment Maximum value defined at Unit Section level
  CURSOR cur_usec_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_maximum
  FROM igs_ps_usec_lim_wlst
  WHERE uoo_id = p_uoo_id;

  -- cursor to fetch the enrollment maximum value defined at unit level
  CURSOR cur_unit_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_maximum
  FROM   igs_ps_unit_ver
  WHERE  (unit_cd , version_number ) IN (SELECT unit_cd , version_number
                                         FROM   igs_ps_unit_ofr_opt
                                         WHERE  uoo_id = p_uoo_id);

  --
  --  Cursor to find the Actual Enrollment of the Unit section
  --
  CURSOR c_enroll_actual (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_actual
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = cp_uoo_id;


  l_class_meet_group_id  igs_ps_uso_clas_meet.class_meet_group_id%TYPE;
  l_max igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;
  l_act igs_ps_unit_ofr_opt.enrollment_actual%TYPE;
  l_total_enrollment NUMBER;
  l_actual_enr igs_ps_unit_ofr_opt_all.enrollment_actual%TYPE;
  l_meet_meaning  igs_lookups_view.meaning%TYPE;
  l_cross_meaning  igs_lookups_view.meaning%TYPE;
  l_usec_partof_group  BOOLEAN;
  l_cat_enr_act varchar2(100);
  l_setup_found NUMBER;
  l_temp VARCHAR2(10);
  l_cross_listed_row c_cross_listed%ROWTYPE;
  l_meet_with_cls_row c_meet_with_cls%ROWTYPE;

  BEGIN

  -- Check whether the unit section belongs to any cross listed group. If so then get the
  -- maximim enrollment limit in the group level. If it is not null then get the actual enrollment
  -- of all the unit sections which belong to that group and return the concatenated string of
  -- Maximim enrollment and actual enrollment.
  -- Incase if the maximum enrollment limit is not set in the group level the get it from
  -- Unit Section level or in the unit level.

    l_usec_partof_group := FALSE;

    OPEN c_cross_listed(p_uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row ;

    IF c_cross_listed%FOUND THEN

         -- Get the maximum enrollment limit from the group level.
        IF l_cross_listed_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;

        ELSE
          l_usec_partof_group := TRUE;
          l_max := l_cross_listed_row.max_enr_group;

      -- Get the actual enrollment count of all the unit sections that belongs to the cross listed group.
      OPEN c_actual_enr_crs_lst(l_cross_listed_row.usec_x_listed_group_id);
      FETCH c_actual_enr_crs_lst INTO l_act;
      CLOSE c_actual_enr_crs_lst;

      OPEN c_group_type('CROSS_LIST');
          FETCH c_group_type INTO l_cross_meaning;
          CLOSE c_group_type;

      -- Concatenate the meaning with the maximim enrollment limit and actual enrollment limit.
      -- The format should be like 'Cross Listed <BR> 10(5)'
      l_cat_enr_act := l_cross_meaning||'   '||l_max||'('||(NVL(to_char(l_act),'0'))||')';

          IF c_cross_listed%ISOPEN THEN
             CLOSE c_cross_listed;
          END IF;
          RETURN l_cat_enr_act;

    END IF;

     ELSE

       OPEN c_meet_with_cls(p_uoo_id);
       FETCH c_meet_with_cls INTO l_meet_with_cls_row ;

       IF c_meet_with_cls%FOUND THEN

         -- Get the maximum enrollment limit from the group level.
         IF l_meet_with_cls_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;

         ELSE
       l_usec_partof_group := TRUE;
           l_max := l_meet_with_cls_row.max_enr_group;

       -- Get the actual enrollment count of all the unit sections that belongs to
       -- the meet with class group.
           OPEN c_actual_enr_meet_cls(l_meet_with_cls_row.class_meet_group_id);
           FETCH c_actual_enr_meet_cls INTO l_act;
           CLOSE c_actual_enr_meet_cls;

       OPEN c_group_type('MEET_WITH');
           FETCH c_group_type INTO l_meet_meaning;
           CLOSE c_group_type;

       -- Concatenate the meaning with the maximim enrollment limit and actual enrollment limit.
       -- The format should be like 'Meet With <BR> 10(5)'
       l_cat_enr_act := l_meet_meaning||'   '||l_max||'('||(NVL(to_char(l_act),'0'))||')';

       IF c_meet_with_cls%ISOPEN THEN
              CLOSE c_meet_with_cls;
           END IF;
           RETURN l_cat_enr_act;
     END IF;

       ELSE
         l_usec_partof_group := FALSE;
       END IF;

       IF c_meet_with_cls%ISOPEN THEN
          CLOSE c_meet_with_cls;
       END IF;
     END IF;

     IF c_cross_listed%ISOPEN THEN
        CLOSE c_cross_listed;
     END IF;

     IF  l_usec_partof_group = FALSE THEN

      -- If the Unit Section passed doesn't belong to any of the group then
      -- check the maximum enrollment limit in the Unit Section level / Unit level.

      OPEN cur_usec_enr_max(p_uoo_id);
      FETCH cur_usec_enr_max INTO l_max;
      CLOSE cur_usec_enr_max;


      IF l_max IS NULL THEN
        -- Get the maximum enrollment limit from Unit level.
    OPEN cur_unit_enr_max(p_uoo_id);
    FETCH cur_unit_enr_max INTO l_max;
        CLOSE cur_unit_enr_max;
     END IF;

      -- get the actual enrollment limit.
      OPEN c_enroll_actual(p_uoo_id);
      FETCH c_enroll_actual INTO l_act;
      CLOSE c_enroll_actual;
      l_temp := l_max;
      l_cat_enr_act :=  NVL(l_temp,'-')||'('||(NVL(to_char(l_act),'0'))||')';
      RETURN l_cat_enr_act;

    END IF;
    RETURN l_cat_enr_act;

 END Enrp_Get_Enr_Max_Act;


FUNCTION Enrp_Chk_Usec_Group (
      p_uoo_id            igs_ps_unit_ofr_opt.uoo_id%TYPE
 )  RETURN VARCHAR2 IS

  ------------------------------------------------------------------------------------
  --Created by  : pradhakr
  --Date created: 30-Oct-2002
  --
  --Purpose:
  --
  --  This function returns the value of Y/N deponding upon whether the unit section
  --  belongs to any group and whether the maximum group limit is set or not . It is
  --  called from the view IGS_SS_EN_ENROLL_CART_RSLT_V. Added as part of Cross List /
  --  Meet With DLD. bug# 2599929
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------------------------
     p_return_status    VARCHAR2(1);
     p_group_type   igs_lookups_view.meaning%TYPE;
     p_group_name   igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE;

  -- Cursor to get the enrollment maximum in cross listed group
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grpmem.usec_x_listed_group_id
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;


  -- Cursor to get the enrollment maximum in Meet with class group
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, ucm.class_meet_group_id
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;


  l_usec_partof_group  BOOLEAN;
  l_cross_listed_row c_cross_listed%ROWTYPE;
  l_meet_with_cls_row c_meet_with_cls%ROWTYPE;

  BEGIN

    l_usec_partof_group := FALSE;

    OPEN c_cross_listed(p_uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row ;

    -- Check in Cross Listed group
    IF c_cross_listed%FOUND THEN

       IF l_cross_listed_row.max_enr_group IS NULL THEN
          l_usec_partof_group := FALSE;
       ELSE
          l_usec_partof_group := TRUE;
       END IF;

    ELSE

       OPEN c_meet_with_cls(p_uoo_id);
       FETCH c_meet_with_cls INTO l_meet_with_cls_row ;

       -- Check in Meet with class group
       IF c_meet_with_cls%FOUND THEN
          IF l_meet_with_cls_row.max_enr_group IS NULL THEN
             l_usec_partof_group := FALSE;
      ELSE
         l_usec_partof_group := TRUE;
      END IF;
       ELSE
          l_usec_partof_group := FALSE;
       END IF;

    END IF;

    IF c_meet_with_cls%ISOPEN THEN
       CLOSE c_meet_with_cls;
    END IF;

    IF c_cross_listed%ISOPEN THEN
       CLOSE c_cross_listed;
    END IF;

    IF l_usec_partof_group = TRUE THEN
       p_return_status := 'Y';
       RETURN p_return_status;
    ELSE
       p_return_status := 'N';
       RETURN p_return_status;
    END IF;

  END Enrp_Chk_Usec_Group;

FUNCTION get_core_disp_unit(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER )

  ------------------------------------------------------------------
  --Created by  : Parul Tandon, Oracle IDC
  --Date created: 06-OCT-2003
  --
  --Purpose: This Function checks whether the given unit section is
  --a core unit or not in the current pattern of study for the given
  --student program attempt.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

RETURN VARCHAR2
IS

--
--  Cursor to find the Unit Code
--
CURSOR cur_unit_cd (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT unit_cd, unit_class
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

--
--  Cursor to find the meaning of lookup code CORE
--
CURSOR cur_get_lkp_meaning IS
  SELECT meaning
  FROM   igs_lookup_values lkup,  IGS_EN_SS_DISP_STPS en
  WHERE  lkup.lookup_type = 'IGS_EN_CORE_IND'
  AND    lkup.lookup_code = en.core_req_ind;


l_unit_cd                igs_ps_unit_ofr_opt.unit_cd%TYPE;
l_unit_class                igs_ps_unit_ofr_opt.unit_class%TYPE;
l_core_meaning           igs_lookup_values.meaning%TYPE;

BEGIN
  -- Get the Unit Code
  OPEN cur_unit_cd(p_uoo_id);
  FETCH cur_unit_cd INTO l_unit_cd,l_unit_class;
  CLOSE cur_unit_cd;

  IF igs_en_gen_009.enrp_check_usec_core(p_person_id,p_program_cd,p_uoo_id) = 'CORE' THEN
     -- Get the meaning of lookup code
     OPEN cur_get_lkp_meaning;
     FETCH cur_get_lkp_meaning INTO l_core_meaning;
     CLOSE cur_get_lkp_meaning;

     RETURN l_unit_cd||'/'||l_unit_class||'('||l_core_meaning||')';
  ELSE
     RETURN l_unit_cd||'/'||l_unit_class;
  END IF;
END get_core_disp_unit;


PROCEDURE get_enr_cat_step(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_enr_cat_prc_step IN VARCHAR2,
  p_ret_status OUT NOCOPY VARCHAR2 ) AS
  ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose:This Function checks whether the given enrollment category step is defined in the system or not
  --it returns TRUE if the step is defined and FALSE whe the step is not defined.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

-- Cursor to check whether the given step is defined
  CURSOR c_enr_cat_prc_step (cp_enrolment_cat VARCHAR2,
                             cp_student_comm_type VARCHAR2,
                             cp_enr_method_type VARCHAR2,
                             cp_enrolment_step_type VARCHAR2) IS
  SELECT 'TRUE'
  FROM igs_en_cat_prc_step
  WHERE enrolment_cat = cp_enrolment_cat AND
  (s_student_comm_type = cp_student_comm_type OR
   s_student_comm_type = 'ALL' ) AND
  enr_method_type = cp_enr_method_type AND
  s_enrolment_step_type = cp_enrolment_step_type;

  l_enrollment_category         igs_en_cat_prc_step.enrolment_cat%TYPE;
  l_comm_type                   igs_en_cat_prc_step.s_student_comm_type%TYPE;
  l_enr_method_type             igs_en_cat_prc_step.enr_method_type%TYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  l_enrol_cal_type              igs_ca_type.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
  l_message                     VARCHAR2(300);
  l_ret_status                  VARCHAR2(30);
  l_dummy                       VARCHAR2(300);

BEGIN

    p_ret_status := 'FALSE';

    --  Get the superior academic calendar instance
    Igs_En_Gen_015.get_academic_cal
    (
     p_person_id               => p_person_id,
     p_course_cd               => p_program_cd,
     p_acad_cal_type           => l_acad_cal_type,
     p_acad_ci_sequence_number => l_acad_ci_sequence_number,
     p_message                 => l_message,
     p_effective_dt            => SYSDATE
    );
   -- Get the enrollment category and commencement type
   l_enrollment_category := Igs_En_Gen_003.enrp_get_enr_cat(
                                               p_person_id,
                                               p_program_cd,
                                               l_acad_cal_type,
                                               l_acad_ci_sequence_number,
                                               NULL,
                                               l_enrol_cal_type,
                                               l_enrol_sequence_number,
                                               l_comm_type,
                                               l_dummy);
   IF l_comm_type = 'BOTH' THEN
      l_comm_type :='ALL';
   END IF;

   -- Get the enrollment method type
   Igs_En_Gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_method_type,
       p_error_message   => l_message,
       p_ret_status      => l_ret_status);

  -- check whether the given step is defined or not
  OPEN c_enr_cat_prc_step (l_enrollment_category,l_comm_type,l_enr_method_type,p_enr_cat_prc_step);
  FETCH c_enr_cat_prc_step INTO p_ret_status;
  CLOSE c_enr_cat_prc_step;

END get_enr_cat_step;

FUNCTION get_stud_yop_unit_set(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_term_cal_type IN VARCHAR2,
  p_term_sequence_number IN NUMBER)
RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose: This function will return the current unit set title for the given student program attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --rvangala  09-Dec-2003  Changed logic to consider multiple census terms,
  --                       if the term has more than one census date defined
  -------------------------------------------------------------------

  -- cursor to fetch the unit set title
  CURSOR c_us_title (cp_person_id NUMBER,cp_program_cd VARCHAR2,cp_term_census_date DATE) IS
    SELECT us.title
    FROM  igs_as_su_setatmpt susa ,
          igs_en_unit_set us ,
          igs_en_unit_set_cat usc
    WHERE susa.person_id =  cp_person_id
    AND   susa.course_cd = cp_program_cd
    AND   susa.student_confirmed_ind = 'Y'
    AND  cp_term_census_date
         BETWEEN susa.selection_dt
         AND   NVL(susa.rqrmnts_complete_dt,NVL(susa.end_dt, cp_term_census_date))
    AND   susa.unit_set_cd = us.unit_set_cd
    AND   us.unit_set_cat = usc.unit_set_cat
    AND   usc.s_unit_set_cat  = 'PRENRL_YR'
    ORDER BY susa.selection_dt DESC;

   -- cursor to fetch census date values
   CURSOR c_term_cen_dates (cp_cal_type IN VARCHAR2, cp_cal_seq_number IN NUMBER) IS
       SELECT   NVL (absolute_val,
                  igs_ca_gen_001.calp_get_alias_val (
                  dai.dt_alias,
                  dai.sequence_number,
                  dai.cal_type,
                  dai.ci_sequence_number
                      )
        ) AS term_census_date
        FROM     igs_ge_s_gen_cal_con sgcc,
                 igs_ca_da_inst dai
        WHERE    sgcc.s_control_num = 1
        AND      dai.dt_alias = sgcc.census_dt_alias
        AND      dai.cal_type = cp_cal_type
        AND      dai.ci_sequence_number = cp_cal_seq_number
        ORDER by 1 desc;

 l_us_title igs_en_unit_set.title%TYPE;
BEGIN
  -- Check whether the pre-enrollment YOP profile is set to Y
  IF fnd_profile.value('IGS_PS_PRENRL_YEAR_IND') = 'Y' THEN

    -- loop through the census dates for given term cal type and sequence number
    FOR l_rec_cen_dates IN c_term_cen_dates(p_term_cal_type,
                                            p_term_sequence_number) LOOP

        -- fetch unit set title for most recent unit set attempt
        OPEN c_us_title(p_person_id,p_program_cd,l_rec_cen_dates.term_census_date);
        FETCH c_us_title INTO l_us_title;

        -- if unit set title for most recent unit set attempt exists
        -- exit and return title
        IF c_us_title%FOUND THEN
            CLOSE c_us_title;
            EXIT;
        END IF;

        CLOSE c_us_title;

    END LOOP;

    RETURN l_us_title;

  ELSE
    -- return NULL as pre-enrollment YOP profile is not set or set to N
    RETURN NULL;
  END IF;

END get_stud_yop_unit_set;


FUNCTION get_pri_prg_title(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_term_cal_type IN VARCHAR2,
  p_term_sequence_number IN NUMBER)
RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose: This Function returns the title of the given program or given primary program
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- get the program title
  CURSOR c_prg_title (cp_person_id NUMBER,cp_program_cd VARCHAR2,cp_term_cal VARCHAR2,cp_term_seq_num NUMBER) IS
     SELECT pv.title
     FROM igs_en_stdnt_ps_att_all sca,
          igs_ps_ver_all pv
     WHERE pv.course_cd = sca.course_cd
     AND   pv.version_number = sca.version_number
     AND   sca.course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT')
     AND   sca.person_id = cp_person_id
     AND   sca.course_cd = cp_program_cd
     AND   ((igs_en_spa_terms_api.get_spat_primary_prg(cp_person_id,cp_program_cd,cp_term_cal,cp_term_seq_num) = 'PRIMARY') OR
            (NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N')= 'N')
           );

  l_prg_title igs_ps_ver_all.title%TYPE;

BEGIN

  OPEN  c_prg_title(p_person_id,p_program_cd,p_term_cal_type,p_term_sequence_number);
  FETCH c_prg_title INTO l_prg_title;
  CLOSE c_prg_title;

  RETURN l_prg_title;

END get_pri_prg_title;

FUNCTION get_sec_prg_title(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_program_version IN NUMBER,
  p_term_cal_type IN VARCHAR2,
  p_term_sequence_number IN NUMBER)
RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose: This Function returns return the concatenated titles of
  --  all the secondary programs in the same career of the given program
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- get the program title
  CURSOR c_sec_prg_title (cp_person_id NUMBER,cp_program_cd VARCHAR2,cp_version_number NUMBER,
                          cp_term_cal VARCHAR2,cp_term_seq_num NUMBER) IS
    SELECT pv.title
     FROM igs_en_stdnt_ps_att_all sca,
          igs_ps_ver_all pv
     WHERE pv.course_cd = sca.course_cd
     AND pv.version_number = sca.version_number
     AND sca.course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT')
     AND sca.person_id = cp_person_id
     AND igs_en_spa_terms_api.get_spat_primary_prg(cp_person_id,cp_program_cd,cp_term_cal,cp_term_seq_num) <> 'PRIMARY'
     AND pv.course_type = (SELECT course_type
                           FROM igs_ps_ver_all
                           WHERE course_cd = cp_program_cd
                           AND version_number = cp_version_number);

  l_sec_prg_title VARCHAR2(2000);

BEGIN

  IF fnd_profile.value('CAREER_MODEL_ENABLED') = 'Y' THEN

     FOR l_sec_prg_rec IN c_sec_prg_title(p_person_id,p_program_cd,p_program_version,p_term_cal_type,p_term_sequence_number) LOOP
       l_sec_prg_title := l_sec_prg_title ||', '||l_sec_prg_rec.title;
     END LOOP;

     RETURN ' '||SUBSTR(l_sec_prg_title,3);
  ELSE
    RETURN NULL;
  END IF;

END get_sec_prg_title;
FUNCTION enrf_is_sup_Sub(
p_uoo_id            IN NUMBER
)
------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 29-OCT-2003
  --
  --Purpose: This Function checks whether the given unit section is
  --a superior, subordinate or none as part of placements build #3052438.
  --If subordiante , it returns the superior unit section
  --if superior , it returns the passed uoo-id
  --else it returns null
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

RETURN VARCHAR2 IS

CURSOR chk_rel IS
SELECT relation_type ,sup_uoo_Id
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = p_uoo_id;

l_rel_type igs_ps_unit_ofr_opt.relation_type%TYPE;
l_sup_uoo_id igs_ps_unit_ofr_opt.sup_uoo_id%TYPE;

BEGIN
   OPEN chk_rel;
   FETCH chk_rel INTO l_rel_type, l_sup_uoo_id;
   CLOSE chk_rel;

   IF nvl(l_rel_type,'NONE') = 'NONE' THEN
      RETURN NULL;
   ELSIF l_rel_type = 'SUBORDINATE' THEN
      RETURN l_sup_uoo_id;
   ELSIF l_rel_type = 'SUPERIOR' THEN
      RETURN p_uoo_Id;
  END IF;
 END enrf_is_sup_Sub;

FUNCTION GET_SUP_SUB_UOO_IDS (
  p_uoo_id IN NUMBER,
  p_relation_type IN VARCHAR2,
  p_sup_uoo_id IN NUMBER
)
------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 29-OCT-2003
  --
  --Purpose: This Function returns a string of conctenated subordinate uoo_ids
  --if the parameter p_uoo_Id is superior , if it is subordinate
  --it returns p_sup_uoo_id else it returns null
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

RETURN VARCHAR2 AS

  recordexists BOOLEAN;
  ret_value    VARCHAR2 (2000);

  CURSOR c_sub_uoo_ids IS
  SELECT uoo_id
  FROM igs_ps_unit_ofr_opt
  WHERE sup_uoo_id = p_uoo_id;

BEGIN

  IF NVL (p_relation_type,'NONE') = 'SUPERIOR' THEN
     ret_value := NULL;
    FOR v_sub_uoo_ids IN c_sub_uoo_ids LOOP
       IF ret_value IS NULL THEN
          ret_value := TO_CHAR(v_sub_uoo_ids.uoo_id);
       ELSE
          ret_value := ret_value || ','||TO_CHAR(v_sub_uoo_ids.uoo_id);
      END IF;
    END LOOP;
  ELSIF NVL (p_relation_type,'NONE') = 'SUBORDINATE' THEN
   ret_value := p_sup_uoo_id;
  END IF;
   RETURN ret_value;
END get_sup_sub_uoo_ids;

  FUNCTION GET_SUP_SUB_DETAILS (
    p_uoo_id IN NUMBER,
    p_sup_uoo_id IN NUMBER,
    p_relation_type IN VARCHAR2
  )  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 29-OCT-2003
  --
  --Purpose: This Function returns teh relation type of the unit section.
  --if the parameter p_uoo_Id is superior , it returns 'SUPERIOR'
  --if subordiante it returns 'SBORDINATE' concatenated to the superior unit code
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR c_lkups (CP_LOOKUP_CODE IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE) IS
    SELECT meaning
    FROM igs_lookup_values
    WHERE lookup_code = cp_lookup_code
    AND lookup_type = 'UOO_RELATION_TYPE';

  CURSOR c_sup_unit_cd (CP_SUP_UOO_ID IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
    SELECT unit_cd
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = cp_sup_uoo_id;

  v_sup_unit_cd IGS_PS_UNIT_VER.UNIT_CD%TYPE;
  l_meaning IGS_LOOKUPS_VIEW.MEANING%TYPE;

  BEGIN

    IF NVL(p_relation_type,'NONE') = 'NONE' THEN
      RETURN NULL;
    END IF;

    OPEN c_lkups(p_relation_type);
    FETCH c_lkups INTO l_meaning;
    CLOSE c_lkups;

    IF p_relation_type = 'SUPERIOR' THEN
      RETURN '<BR>('||l_meaning||')';
    ELSIF p_relation_type = 'SUBORDINATE' THEN

      IF p_sup_uoo_id IS NOT NULL THEN
        OPEN c_sup_unit_cd(p_sup_uoo_id);
        FETCH c_sup_unit_cd INTO v_sup_unit_cd;
        IF c_sup_unit_cd%FOUND THEN
          CLOSE c_sup_unit_cd;
          RETURN '<BR>('|| FND_MESSAGE.GET_STRING('IGS','IGS_EN_SUBORDINATE_TO') || ' ' || v_sup_unit_cd||')';
        ELSE
          CLOSE c_sup_unit_cd;
          RETURN NULL;
        END IF;
      ELSE
        RETURN NULL;
      END IF;
    END IF;

  END get_sup_sub_details;

  -- Procedure to get the level at which notes is defined for give unit section.
  -- Procedure retuns the following values in the out variable p_c_dfn_lvl.
  -- 'UNIT_SECTION' - when the notes are defined at unit section level.
  -- 'UNIT_OFFERING_PATTERN' - when the notes are defined at unit offering pattern level.
  -- 'UNIT_OFFERING' - when the notes are defined at unit offering level.
  -- 'UNIT_VERSION' - when the notes are defined at unit version level.
  -- 'NOTES_UN_DEFINED' - when the notes are not defined at any of the above levels.
  PROCEDURE get_notes_defn_lvl (
                                 p_n_uoo_id IN NUMBER,
                                 p_c_dfn_lvl OUT NOCOPY VARCHAR2) IS
    CURSOR c_usec (cp_n_uoo_id IN NUMBER) IS
      SELECT 1
      FROM   IGS_PS_UNT_OFR_OPT_N USEC
      WHERE  USEC.UOO_ID = cp_n_uoo_id
      AND    ROWNUM < 2 ;

    CURSOR c_uop (cp_n_uoo_id IN NUMBER) IS
      SELECT 1
      FROM   IGS_PS_UNT_OFR_PAT_N UOP,
             IGS_PS_UNIT_OFR_OPT_ALL UOO
      WHERE  UOO.UNIT_CD = UOP.UNIT_CD
        AND  UOO.VERSION_NUMBER = UOP.VERSION_NUMBER
        AND  UOO.CAL_TYPE = UOP.CAL_TYPE
        AND  UOO.CI_SEQUENCE_NUMBER = UOP.CI_SEQUENCE_NUMBER
        AND  UOO.UOO_ID = cp_n_uoo_id
        AND  ROWNUM < 2;

    CURSOR c_uo (cp_n_uoo_id IN NUMBER) IS
      SELECT 1
      FROM   IGS_PS_UNIT_OFR_NOTE UO,
             IGS_PS_UNIT_OFR_OPT_ALL UOO
      WHERE  UOO.UNIT_CD = UO.UNIT_CD
        AND  UOO.VERSION_NUMBER = UO.VERSION_NUMBER
        AND  UOO.CAL_TYPE = UO.CAL_TYPE
        AND  UOO.UOO_ID = cp_n_uoo_id
        AND  ROWNUM < 2;

    CURSOR c_uv (cp_n_uoo_id IN NUMBER) IS
      SELECT 1
      FROM   IGS_PS_UNIT_VER_NOTE UV,
             IGS_PS_UNIT_OFR_OPT_ALL UOO
      WHERE  UOO.UNIT_CD = UV.UNIT_CD
        AND  UOO.VERSION_NUMBER = UV.VERSION_NUMBER
        AND  UOO.UOO_ID = cp_n_uoo_id
        AND  ROWNUM < 2;

    l_n_temp NUMBER;

  BEGIN
    OPEN c_usec (p_n_uoo_id);
    FETCH c_usec INTO l_n_temp;
    IF c_usec%FOUND THEN
       CLOSE c_usec;
       p_c_dfn_lvl := 'UNIT_SECTION';
    ELSE
      CLOSE c_usec;
      OPEN c_uop(p_n_uoo_id);
      FETCH c_uop INTO l_n_temp;
      IF c_uop%FOUND THEN
         CLOSE c_uop;
         p_c_dfn_lvl := 'UNIT_OFFERING_PATTERN';
      ELSE
         CLOSE c_uop;
         OPEN c_uo(p_n_uoo_id);
         FETCH c_uo INTO l_n_temp;
         IF c_uo%FOUND THEN
            CLOSE c_uo;
            p_c_dfn_lvl := 'UNIT_OFFERING';
         ELSE
            CLOSE c_uo;
            OPEN c_uv(p_n_uoo_id);
            FETCH c_uv INTO l_n_temp;
            IF c_uv%FOUND THEN
               CLOSE c_uv;
               p_c_dfn_lvl := 'UNIT_VERSION';
            ELSE
               CLOSE c_uv;
               p_c_dfn_lvl := 'NOTES_UN_DEFINED';
            END IF;
         END IF;
      END IF;
    END IF;
  END get_notes_defn_lvl;

FUNCTION GET_DUP_SUA_SELECTION (
    p_person_id IN NUMBER,
    p_src_course_cd IN VARCHAR2,
    p_dest_course_cd IN VARCHAR2,
    p_uoo_id IN NUMBER
    )  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 23-Dec-2004
  --
  --Purpose: This Function returns 'Y' if a duplicate unit attempt
  --in the source program can be unchecked in the Program Transfer Page.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --Somasekar   17th feb 2006	Bug # 5026874
  -------------------------------------------------------------------
-- Get the details of
Cursor uoo_attempt_status (
     cp_person_id IN NUMBER ,
     cp_course_cd IN VARCHAR2,
     cp_uoo_id NUMBER) IS
SELECT unit_attempt_status
FROM igs_en_su_Attempt
WHERE person_id = cp_person_id
AND course_cd = cp_course_cd
AND uoo_id = cp_uoo_id;

l_src_status  VARCHAR2(20);
l_dest_status  VARCHAR2(20);

BEGIN
 OPEN uoo_attempt_status(p_person_id, p_src_course_cd, p_uoo_id);
 FETCH uoo_attempt_status INTO l_src_status;
 CLOSE uoo_attempt_status;

IF l_src_status = 'COMPLETED' OR l_src_status = 'DISCONTIN' THEN

        --chk if unit exists in destination with duplicate status for corresponding completed unit in source
        OPEN uoo_attempt_status(p_person_id, p_dest_course_cd, p_uoo_id);
        FETCH uoo_attempt_status INTO l_dest_status;

        CLOSE uoo_attempt_status;
        IF l_dest_status IS NOT NULL AND l_dest_status = 'DUPLICATE' THEN

        --completed unit can be unchecked in the page
                RETURN 'N';
        END IF;

        RETURN 'Y';
END IF;

IF l_src_status = 'DUPLICATE' THEN

        --chk if unit exists in destination
        OPEN uoo_attempt_status(p_person_id, p_dest_course_cd, p_uoo_id);
        FETCH uoo_attempt_status INTO l_dest_status;
        CLOSE uoo_attempt_status;

        IF l_dest_status IS NOT NULL THEN
        --unit can be unchecked in the page
                RETURN 'N';
        END IF;

        RETURN 'Y';
END IF;

RETURN 'Y';

END get_dup_sua_selection;

FUNCTION get_title_for_unit(p_unit_cd IN VARCHAR2, p_version IN NUMBER) RETURN VARCHAR2
IS
  Cursor cur_title(cp_unit_cd VARCHAR2, cp_version NUMBER) IS
   Select title from igs_ps_unit_ver
    where unit_cd=cp_unit_cd
    and version_number=cp_version;

  l_title igs_ps_unit_ver.title%TYPE;
BEGIN
  OPEN cur_title(p_unit_cd,p_version);
  FETCH cur_title INTO l_title;
  CLOSE cur_title;

  RETURN l_title;

END get_title_for_unit;

FUNCTION get_max_waitlist_for_unit(p_uoo_id IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER,
                  p_cal_type IN VARCHAR2, p_sequence_number IN NUMBER,
                  p_owner_org_unit_cd IN VARCHAR2) RETURN NUMBER
IS

  Cursor c_check(cp_uoo_id NUMBER) IS
    select max_students_per_waitlist
    from igs_ps_usec_lim_wlst
    where uoo_id=cp_uoo_id;

  Cursor c_check2(cp_unit_cd VARCHAR2, cp_version NUMBER,
                  cp_cal_type VARCHAR2, cp_sequence_number NUMBER) IS
   select max_students_per_waitlist
   from igs_ps_unit_ofr_pat
   where unit_cd=cp_unit_cd
        and version_number=cp_version
        and cal_type=cp_cal_type
        and ci_sequence_number=cp_sequence_number
        and delete_flag = 'N';

      l_result igs_en_or_unit_wlst.max_stud_per_wlst%TYPE DEFAULT NULL;
BEGIN
   OPEN c_check(p_uoo_id);
   FETCH c_check INTO l_result;
   CLOSE c_check;

   IF l_result IS NOT NULL THEN
     RETURN l_result;
   END IF;

   OPEN c_check2(p_unit_cd,p_version,p_cal_type,p_sequence_number);
   FETCH c_check2 INTO l_result;
   CLOSE c_check2;

   IF l_result IS NOT NULL THEN
     RETURN l_result;
   END IF;

   RETURN get_max_std_wait_org_level(
                           p_owner_org_unit_cd ,
                           p_cal_type ,
                           p_sequence_number);

END get_max_waitlist_for_unit;


FUNCTION get_enroll_max_for_unit(p_uooid IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER) RETURN NUMBER
IS
   Cursor c_check1(cp_uooid NUMBER) IS
    select enrollment_maximum
    from igs_ps_usec_lim_wlst
    where uoo_id=cp_uooid;

   Cursor c_check2(cp_unit_cd VARCHAR2,
                   cp_version NUMBER) IS
    select enrollment_maximum
    from igs_ps_unit_ver
    where unit_cd=cp_unit_cd
    and version_number=cp_version;

    l_result igs_ps_usec_lim_wlst.enrollment_maximum%TYPE DEFAULT NULL;
BEGIN
    OPEN c_check1(p_uooid);
    FETCH c_check1 INTO l_result;
    CLOSE c_check1;

    IF l_result IS NOT NULL THEN
      return l_result;
    END IF;

    OPEN c_check2(p_unit_cd,p_version);
    FETCH c_check2 INTO l_result;
    CLOSE c_check2;

    RETURN l_result;

END get_enroll_max_for_unit;


FUNCTION get_enroll_min_for_unit(p_uooid IN NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER) RETURN NUMBER
IS
   Cursor c_check1(cp_uooid NUMBER) IS
    select enrollment_minimum
    from igs_ps_usec_lim_wlst
    where uoo_id=cp_uooid;

   Cursor c_check2(cp_unit_cd VARCHAR2,
                   cp_version NUMBER) IS
    select enrollment_minimum
    from igs_ps_unit_ver
    where unit_cd=cp_unit_cd
    and version_number=cp_version;

    l_result igs_ps_usec_lim_wlst.enrollment_minimum%TYPE DEFAULT NULL;
BEGIN
    OPEN c_check1(p_uooid);
    FETCH c_check1 INTO l_result;
    CLOSE c_check1;

    IF l_result IS NOT NULL THEN
      return l_result;
    END IF;

    OPEN c_check2(p_unit_cd,p_version);
    FETCH c_check2 INTO l_result;
    CLOSE c_check2;

    RETURN l_result;

END get_enroll_min_for_unit;



-- Function to get alias value for the given calendar instance and date alias.
FUNCTION get_alias_val (p_c_cal_type IN VARCHAR2,
                           p_n_seq_num  IN NUMBER,
                           p_c_dt_alias IN VARCHAR2) RETURN DATE IS

------------------------------------------------------------------
  --Created by  : Somasekar, Oracle IDC
  --Date created: 17-May-2005
  --
  --Purpose: Function to get alias value for the given
  --                                calendar instance and date alias
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------

CURSOR c_alias_val (cp_c_cal_type IN VARCHAR2,
                    cp_n_seq_num  IN NUMBER,
                    cp_c_dt_alias IN VARCHAR2) IS
       SELECT alias_val
       FROM   igs_ca_da_inst_v
       WHERE  cal_type = cp_c_cal_type
       AND    ci_sequence_number = cp_n_seq_num
       AND    dt_alias = cp_c_dt_alias
       ORDER BY alias_val DESC;

       l_d_alias_val igs_ca_da_inst_v.alias_val%TYPE;

BEGIN
    OPEN c_alias_val(p_c_cal_type, p_n_seq_num, p_c_dt_alias);
    FETCH c_alias_val INTO l_d_alias_val;
    CLOSE c_alias_val;
   RETURN l_d_alias_val;
END get_alias_val;


-- Function to check whether timeslot is open or close for a student
-- returns true if the timeslot is open otherwise false
FUNCTION stu_timeslot_open (p_n_person_id IN NUMBER,
                               p_c_person_type IN VARCHAR2,
                               p_c_program_cd  IN VARCHAR2,
                               p_c_cal_type    IN VARCHAR2,
                               p_n_seq_num     IN NUMBER) RETURN BOOLEAN IS
------------------------------------------------------------------
  --Created by  : Somasekar, Oracle IDC
  --Date created: 17-May-2005
  --
  --Purpose: Function to check whether timeslot is open or close for a student
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------

     l_c_msg VARCHAR2(2000);
     l_c_ret_sts VARCHAR2(10);
     l_c_en_meth_type igs_en_method_type.enr_method_type%TYPE;
     l_c_en_cal igs_ca_inst.cal_type%type;
     l_n_en_seq igs_ca_inst.sequence_number%type;
     l_c_en_com igs_en_cat_prc_dtl.S_STUDENT_COMM_TYPE%TYPE;
     l_c_acad_cal igs_ca_inst.cal_type%type;
     l_n_acad_seq igs_ca_inst.sequence_number%type;
     l_d_acad_st_dt igs_ca_inst.start_dt%type;
     l_d_acad_ed_dt igs_ca_inst.end_dt%type;
     l_c_alternate_cd igs_ca_inst.alternate_code%type;
     l_c_en_cat igs_en_enrolment_cat.enrolment_cat%TYPE;
     l_c_en_ctgs VARCHAR2(200);
     l_c_notify_flag       igs_en_cpd_ext.notification_flag%TYPE;
     l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
     l_step_override      BOOLEAN := FALSE;
     lv_timeslot_rec_found      BOOLEAN := FALSE;

     CURSOR c_stud_timeslot (cp_cal_type     igs_en_timeslot_para.cal_type%TYPE,
                             cp_sequence_number   igs_en_timeslot_para.sequence_number%TYPE) IS
             SELECT tr.start_dt_time,
                    tr.end_dt_time
             FROM   igs_en_timeslot_rslt tr,
                    igs_en_timeslot_para tp
             WHERE  tr.person_id = p_n_person_id
             AND    tr.igs_en_timeslot_para_id = tp.igs_en_timeslot_para_id
             AND    tp.cal_type = cp_cal_type
             AND    tp.sequence_number = cp_sequence_number;
      rec_stud_timeslot    c_stud_timeslot%ROWTYPE;

 BEGIN
    -- Call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
   igs_en_gen_017.enrp_get_enr_method(
        p_enr_method_type => l_c_en_meth_type,
        p_error_message   => l_c_msg,
        p_ret_status      => l_c_ret_sts);

    -- get the enrollment method message
  IF l_c_msg IS NOT NULL THEN
     RETURN FALSE;
  END IF;

    -- get the academic calendar of the given Load Calendar
  l_c_alternate_cd := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                               p_cal_type                => p_c_cal_type,
                               p_ci_sequence_number      => p_n_seq_num,
                               p_acad_cal_type           => l_c_acad_cal,
                               p_acad_ci_sequence_number => l_n_acad_seq,
                               p_acad_ci_start_dt        => l_d_acad_st_dt,
                               p_acad_ci_end_dt          => l_d_acad_ed_dt,
                               p_message_name            => l_c_msg );

   -- get the academic method message
  IF l_c_msg IS NOT NULL THEN
     RETURN FALSE;
  END IF;

    -- get the enrollment category for the given calendar.
  l_c_en_cat := igs_en_gen_003.enrp_get_enr_cat(
                             p_n_person_id,
                             p_c_program_cd,
                             l_c_acad_cal,
                             l_n_acad_seq,
                             NULL,
                             l_c_en_cal,
                             l_n_en_seq,
                             l_c_en_com,
                             l_c_en_ctgs);

  IF l_c_en_com = 'BOTH' THEN
     l_c_en_com :='ALL';
  END IF;

  l_c_notify_flag  := igs_ss_enr_details.get_notification(
                                          p_person_type            => p_c_person_type,
                                          p_enrollment_category    => l_c_en_cat,
                                          p_comm_type              => l_c_en_com,
                                          p_enr_method_type        => l_c_en_meth_type,
                                          p_step_group_type        => 'PERSON',
                                          p_step_type              => 'CHK_TIME_PER',
                                          p_person_id              => p_n_person_id,
                                          p_message                => l_c_msg
                                          ) ;

   -- get the notification method message
  IF l_c_msg IS NOT NULL THEN
    RETURN FALSE;
  END IF;
  -- if the step is not defined then notification flag will be null
  -- if the step is configured as 'Warn' then returns WARN.
  -- Either is step is not defined or configured as warn then no need to evaluate the step at all.
  IF NVL(l_c_notify_flag,'WARN')   ='WARN' Then
   RETURN TRUE;
  ELSE
   -- check the step is overridden for the given load calendar/teaching period or not
    l_step_override := igs_en_gen_015.validation_step_is_overridden(
     p_eligibility_step_type        => 'CHK_TIME_PER',
     p_load_cal_type                => p_c_cal_type    ,
     p_load_cal_seq_number => p_n_seq_num     ,
     p_person_id                    => p_N_person_id,
     p_uoo_id                       => NULL,
     p_step_override_limit          => l_step_override_limit                            );

    IF l_step_override THEN
      RETURN TRUE;
    END IF;
    -- now fetch the timeslot based on the obtained cal_type and seq number and if the values are null
    -- pass p_load_calendar_type and p_load_cal_sequence_number

     lv_timeslot_rec_found := FALSE;
     FOR rec_stud_timeslot IN c_stud_timeslot (p_c_cal_type,   p_n_seq_num )
      LOOP
         -- Timeslot record found
         lv_timeslot_rec_found := TRUE;
              IF (SYSDATE >=  rec_stud_timeslot.start_dt_time) OR  (rec_stud_timeslot.start_dt_time IS NULL ) THEN
           --Student is eligible
               RETURN TRUE;
          END IF;
      END LOOP;

  IF NOT lv_timeslot_rec_found THEN
   -- No Timeslot records defined/alloted for the Student
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

 END IF;

END stu_timeslot_open;


  FUNCTION get_tba_desc RETURN VARCHAR2 IS
  BEGIN
   RETURN g_tba_desc;
  END get_tba_desc;


 FUNCTION get_nsd_desc RETURN VARCHAR2 IS
  BEGIN
    RETURN g_nsd_desc;
  END get_nsd_desc;

 FUNCTION get_uso_instructors(p_n_uso_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR c_instr (cp_n_occurs_id IN NUMBER) IS
        SELECT pe.last_name || ', ' || pe.first_name || ' ' || pe.middle_name name
        FROM igs_ps_uso_instrctrs instr,
             igs_pe_person_base_v pe
        WHERE instr.unit_section_occurrence_id = cp_n_occurs_id AND
              instr.instructor_id = pe.person_id;
    l_c_instr VARCHAR2(32000);
    l_b_found boolean;
  BEGIN
    l_b_found := false;
    FOR rec_instr IN c_instr(p_n_uso_id)
    LOOP
       l_b_found := true;
       l_c_instr := l_c_instr || rec_instr.name  || '; ';
    END LOOP;
    IF l_b_found THEN
       l_c_instr := substr(l_c_instr,0,length(l_c_instr) -2);
    END IF;
    return l_c_instr;
  END get_uso_instructors;


 FUNCTION get_none_desc RETURN VARCHAR2 IS
  BEGIN
    RETURN get_meaning ('CALL_NUMBER','NONE');
 END get_none_desc;


FUNCTION get_meeting_pattern(p_n_uoo_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the meeting pattern for a unit section
  --         to display in self service
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
     --Cursor to get all the occurrences of given unit section.
     CURSOR c_uso_dtls (cp_n_uoo_id IN NUMBER) IS
     SELECT
            TO_CHAR(NVL(NVL(USO.START_DATE,US.UNIT_SECTION_START_DATE),CA.START_DT),'DD MON YYYY') || ' - ' ||
            TO_CHAR(NVL(NVL(USO.END_DATE,US.UNIT_SECTION_END_DATE),CA.END_DT),'DD MON YYYY') effective_date,
            uso.building_code,
            uso.room_code,
            uso.to_be_announced,
            uso.no_set_day_ind,
            NVL(
              DECODE(uso.monday,  'Y',  'M',  NULL)    ||
            DECODE(uso.tuesday,  'Y',  'Tu',  NULL)  ||
            DECODE(uso.wednesday,  'Y',  'W',  NULL) ||
            DECODE(uso.thursday,  'Y',  'Th',  NULL) ||
            DECODE(uso.friday,  'Y',  'F',  NULL)    ||
            DECODE(uso.saturday,  'Y',  'Sa',  NULL) ||
              DECODE(uso.sunday,  'Y',  'Su',  NULL),'TBA') meetings,
            TO_CHAR(uso.start_time,'hh:miam') start_time,
            TO_CHAR(uso.end_time, 'hh:miam') end_time
     FROM   igs_ps_usec_occurs_all USO,
            igs_ps_unit_ofr_opt_all US,
            igs_ca_inst_all CA
     WHERE  uso.uoo_id = cp_n_uoo_id AND
            uso.uoo_id = us.uoo_id AND
            us.cal_type = ca.cal_type AND
            us.ci_sequence_number = ca.sequence_number
     ORDER BY uso.unit_section_occurrence_id;

     l_c_meet_info VARCHAR2(32000);

   -- Internal function to get the building code for the given building identifier
    FUNCTION get_building_code(p_n_building_id IN NUMBER)  RETURN VARCHAR2 IS
       CURSOR c_building_code (cp_n_building_id IN NUMBER) IS
        SELECT building_cd
        FROM   igs_ad_building_all
        WHERE  building_id = cp_n_building_id;
        l_c_building_cd igs_ad_building_all.building_cd%TYPE;
    BEGIN
       OPEN c_building_code (p_n_building_id );
       FETCH c_building_code INTO l_c_building_cd;
       CLOSE c_building_code;
       RETURN l_c_building_cd;
    END get_building_code;

  -- Internal function to get the room code for the given room identifier
    FUNCTION get_room_code(p_n_room_id IN NUMBER)  RETURN VARCHAR2 IS
       CURSOR c_room_code  (cp_n_room_id IN NUMBER) IS
        SELECT room_cd
        FROM   igs_ad_room_all
        WHERE  room_id = cp_n_room_id;
        l_c_room_cd igs_ad_room_all.room_cd%TYPE;
    BEGIN
       OPEN c_room_code (p_n_room_id );
       FETCH c_room_code INTO l_c_room_cd;
       CLOSE c_room_code;
       RETURN l_c_room_cd;
    END get_room_code;

    -- function to display dummy data
    -- Called when the unit section does not have occurrences then need to display meeting information
    -- as if an to be announced occurrence exists.
    FUNCTION get_dummy_data(p_n_uoo_id IN NUMBER) RETURN VARCHAR2 IS
      CURSOR c_uoo(cp_n_uoo_id IN NUMBER) IS
        SELECT NVL(us.unit_section_start_date,ca.start_dt) start_date,
               NVL(us.unit_section_end_date, ca.end_dt) end_date
        FROM igs_ps_unit_ofr_opt_all us,
             igs_ca_inst_all ca
        WHERE us.uoo_id = cp_n_uoo_id AND
              us.cal_type = ca.cal_type AND
              us.ci_sequence_number = ca.sequence_number;

      rec_uoo c_uoo%ROWTYPE;

    BEGIN
       OPEN c_uoo(p_n_uoo_id);
       FETCH c_uoo INTO rec_uoo;
       CLOSE c_uoo;
       return rec_uoo.start_date ||' - ' || rec_uoo.end_date || '; ' || g_tba_desc ;
    END get_dummy_data;


  BEGIN
    -- loop through the unit section occurrences
    FOR rec_uso_dtls IN c_uso_dtls(p_n_uoo_id)
    LOOP
        l_c_meet_info := l_c_meet_info || rec_uso_dtls.effective_date || '; ';
        IF rec_uso_dtls.to_be_announced = 'Y' THEN
             l_c_meet_info := l_c_meet_info || g_tba_desc;
        ELSIF rec_uso_dtls.no_set_day_ind = 'Y' THEN
             l_c_meet_info := l_c_meet_info || g_nsd_desc;
        ELSE
             IF rec_uso_dtls.building_code IS NOT NULL THEN
                  l_c_meet_info := l_c_meet_info || get_building_code(rec_uso_dtls.building_code) || '; ';
             ELSE
                  l_c_meet_info := l_c_meet_info || 'TBA' || '; ';
             END IF;
             IF rec_uso_dtls.room_code IS NOT NULL THEN
                  l_c_meet_info := l_c_meet_info || get_room_code(rec_uso_dtls.room_code) || '; ';
             ELSE
                  l_c_meet_info := l_c_meet_info || 'TBA' || '; ';
             END IF;
            l_c_meet_info := l_c_meet_info || rec_uso_dtls.meetings || '; '
                                         || rec_uso_dtls.start_time || ' - ' || rec_uso_dtls.end_time;
        END IF;
        l_c_meet_info := l_c_meet_info || ' <BR> ' ;
    END LOOP;

    IF l_c_meet_info IS NULL THEN
        l_c_meet_info := get_dummy_data(p_n_uoo_id);
    ELSE
        l_c_meet_info := substr(l_c_meet_info,0,length(l_c_meet_info) -6);
    END IF;
    RETURN l_c_meet_info;

  END get_meeting_pattern;



  FUNCTION get_usec_instructors(p_n_uoo_id IN NUMBER) RETURN VARCHAR2 AS
    CURSOR c_uso (cp_n_uoo_id IN NUMBER) IS
      SELECT unit_section_occurrence_id
      FROM igs_ps_usec_occurs_all
      WHERE uoo_id = cp_n_uoo_id
      ORDER BY unit_section_occurrence_id;
    CURSOR c_instr (cp_n_occurs_id IN NUMBER) IS
      SELECT pe.last_name || ', ' || pe.first_name || ' ' || pe.middle_name name
      FROM igs_ps_uso_instrctrs instr,
           igs_pe_person_base_v pe
      WHERE instr.unit_section_occurrence_id = cp_n_occurs_id AND
            instr.uso_instructor_id = pe.person_id;
    l_c_instr VARCHAR2(32000);
    l_c_uso_instr VARCHAR2(32000);
  BEGIN
    FOR rec_uso IN c_uso(p_n_uoo_id)
    LOOP
      l_c_uso_instr := NULL;
      l_c_uso_instr := get_uso_instructors(rec_uso.unit_section_occurrence_id);
      l_c_instr := l_c_instr || l_c_uso_instr || ' <BR> ' ;
    END LOOP;
    IF l_c_instr IS NOT NULL THEN
       l_c_instr := substr(l_c_instr,0,length(l_c_instr) -6);
    END IF;
    return l_c_instr;
  END get_usec_instructors;

/**
    This Function Returns the Title for the Unit Section for the given uoo_id
**/
  FUNCTION get_us_title(p_n_uoo_id IN NUMBER) RETURN VARCHAR2 IS

    CURSOR c_us_title(cp_n_uoo_id IN NUMBER) IS
      SELECT t.title
      FROM   igs_ps_usec_ref t
      WHERE  t.uoo_id = cp_n_uoo_id;

    CURSOR c_uv_title(cp_n_uoo_id IN NUMBER) IS
       SELECT uv.title
       FROM   igs_ps_unit_ofr_opt_all us,
              igs_ps_unit_ver_all uv
       WHERE  us.uoo_id = cp_n_uoo_id
       AND    us.unit_cd = uv.unit_cd
       AND    us.version_number = uv.version_number;

     l_c_title igs_ps_unit_ver_all.title%TYPE;
  BEGIN
    OPEN c_us_title (p_n_uoo_id);
    FETCH c_us_title INTO l_c_title;
    CLOSE c_us_title;

    IF l_c_title IS NULL THEN
       OPEN c_uv_title(p_n_uoo_id);
       FETCH c_uv_title INTO l_c_title;
       CLOSE c_uv_title;
    END IF;

    RETURN l_c_title;

  END get_us_title;


  FUNCTION get_rule_text(p_rule_type IN VARCHAR2, p_n_uoo_id IN NUMBER) RETURN VARCHAR2
  ------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the rule text for a rule type and unit section
  --         to display in self service
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
  IS
    --cursor to look up the rule code in unit section version rules
    CURSOR c_usec_ru (cp_n_uoo_id IN NUMBER, cp_c_rul_call_cd IN VARCHAR2) IS
      SELECT rul_sequence_number
      FROM   igs_ps_usec_ru
      WHERE  uoo_id = p_n_uoo_id
      AND    s_rule_call_cd = cp_c_rul_call_cd;

    --cursor to look up the rule code in unit version rules
    CURSOR c_unit_ru(cp_n_uoo_id IN NUMBER, cp_c_rul_call_cd IN VARCHAR2) IS
      SELECT ru.rul_sequence_number
      FROM   igs_ps_unit_ver_ru ru,
             igs_ps_unit_ofr_opt_all uoo
      WHERE  uoo.uoo_id = p_n_uoo_id
      AND    uoo.unit_cd = ru.unit_cd
      AND    uoo.version_number = ru.version_number
      AND    ru.s_rule_call_cd = cp_c_rul_call_cd;

    l_n_seq_num igs_ps_usec_ru.rul_sequence_number%TYPE;
    l_c_us_cal_cd igs_ps_usec_ru.s_rule_call_cd%TYPE;
  BEGIN
    IF p_rule_type = 'COREQ' THEN
       l_c_us_cal_cd := 'USECCOREQ';
    ELSIF p_rule_type = 'PREREQ' THEN
       l_c_us_cal_cd := 'USECPREREQ';
    END IF;

    --check for rule at unit section level
    OPEN c_usec_ru(p_n_uoo_id,l_c_us_cal_cd);
    FETCH c_usec_ru INTO l_n_seq_num;
    CLOSE c_usec_ru;

    IF l_n_seq_num IS NULL THEN
       --check for rule at unit level
       OPEN c_unit_ru(p_n_uoo_id, p_rule_type);
       FETCH c_unit_ru INTO l_n_seq_num;
       CLOSE c_unit_ru;
    END IF;

    --get the rule text
    IF l_n_seq_num IS NULL THEN
       return get_none_desc;
    ELSE
       return igs_ru_gen_003.rulp_get_rule(l_n_seq_num);
    END IF;

  END get_rule_text;


-- returns the apportioned credit points for a unit section
FUNCTION  get_apor_credits(p_uoo_id IN NUMBER,
                           p_override_enrolled_cp IN NUMBER,
                           p_term_cal_type IN VARCHAR2,
                           p_term_seq_num IN NUMBER
                           ) RETURN NUMBER
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the apportioned credit points for a unit section
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
  -- get unit section details
  CURSOR c_unit_dtls(cp_uoo_id NUMBER)
  IS
  SELECT unit_cd,version_number,cal_type,ci_sequence_number
  FROM  igs_ps_unit_ofr_opt uoo
  WHERE uoo_id = cp_uoo_id;

  l_unit_dtls   c_unit_dtls%ROWTYPE;
  l_dummy1   NUMBER;
  l_dummy2   NUMBER;
  l_dummy3   NUMBER;
  l_dummy4   NUMBER;

  l_result      NUMBER;

BEGIN

  OPEN c_unit_dtls(p_uoo_id);
  FETCH c_unit_dtls INTO l_unit_dtls;
  CLOSE c_unit_dtls;

 --calculate the apportioned credit points
 l_result :=  igs_en_prc_load.enrp_clc_sua_load(
                l_unit_dtls.unit_cd,
                l_unit_dtls.version_number,
                l_unit_dtls.cal_type,
                l_unit_dtls.ci_sequence_number,
                p_term_cal_type,
                p_term_seq_num,
                p_override_enrolled_cp,
                null,
                l_dummy1,
                p_uoo_id,
                'N',
                l_dummy2,
                l_dummy3,
                l_dummy4);

 return l_result;

END get_apor_credits;

FUNCTION  get_billable_credit_points(p_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE)
            RETURN NUMBER
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the billable credit points for a unit section
  --         to display in self service
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS

  l_uv_enrolled_cp      IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
  l_uv_billing_cp       IGS_PS_UNIT_VER.billing_hrs%TYPE;
  l_uv_audit_cp         IGS_PS_UNIT_VER.billing_credit_points%TYPE;

  BEGIN
    IGS_PS_VAL_UV.get_cp_values(p_uoo_id, l_uv_enrolled_cp, l_uv_billing_cp,
                                l_uv_audit_cp);
    RETURN l_uv_billing_cp;
  END get_billable_credit_points;


FUNCTION is_unit_rule_defined(p_uoo_id  IN NUMBER,
                              p_rule_type IN VARCHAR2) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if a prereq/coreq rule has been setup for
  --         a unit section at the unit section/unit level.
  --         p_rule_type specifies the rule type that needs to be checked for
  --         for the unit section. Value can be either PREREQ or COREQ.
  --
  --         Returns Yes if rule has been setup.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
--Check if the prereq/coreq rule  is setup at the unit section level.
  CURSOR c_get_usec_rul_seq_no IS
     SELECT rul_sequence_number
     FROM igs_ps_usec_ru
     WHERE uoo_id = p_uoo_id
     AND s_rule_call_cd = 'USEC'|| p_rule_type;


 --Check if the prereq/coreq rule  is setup at the unit version level.
  CURSOR c_get_unit_rul_seq_no IS
     SELECT rul_sequence_number
     FROM igs_ps_unit_ver_ru uvr,
          igs_ps_unit_ofr_opt uoo
     WHERE uvr.unit_cd = uoo.unit_cd
     AND uvr.version_number = uoo.version_number
     AND   uoo_id = p_uoo_id
     AND uvr.s_rule_call_cd = p_rule_type;

 l_usec_seq_no  c_get_usec_rul_seq_no%ROWTYPE;
 l_unit_seq_no  c_get_unit_rul_seq_no%ROWTYPE;

BEGIN

 OPEN c_get_usec_rul_seq_no;
 FETCH c_get_usec_rul_seq_no INTO l_usec_seq_no;
 CLOSE c_get_usec_rul_seq_no;

 OPEN c_get_unit_rul_seq_no;
 FETCH c_get_unit_rul_seq_no INTO l_unit_seq_no;
 CLOSE c_get_unit_rul_seq_no;

 ---If rule is defined at either unit section or unit level
 IF l_usec_seq_no.rul_sequence_number IS NOT NULL OR l_unit_seq_no.rul_sequence_number IS NOT NULL THEN
    RETURN igs_ss_enroll_pkg.enrf_get_lookup_meaning('Y','YES_NO');
 END IF;

-- rule is not defined at either level so return false
 RETURN fnd_message.get_string('IGS','IGS_AZ_NONE');

END is_unit_rule_defined;

/**
  This function gets the meaning for the given lookup type and lookup code.
**/
FUNCTION get_meaning (p_c_lkup_type IN VARCHAR2,p_c_lkup_code IN VARCHAR2 ) RETURN VARCHAR2 IS
    cursor c_meaning (cp_c_lkup_type IN VARCHAR2, cp_c_lkup_code IN VARCHAR2) IS
      SELECT meaning
      FROM   igs_lookup_values
      WHERE  lookup_type = cp_c_lkup_type
      AND    lookup_code = cp_c_lkup_code;

    l_c_meaning igs_lookup_values.meaning%TYPE;

  BEGIN

     OPEN c_meaning(p_c_lkup_type, p_c_lkup_code);
     FETCH c_meaning INTO l_c_meaning;
     CLOSE c_meaning;
     RETURN l_c_meaning;

END get_meaning;



FUNCTION get_special_status(p_uoo_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if special permission is required
  --         for a unit section
  --
  --        Returns 'Special' if special permission is required for this unit section
  --        Returns 'None' if no special permission is required
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
 --cursor to check if special permission is setup at unit section level or at unit level
CURSOR cur_usec_details ( cp_uoo_id NUMBER) IS
      SELECT NVL(usec.special_permission_ind,'N')  special_permission_ind
                         FROM igs_ps_unit_ofr_opt_all usec
      WHERE usec.uoo_id = cp_uoo_id;


 cur_usec_details_rec cur_usec_details %ROWTYPE;

BEGIN
     OPEN cur_usec_details (p_uoo_id);
     FETCH cur_usec_details INTO cur_usec_details_rec;
     CLOSE cur_usec_details;

    --if special permission has been set up
    IF cur_usec_details_rec.special_permission_ind = 'Y' Then
      RETURN fnd_message.get_string('IGS','IGS_EN_SPECIAL_LINK');
    ELSE
       --no special permission has been set up, return 'None'
       RETURN fnd_message.get_string('IGS','IGS_AZ_NONE');
     END IF;


END get_special_status;


FUNCTION get_audit_status(p_uoo_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if audit permission is required
  --         for a unit section
  --
  --        Returns 'Audit' if audit permission is required for this unit section
  --        Returns 'None' if no audit permission is required
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
 --cursor to check if audit permission is setup at unit section level or at unit level
      CURSOR cur_usec_details ( cp_uoo_id NUMBER) IS
      SELECT     NVL(usec.auditable_ind,'N')  auditable_ind,
      NVL(usec.audit_permission_ind,'N')  audit_permission_ind
      FROM igs_ps_unit_ofr_opt_all usec
      WHERE usec.uoo_id = cp_uoo_id;

     cur_usec_details_rec cur_usec_details %ROWTYPE;

BEGIN
      OPEN cur_usec_details (p_uoo_id);
      FETCH cur_usec_details INTO cur_usec_details_rec;
      CLOSE cur_usec_details;

       --if audit permission has been set up
       IF cur_usec_details_rec.auditable_ind  ='Y' AND cur_usec_details_rec.audit_permission_ind ='Y' THEN
           RETURN fnd_message.get_string('IGS','IGS_EN_AUDIT_LINK');
       ELSE
          --no audit permission has been set up, return 'None'
          RETURN fnd_message.get_string('IGS','IGS_AZ_NONE');
       END IF;

END get_audit_status;



FUNCTION get_special_audit_status(p_uoo_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if special or audit permission is required
  --         for a unit section
  --
  --        Returns Special if special permission is set up
  --        Returns Audit if audit permission is set up
  --        Returns  Special / Audit if both special and audit permission are set up
  --        Returns None if niether special or audit permission are set up
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS

      CURSOR c_get_spl_audit_perm(cp_uoo_id NUMBER) IS
      SELECT NVL(special_permission_ind,'N'),NVL(audit_permission_ind,'N')
      FROM igs_ps_unit_ofr_opt
      WHERE uoo_id=cp_uoo_id;

    l_spl_perm VARCHAR2(1);
    l_aud_perm VARCHAR2(1);
    l_spl_audit_perm VARCHAR2(100);

BEGIN

   OPEN c_get_spl_audit_perm(p_uoo_id);
   FETCH c_get_spl_audit_perm INTO l_spl_perm,l_aud_perm;
   CLOSE c_get_spl_audit_perm;

   IF l_spl_perm = 'N' AND l_aud_perm = 'N'  THEN
      l_spl_audit_perm := fnd_message.get_string('IGS','IGS_AZ_NONE');
   ELSIF  l_spl_perm = 'Y'  AND l_aud_perm = 'N' THEN
      l_spl_audit_perm := fnd_message.get_string('IGS','IGS_EN_SPECIAL_LINK') ;
   ELSIF  l_spl_perm  = 'N' AND l_aud_perm = 'Y' THEN
      l_spl_audit_perm :=   fnd_message.get_string('IGS','IGS_EN_AUDIT_LINK');
   ELSIF  l_spl_perm  = 'Y' AND l_aud_perm = 'Y' THEN
      l_spl_audit_perm :=    fnd_message.get_string('IGS','IGS_EN_SPECIAL_LINK') ||  '/' || fnd_message.get_string('IGS','IGS_EN_AUDIT_LINK');
   END IF;

  RETURN l_spl_audit_perm;

END get_special_audit_status;


FUNCTION is_audit_allowed(p_uoo_id IN NUMBER,
                          p_person_type IN VARCHAR2) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if a unit section is auditable or not
  --
  --        Returns 'Y' if unit section is auditable
  --        Returns 'N' if unit section is not auditable
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- smaddali 13-oct-05 modified for bug4666977
-------------------------------------------------------------------
AS
 -- cursor to check if audit is allowed, checks first at unit section
 -- level, if not found checks at unit level

   CURSOR cur_uv_audit_ind (cp_uoo_id NUMBER)   IS
    Select NVL(usec.auditable_ind,'N') auditable_ind, cal_type,ci_sequence_number
    FROM igs_ps_unit_ofr_opt_all usec
    WHERE  usec.uoo_id = cp_uoo_id;

    CURSOR c_usr_conf (cp_person_type VARCHAR2) IS
     SELECT UPD_AUDIT_DT_ALIAS
     FROM   igs_pe_usr_arg
     WHERE  person_type = cp_person_type;

   CURSOR c_cal_conf IS
     SELECT AUDIT_STATUS_DT_ALIAS
     FROM   igs_en_cal_conf
     WHERE  s_control_num = 1;


  cur_uv_audit_ind_rec cur_uv_audit_ind%ROWTYPE;
  l_audit_dt_alias igs_en_cal_conf. AUDIT_STATUS_DT_ALIAS %TYPE;
  l_dt_alias_val igs_ca_da_inst_v.alias_val%TYPE;
BEGIN

    OPEN cur_uv_audit_ind(p_uoo_id);
    FETCH cur_uv_audit_ind INTO cur_uv_audit_ind_rec;
    CLOSE cur_uv_audit_ind;

     IF cur_uv_audit_ind_rec.auditable_ind ='Y'  THEN

      OPEN c_usr_conf(p_person_type);
      FETCH c_usr_conf INTO l_audit_dt_alias;
      CLOSE c_usr_conf;
      IF l_audit_dt_alias IS NULL THEN
        OPEN c_cal_conf;
        FETCH c_cal_conf INTO l_audit_dt_alias;
        CLOSE c_cal_conf;
      END IF;

      IF l_audit_dt_alias IS NULL THEN
 	    RETURN 'Y';
      END IF;

     l_dt_alias_val := igs_ss_enr_details.get_alias_val(cur_uv_audit_ind_rec.cal_type,
                           cur_uv_audit_ind_rec.ci_sequence_number, l_audit_dt_alias);

     -- Check whether the audit update date alias value is greater than or equal to sysdate
     -- smaddali modified to remove NVL handling in the if clause for bug4666977

     IF TRUNC (l_dt_alias_val) <= TRUNC (SYSDATE) THEN
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;


  END IF;

    RETURN 'N';

END is_audit_allowed;


FUNCTION is_placement_allowed (p_unit_cd IN VARCHAR2, p_version_number IN NUMBER)
           RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to check if placement is allowed for a unit section or not
  --
  --        Returns 'Y' if placement is allowed for unit section
  --        Returns 'N' if placement is not allowed for unit section
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
-- if the unit version has been marked as a practical unit then placement details will be available else no
    Cursor cur_practical_ind(cp_unit_cd VARCHAR2, cp_version_number NUMBER) IS
    Select practical_ind
    From igs_ps_unit_ver
    where unit_cd=cp_unit_cd
    and version_number= cp_version_number;

    l_result igs_ps_unit_ver.practical_ind%TYPE;

BEGIN

   OPEN cur_practical_ind(p_unit_cd,p_version_number);
   FETCH cur_practical_ind INTO l_result;
   CLOSE cur_practical_ind;

   RETURN l_result;

END is_placement_allowed;

FUNCTION get_enrollment_capacity(p_uoo_id NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function returns the enrollment maximum and actual enrollment for
  --         a unit section in the format actual enrollment/maximum enrollment
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- ckasu     01-Aug-2005     Modified as a part of EN317 SS UI Build
  --                            bug# #4377985
-------------------------------------------------------------------
IS

-- Cursor to get the enrollment maximum in cross listed group
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grpmem.usec_x_listed_group_id
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;


  -- Cursor to get the enrollment maximum in Meet with class group
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, ucm.class_meet_group_id
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;

   -- Cursor to get the actual enrollment of all the unit sections that belong
   -- to this class listed group.
  CURSOR c_actual_enr_crs_lst(l_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_usec_x_grpmem ugrp
  WHERE  uoo.uoo_id = ugrp.uoo_id
  AND    ugrp.usec_x_listed_group_id = l_usec_x_listed_group_id;


  -- Cursor to get the actual enrollment of all the unit sections that belong
  -- to this meet with class group.
  CURSOR c_actual_enr_meet_cls(l_class_meet_group_id igs_ps_uso_clas_meet.class_meet_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_uso_clas_meet ucls
  WHERE  uoo.uoo_id = ucls.uoo_id
  AND    ucls.class_meet_group_id = l_class_meet_group_id;


  -- Cursor to fetch the enrollment Maximum value defined at Unit Section level
  CURSOR cur_usec_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_maximum
  FROM igs_ps_usec_lim_wlst
  WHERE uoo_id = p_uoo_id;

  -- cursor to fetch the enrollment maximum value defined at unit level
  CURSOR cur_unit_enr_max( p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_maximum
  FROM   igs_ps_unit_ver
  WHERE  (unit_cd , version_number ) IN (SELECT unit_cd , version_number
                                         FROM   igs_ps_unit_ofr_opt
                                         WHERE  uoo_id = p_uoo_id);

  --
  --  Cursor to find the Actual Enrollment of the Unit section
  --
  CURSOR c_enroll_actual (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT enrollment_actual
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = cp_uoo_id;

  l_max igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;
  l_act igs_ps_unit_ofr_opt.enrollment_actual%TYPE;
  l_setup_found NUMBER;
  l_cross_listed_row c_cross_listed%ROWTYPE;
  l_meet_with_cls_row c_meet_with_cls%ROWTYPE;
  l_usec_partof_group  BOOLEAN;
  l_cat_enr_act varchar2(100);
  l_temp VARCHAR2(10);

  BEGIN

  -- Check whether the unit section belongs to any cross listed group. If so then get the
  -- maximim enrollment limit in the group level. If it is not null then get the actual enrollment
  -- of all the unit sections which belong to that group and return the concatenated string of
  -- Maximim enrollment and actual enrollment.
  -- Incase if the maximum enrollment limit is not set in the group level the get it from
  -- Unit Section level or in the unit level.

    l_usec_partof_group := FALSE;

    OPEN c_cross_listed(p_uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row ;


    IF c_cross_listed%FOUND THEN
        CLOSE c_cross_listed;
         -- Get the maximum enrollment limit from the group level.
        IF l_cross_listed_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;

        ELSE
          l_usec_partof_group := TRUE;
          l_max := l_cross_listed_row.max_enr_group;

          -- Get the actual enrollment count of all the unit sections that belongs to the cross listed group.
         OPEN c_actual_enr_crs_lst(l_cross_listed_row.usec_x_listed_group_id);
         FETCH c_actual_enr_crs_lst INTO l_act;
         CLOSE c_actual_enr_crs_lst;

      -- Concatenate the meaning with the maximim enrollment limit and actual enrollment limit.
      -- The format should be like 'Cross Listed <BR> 10(5)'
          RETURN get_meaning('IGS_PS_USEC_GROUPS','CROSS_LIST') ||'   '||NVL(to_char(l_act),'-') || '/' || NVL(to_char(l_max),'-');

        END IF;

     ELSE
       CLOSE c_cross_listed;
       OPEN c_meet_with_cls(p_uoo_id);
       FETCH c_meet_with_cls INTO l_meet_with_cls_row ;


       IF c_meet_with_cls%FOUND THEN
        CLOSE c_meet_with_cls;
         -- Get the maximum enrollment limit from the group level.
         IF l_meet_with_cls_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;

         ELSE
           l_usec_partof_group := TRUE;
           l_max := l_meet_with_cls_row.max_enr_group;

       -- Get the actual enrollment count of all the unit sections that belongs to
       -- the meet with class group.
           OPEN c_actual_enr_meet_cls(l_meet_with_cls_row.class_meet_group_id);
           FETCH c_actual_enr_meet_cls INTO l_act;
           CLOSE c_actual_enr_meet_cls;



          -- Concatenate the meaning with the maximim enrollment limit and actual enrollment limit.
          -- The format should be like 'Meet With <BR> 10(5)'
         RETURN get_meaning('IGS_PS_USEC_GROUPS','MEET_WITH')||'   '||NVL(to_char(l_act),'-') || '/' || NVL(to_char(l_max),'-');
         END IF;
       ELSE
         CLOSE c_meet_with_cls;
         l_usec_partof_group := FALSE;
      END IF;

     END IF;
     IF  l_usec_partof_group = FALSE THEN

      -- If the Unit Section passed doesn't belong to any of the group then
      -- check the maximum enrollment limit in the Unit Section level / Unit level.

      OPEN cur_usec_enr_max(p_uoo_id);
      FETCH cur_usec_enr_max INTO l_max;
      CLOSE cur_usec_enr_max;


      IF l_max IS NULL THEN
        -- Get the maximum enrollment limit from Unit level.
         OPEN cur_unit_enr_max(p_uoo_id);
         FETCH cur_unit_enr_max INTO l_max;
         CLOSE cur_unit_enr_max;
      END IF;

      -- get the actual enrollment limit.
      OPEN c_enroll_actual(p_uoo_id);
      FETCH c_enroll_actual INTO l_act;
      CLOSE c_enroll_actual;
      l_temp := l_max;
      l_cat_enr_act := NVL(to_char(l_act),'-') || '/' || NVL(l_temp,'-');
      RETURN l_cat_enr_act;
    END IF;
    RETURN l_cat_enr_act;
END get_enrollment_capacity;


FUNCTION can_drop (p_cal_type   IN VARCHAR2,
                   p_ci_sequence_number IN NUMBER,
                   p_effective_dt       IN DATE,
                   p_uoo_id             IN NUMBER,
                   p_c_core             IN VARCHAR2,
                   p_n_person_id        IN NUMBER,
                   p_c_course_cd        IN VARCHAR2
                   ) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function determines if a unit attempt can be dropped for swap
  --
  --         Returns N if unit attempt can be dropped
  --         Return  Y if unit attempt cannot be dropped
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ckasu     05-JUL-2005    modified as a part of EN317 BUILD
-------------------------------------------------------------------
AS

    CURSOR c_uoo_teach_cal (cp_uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
    SELECT cal_type, ci_sequence_number
    FROM IGS_PS_UNIT_OFR_OPT
    WHERE uoo_id = cp_uoo_id;

    -- cursor to check whether unit section is superior unit section.
    CURSOR c_sup(cp_n_uoo_id IN NUMBER) IS
       SELECT 1
       FROM   igs_ps_unit_ofr_opt_all
       WHERE  sup_uoo_id = cp_n_uoo_id
       AND    rownum <2;

    -- cursor to checks whether subordinate unit section exists in unit attempt status
    -- other than enrolled, invalid, discontinued and dropped for the given superior unit section.
    CURSOR c_invalid_sub(cp_c_course_cd IN VARCHAR2,
                                               cp_n_person_id IN NUMBER,
                                               cp_n_uoo_id IN NUMBER) IS
      SELECT 1
      FROM   IGS_EN_SU_ATTEMPT_ALL sua,
                    IGS_PS_UNIT_OFR_OPT_ALL uoo
      WHERE  sua.uoo_id = uoo.uoo_id
      AND    uoo.sup_uoo_id = cp_n_uoo_id
      AND    sua.course_cd = cp_c_course_cd
      AND    sua.person_id = cp_n_person_id
      AND    sua.unit_attempt_status NOT IN ('ENROLLED','INVALID','DISCONTIN','DROPPED')
      AND    ROWNUM <2;

    -- cursor to get all the subordinate unit attempt for the given superior unit attempt.
    CURSOR c_sub_sua (cp_c_course_cd IN VARCHAR2,
                      cp_n_person_id IN NUMBER,
            cp_n_uoo_id IN NUMBER) IS
      SELECT sua.uoo_id,
             sua.core_indicator_code
      FROM   IGS_EN_SU_ATTEMPT_ALL sua,
                    IGS_PS_UNIT_OFR_OPT_ALL uoo
      WHERE  sua.uoo_id = uoo.uoo_id
      AND    uoo.sup_uoo_id = cp_n_uoo_id
      AND    sua.course_cd = cp_c_course_cd
      AND    sua.person_id = cp_n_person_id
      AND    sua.unit_attempt_status IN ('ENROLLED','INVALID');

    temp Number; -- temporary variable.
    l_c_deny_warn VARCHAR2(10); -- deny warn flag.

    l_teach_cal_type IGS_PS_UNIT_OFR_OPT.CAL_TYPE%TYPE;
    l_teach_ci_sequence_number IGS_PS_UNIT_OFR_OPT.CI_SEQUENCE_NUMBER%TYPE;

  BEGIN

    OPEN c_uoo_teach_cal(p_uoo_id);
    FETCH c_uoo_teach_cal INTO l_teach_cal_type, l_teach_ci_sequence_number;
    CLOSE c_uoo_teach_cal;

     -- Check whether enrollment window is open
     IF IGS_EN_GEN_008.enrp_get_var_window( l_teach_cal_type, l_teach_ci_sequence_number,
                                                p_effective_dt, p_uoo_id) THEN

       -- check whether unit attempt can be dropped or discontinued
       -- function Enrp_Get_Ua_Del_Alwd returns 'N' if it can be discontinued 'Y' if it can only be dropped.
        IF IGS_EN_GEN_008.Enrp_Get_Ua_Del_Alwd(l_teach_cal_type, l_teach_ci_sequence_number,
                                               p_effective_dt, p_uoo_id) = 'Y' THEN
           -- check whether the unit attempt getting dropped is superior unit section.
           OPEN c_sup(p_uoo_id);
           FETCH c_sup INTO temp;
           IF c_sup%FOUND THEN
              CLOSE c_sup;
              -- check whether the superior unit attempt has subordinate unit attempt
              -- in status other than enrolled and invalid
              OPEN c_invalid_sub(p_c_course_cd,p_n_person_id,p_uoo_id);
              FETCH c_invalid_sub INTO temp;
              IF c_invalid_sub%FOUND THEN
                 close c_invalid_sub;
                   -- return 'Y' if there are subordinate unit attempt exists and
                   -- their unit attempt status is other than 'enrolled' and 'invalid'
                 RETURN 'Y';
              ELSE
                 close c_invalid_sub;
              END IF;

              -- check whether the subordinate unit attempt can be dropped without any issues.
              FOR rec_sub_sua IN c_sub_sua(p_c_course_cd,p_n_person_id,p_uoo_id)
              LOOP
                IF can_drop (p_cal_type           => p_cal_type,
                             p_ci_sequence_number => p_ci_sequence_number,
                             p_effective_dt       => p_effective_dt,
                             p_uoo_id             => rec_sub_sua.uoo_id,
                             p_c_core             => rec_sub_sua.core_indicator_code,
                             p_n_person_id        => p_n_person_id,
                             p_c_course_cd        => p_c_course_cd) = 'Y' THEN
                     RETURN 'Y';
                END IF;
              END LOOP;
           ELSE
              CLOSE c_sup;
           END IF;
           RETURN 'N';  -- Can be selected for swap
        END IF; -- checking for drop / discontinue
     END IF; -- checking for variable window open
     RETURN 'Y';
END can_drop;

/**
  This function returns the total credits for planned unit attempts in a term
**/
FUNCTION get_total_plan_credits(p_personid NUMBER,
                                p_course_cd VARCHAR2,
                                p_term_cal_type VARCHAR2,
                                p_term_seq_num NUMBER) RETURN NUMBER
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function returns the total credit points in the planning sheet
  --         for a term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS

CURSOR c_total_plan_credits(cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
SELECT  SUM(igs_ss_enr_details.get_apor_credits ( uoo_id, override_enrolled_cp,
             cp_term_cal_type,cp_term_seq_num)) apor_cp
FROM IGS_EN_PLAN_UNITS pls
WHERE pls.cart_error_flag= 'N'
AND  pls.person_id = p_personid
AND  pls.course_cd = p_course_cd
AND  pls.term_cal_type = cp_term_cal_type
AND  pls.term_ci_sequence_number = cp_term_seq_num;

CURSOR c_total_unconfirm_credits (cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
SELECT   SUM(igs_ss_enr_details.get_apor_credits ( uoo_id, override_enrolled_cp,
             cp_term_cal_type,cp_term_seq_num)) apor_cp
FROM IGS_EN_SU_ATTEMPT sua
WHERE sua.unit_attempt_status = 'UNCONFIRM'
   AND sua.person_id = p_personid
  AND  sua.course_cd = p_course_cd
  AND  (sua.cal_type , sua.ci_sequence_number) in (select teach_cal_type, teach_ci_sequence_number from igs_ca_teach_to_load_v where
                                                        load_cal_type = cp_term_cal_type and load_ci_sequence_number = cp_term_seq_num);

   l_total_plan_credits NUMBER;
   l_total_unconfirm_credits NUMBER;

BEGIN


   -- fetch the total credits points from planning sheet
   OPEN c_total_plan_credits(p_term_cal_type,p_term_seq_num);
   FETCH c_total_plan_credits INTO l_total_plan_credits;
   CLOSE c_total_plan_credits;

   --fetch the total credit points of unconfirmed unit attempts
   OPEN c_total_unconfirm_credits(p_term_cal_type,p_term_seq_num);
   FETCH c_total_unconfirm_credits INTO l_total_unconfirm_credits;
   CLOSE c_total_unconfirm_credits;


   --return the sum of planned and unconfirmed unit attempts
   RETURN NVL(l_total_plan_credits,0) + NVL(l_total_unconfirm_credits,0);


END;


/**
  This function checks if enrollment is open for a given term
**/
FUNCTION get_enr_period_open_status( p_person_id                  IN  NUMBER,
                                     p_course_cd                  IN VARCHAR2,
                                     p_load_calendar_type         IN  VARCHAR2,
                                     p_load_cal_sequence_number   IN  NUMBER,
                                     p_person_type                IN VARCHAR2,
                                     p_message                    OUT NOCOPY  VARCHAR2)
                                     RETURN BOOLEAN
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function checks if enrollment is open for a term
  --
  --         Returns True if enrollment is open
  --         Returns False if enrollment is not open
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
--cursor to check if schedule is open for a given term
CURSOR c_get_schedule_flag IS
SELECT   ci.schedule_flag schedule_flag
FROM igs_ca_inst_all ci
WHERE CAL_TYPE = p_load_calendar_type
AND   SEQUENCE_NUMBER = p_load_cal_sequence_number;

--cursor to fetch the schedule start date alias
CURSOR c_cal_conf IS
SELECT  schedule_open_dt_alias
FROM   igs_en_cal_conf
WHERE  s_control_num = 1;

l_sch_dt_alias igs_en_cal_conf.SCHEDULE_OPEN_DT_ALIAS%TYPE;
l_schedule_flag igs_ca_inst_all.schedule_flag%TYPE;
l_dt_alias_val DATE;


BEGIN



OPEN c_get_schedule_flag;
FETCH c_get_schedule_flag INTO l_schedule_flag;
CLOSE c_get_schedule_flag;

OPEN c_cal_conf;
FETCH c_cal_conf INTO l_sch_dt_alias;
CLOSE c_cal_conf;

 --if schedule is open for the term
 IF l_schedule_flag = 'Y' THEN
    -- get the schedule alias value for the current term.
    l_dt_alias_val := igs_ss_enr_details.get_alias_val(p_load_calendar_type, p_load_cal_sequence_number, l_sch_dt_alias);
    -- Check whether the planning sheet date alias value is greater than or equal to sysdate
    IF l_dt_alias_val IS NOT NULL AND TRUNC (l_dt_alias_val) <= TRUNC (SYSDATE) THEN
        -- Check whether student has timeslot
        IF igs_ss_enr_details.stu_timeslot_open (p_person_id,
                                                 p_person_type,
                                                 p_course_cd,
                                                 p_load_calendar_type,
                                                 p_load_cal_sequence_number) THEN

            RETURN TRUE;

        END IF; -- end of  IF igs_ss_enr_details.stu_timeslot_open check

    END IF; -- end of IF l_dt_alias_val IS NOT NULL AND TRUNC (l_dt_alias_val) <= TRUNC (SYSDATE)

 END IF; -- end of IF  l_schedule_flag = 'Y

RETURN FALSE;

END get_enr_period_open_status;


FUNCTION  is_selection_enabled (p_person_id                  IN  NUMBER,
                                p_load_cal_type              IN  VARCHAR2,
                                p_load_seq_num               IN  NUMBER,
                                p_person_type                IN VARCHAR2,
                                p_message                    OUT NOCOPY  VARCHAR2
                                ) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function checks if unit sections can be selected to be enrolled
  --         for a term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ckasu    29-Jul-2005      modified as a part of EN 317 Build
  --svanukur   30-sep-2005   modified as a part of EN 317 Build

-------------------------------------------------------------------
IS
 --cursor to check if the selected load calendar is open only for searching
 --but not for planning or  for the schedule.
 CURSOR c_get_load_cal_open_status(cp_load_cal_type VARCHAR2, cp_load_seq_num NUMBER) IS
    SELECT  'x'
    FROM  IGS_CA_INST
    WHERE CAL_TYPE = cp_load_cal_type
    AND   SEQUENCE_NUMBER = cp_load_seq_num
    AND   SS_DISPLAYED = 'Y'
    AND   PLANNING_FLAG = 'N'
    AND   SCHEDULE_FLAG = 'N';

 --cursor to check if the passed in load calendar is associated with the academic calendar
 -- of any of the student's program attempts
  CURSOR c_check_is_load_assoc_to_acad (cp_person_id NUMBER, cp_load_cal_type VARCHAR2, cp_load_seq_num NUMBER) IS
    SELECT distinct cir.sub_cal_type ,cir.sub_ci_sequence_number
    FROM igs_en_stdnt_ps_att sca,
         igs_ca_inst_rel cir,
         igs_ca_type ct
    WHERE cir.sup_cal_type = sca.cal_type and
          ct.cal_type = cir.sub_cal_type  and
          ct.s_cal_cat = 'LOAD' and
          sca.person_id = cp_person_id and
          cir.sub_cal_type = cp_load_cal_type and
          cir.sub_ci_sequence_number = cp_load_seq_num;

  CURSOR cur_sys_pers_type(p_person_type_code VARCHAR2) IS
    SELECT system_type
    FROM igs_pe_person_types
    WHERE person_type_code = p_person_type_code;


 l_rec                 c_get_load_cal_open_status%ROWTYPE;
 l_load_acad_rec c_check_is_load_assoc_to_acad%ROWTYPE;
 l_system_type         igs_pe_person_types.system_type%TYPE;

BEGIN

    OPEN cur_sys_pers_type(p_person_type);
    FETCH cur_sys_pers_type INTO l_system_type;
    CLOSE cur_sys_pers_type;

    IF  l_system_type = 'STUDENT' THEN
        OPEN c_get_load_cal_open_status(p_load_cal_type,p_load_seq_num);
        FETCH c_get_load_cal_open_status INTO l_rec;
        --if load calendar is open only for searching
        IF c_get_load_cal_open_status%FOUND THEN
           p_message := 'IGS_EN_SEARCH_ONLY';
        CLOSE c_get_load_cal_open_status;
           RETURN 'FALSE';
        END IF;
        CLOSE c_get_load_cal_open_status;

    END IF; -- end of IF  l_system_type = 'STUDENT' THEN

    OPEN c_check_is_load_assoc_to_acad(p_person_id,p_load_cal_type,p_load_seq_num);
    FETCH c_check_is_load_assoc_to_acad INTO l_load_acad_rec;
    --if load calendar is not associated with academic calendar of
    --any of the student's program attempts
    IF c_check_is_load_assoc_to_acad%NOTFOUND THEN
     p_message := 'IGS_EN_SEARCH_ONLY';
     CLOSE c_check_is_load_assoc_to_acad;
     RETURN 'FALSE';
    END IF;
    CLOSE c_check_is_load_assoc_to_acad;

    RETURN 'TRUE';

 END is_selection_enabled;

FUNCTION get_us_subtitle (p_n_uoo_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function returns the subtitle for a unit section
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
     CURSOR c_us_title(cp_n_uoo_id IN NUMBER) IS
       SELECT t.subtitle
       FROM   igs_ps_unit_subtitle t,
                      igs_ps_usec_ref us
       WHERE  us.uoo_id = cp_n_uoo_id
      AND    us.subtitle_id = t.subtitle_id;

      CURSOR c_uv_title(cp_n_uoo_id IN NUMBER) IS
       SELECT t.subtitle
       FROM   igs_ps_unit_subtitle t,
                      igs_ps_unit_ofr_opt_all us,
                      igs_ps_unit_ver_all uv
       WHERE  us.uoo_id = cp_n_uoo_id
       AND    us.unit_cd = uv.unit_cd
       AND    us.version_number = uv.version_number
       AND    uv.subtitle_id = t.subtitle_id;
        l_c_subtitle  igs_ps_unit_subtitle.subtitle%TYPE;
 BEGIN
    OPEN c_us_title(p_n_uoo_id);
    FETCH c_us_title INTO l_c_subtitle;
    CLOSE c_us_title;
    IF l_c_subtitle IS NULL THEN
       OPEN c_uv_title(p_n_uoo_id);
       FETCH c_uv_title INTO l_c_subtitle;
      CLOSE c_uv_title;
    END IF;
   RETURN l_c_subtitle;
 END get_us_subtitle;


FUNCTION get_waitlist_capacity(p_uoo_id NUMBER, p_unit_cd IN VARCHAR2,
                  p_version IN NUMBER,
                  p_cal_type IN VARCHAR2, p_sequence_number IN NUMBER,
                  p_owner_org_unit_cd IN VARCHAR2) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function returns the actual and maximum waitlist capacity for
  --         a unit section in the format actual waitlist/maximum waitlist
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
    Cursor cur_wait_actual(cp_uoo_id NUMBER) IS
      Select NVL(waitlist_actual,0)
      from igs_ps_unit_ofr_opt
      where uoo_id=cp_uoo_id;

    l_result VARCHAR2(100);

BEGIN
    OPEN cur_wait_actual(p_uoo_id);
    FETCH cur_wait_actual INTO l_result;
    CLOSE cur_wait_actual;

    l_result := l_result || '/' || get_max_waitlist_for_unit(p_uoo_id ,
                  p_unit_cd ,
                  p_version ,
                  p_cal_type , p_sequence_number ,
                  p_owner_org_unit_cd) ;

    return l_result;

END get_waitlist_capacity;

FUNCTION get_class_day (p_n_uso_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the meeting days for a unit section occurrence
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
     CURSOR c_uso(cp_n_uso_id IN NUMBER) IS
       SELECT uso.to_be_announced,
                       uso.no_set_day_ind,
                       DECODE(uso.monday,  'Y',  'M',  NULL)   ||
                       DECODE(uso.tuesday,  'Y',  'Tu',  NULL)  ||
                       DECODE(uso.wednesday,  'Y',  'W',  NULL) ||
                       DECODE(uso.thursday,  'Y',  'Th',  NULL) ||
                       DECODE(uso.friday,  'Y',  'F',  NULL)    ||
                       DECODE(uso.saturday,  'Y',  'Sa',  NULL) ||
                       DECODE(uso.sunday,  'Y',  'Su',  NULL)  meetings
      FROM    igs_ps_usec_occurs_all uso
      WHERE   uso.unit_section_occurrence_id = cp_n_uso_id;
      rec_uso c_uso%ROWTYPE;
      l_c_ret_data varchar2(80);
 BEGIN
     OPEN c_uso(p_n_uso_id);
     FETCH c_uso INTO rec_uso;
     IF c_uso%FOUND THEN
         IF rec_uso.to_be_announced = 'Y' THEN
              l_c_ret_data := get_tba_desc;
         ELSIF rec_uso.no_set_day_ind ='Y' THEN
            l_c_ret_data := get_nsd_desc;
         ELSE
            l_c_ret_data := rec_uso.meetings;
         END IF;
      END IF;
      CLOSE c_uso;
      RETURN l_c_ret_data;
END get_class_day;

FUNCTION get_class_time (p_n_uso_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the meeting times for a unit section occurrence
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
    CURSOR c_uso(cp_n_uso_id IN NUMBER) IS
       SELECT uso.no_set_day_ind,
              to_char(uso.start_time,'hh:miam') start_time,
              to_char(uso.end_time,'hh:miam') end_time
       FROM    igs_ps_usec_occurs_all uso
       WHERE   uso.unit_section_occurrence_id = cp_n_uso_id;
   rec_uso c_uso%ROWTYPE;

   l_c_ret_data varchar2(80);
BEGIN
      OPEN c_uso (p_n_uso_id);
       FETCH c_uso INTO rec_uso;
       IF c_uso%FOUND THEN
            IF rec_uso.no_set_day_ind = 'Y' THEN
                  l_c_ret_data := NULL;
            ELSIF rec_uso.start_time IS NULL THEN
                  l_c_ret_data := get_tba_desc;
            ELSE
                  l_c_ret_data := rec_uso.start_time  || ' - ' || rec_uso.end_time;
           END IF;
      END IF;
      CLOSE c_uso;
      RETURN l_c_ret_data;
END get_class_time;


FUNCTION get_occur_dates (p_n_uso_id IN NUMBER) RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the meeting dates for a unit section occurrence
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
    CURSOR c_uso_dtls (cp_n_uso_id IN NUMBER) IS
      SELECT           TO_CHAR( NVL( NVL( USO.START_DATE, US.UNIT_SECTION_START_DATE),
                                CA.START_DT), 'DD MON YYYY') || ' - ' ||
                                TO_CHAR( NVL( NVL( USO.END_DATE, US.UNIT_SECTION_END_DATE),
                                CA.END_DT), 'DD MON YYYY')  effective_date
     FROM   igs_ps_usec_occurs_all USO,
                    igs_ps_unit_ofr_opt_all US,
                    igs_ca_inst_all CA
     WHERE  uso.unit_section_occurrence_id = cp_n_uso_id
    AND        uso.uoo_id = us.uoo_id
    AND        us.cal_type = ca.cal_type
    AND        us.ci_sequence_number = ca.sequence_number;

    l_uso_dates varchar2(50);
BEGIN
      OPEN c_uso_dtls(p_n_uso_id);
      FETCH c_uso_dtls INTO l_uso_dates;
      CLOSE c_uso_dtls;
      return l_uso_dates;

END get_occur_dates;

FUNCTION get_calling_object (p_person_id         IN  NUMBER,
                             p_course_cd         IN VARCHAR2,
                             p_load_cal_type     IN  VARCHAR2,
                             p_load_seq_num      IN  NUMBER,
                             p_person_type       IN VARCHAR2,
                             p_message           OUT NOCOPY  VARCHAR2
                            ) RETURN VARCHAR2
IS
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function checks if unit sections can be selected to be enrolled
  --         for a term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ckasu    29-Jul-2005      modified as a part of EN 317 Build
  --stutta   28-Oct-2005      removed check for student as this method
  --                                   is called only from student page
-------------------------------------------------------------------

     CURSOR c_get_plan_schedule_flag(cp_load_cal_type VARCHAR2, cp_load_seq_num NUMBER) IS
     SELECT  planning_flag,
             schedule_flag
     FROM igs_ca_inst_all ci
     WHERE CAL_TYPE = cp_load_cal_type
     AND   SEQUENCE_NUMBER = cp_load_seq_num;

     CURSOR c_cal_conf IS
             SELECT planning_open_dt_alias, schedule_open_dt_alias
             FROM   igs_en_cal_conf
             WHERE  s_control_num = 1;

     CURSOR c_spat_check (cp_person_id         IN  NUMBER,
                         cp_course_cd          IN  VARCHAR2,
                         cp_load_cal_type      IN  VARCHAR2,
                         cp_load_seq_num       IN  NUMBER) IS
     SELECT plan_sht_status
     FROM   igs_en_spa_terms
     WHERE  person_id= cp_person_id
     AND    program_cd=cp_course_cd
     AND    term_cal_type=cp_load_cal_type
     AND    term_sequence_number=cp_load_seq_num;

     CURSOR cur_sys_pers_type(p_person_type_code VARCHAR2) IS
     SELECT system_type
     FROM igs_pe_person_types
     WHERE person_type_code = p_person_type_code;


     l_plan_dt_alias igs_en_cal_conf.planning_open_dt_alias %TYPE;
     l_sch_dt_alias igs_en_cal_conf.SCHEDULE_open_DT_ALIAS%TYPE;

     l_plan_flag igs_ca_inst_all.planning_flag%TYPE;
     l_schedule_flag igs_ca_inst_all.schedule_flag%TYPE;

     l_dt_alias_val DATE;

     l_planning_open BOOLEAN;
     l_schedule_open BOOLEAN;
     l_calling_object VARCHAR2(100);

     l_spat_plan_flag igs_en_spa_terms.plan_sht_status%TYPE;
     l_system_type         igs_pe_person_types.system_type%TYPE;


BEGIN
 l_planning_open := FALSE;
 l_schedule_open := FALSE;

 OPEN cur_sys_pers_type(p_person_type);
 FETCH cur_sys_pers_type INTO l_system_type;
 CLOSE cur_sys_pers_type;


 OPEN c_get_plan_schedule_flag(p_load_cal_type,p_load_seq_num);
 FETCH c_get_plan_schedule_flag INTO l_plan_flag,l_schedule_flag;
 CLOSE c_get_plan_schedule_flag;

 OPEN c_cal_conf;
 FETCH c_cal_conf INTO l_plan_dt_alias,l_sch_dt_alias;
 CLOSE c_cal_conf;

 -- Check whether the schedule is open for the given term

 IF l_schedule_flag = 'Y' THEN
    -- get the schedule alias value for the current term.
    l_dt_alias_val := igs_ss_enr_details.get_alias_val(p_load_cal_type, p_load_seq_num, l_sch_dt_alias);
    -- Check whether the planning sheet date alias value is greater than or equal to sysdate
    IF l_dt_alias_val IS NOT NULL AND TRUNC (l_dt_alias_val) <= TRUNC (SYSDATE) THEN
        -- Check whether student has timeslot and
        IF igs_ss_enr_details.stu_timeslot_open (p_person_id,
                                                 p_person_type,
                                                 p_course_cd,
                                                             p_load_cal_type,
                                                                 p_load_seq_num) THEN

            l_schedule_open := TRUE;

      END IF; -- end of  IF igs_ss_enr_details.stu_timeslot_open check

    END IF; -- end of IF l_dt_alias_val IS NOT NULL AND TRUNC (l_dt_alias_val) >= TRUNC (SYSDATE)

 END IF; -- end of IF  l_schedule_flag = 'Y

         -- Check whether the planning is open for the given term
         -- if the plannings is allowed for the plannig sheet and IGS: Use Planning Sheet Profile is ON
         IF  l_plan_flag = 'Y' AND  NVL(fnd_profile.value('IGS_EN_USE_PLAN'),'OFF') = 'ON'  THEN

           -- Get the planning sheet date alias value for the given load calendar.
           l_dt_alias_val := igs_ss_enr_details.get_alias_val( p_load_cal_type, p_load_seq_num,l_plan_dt_alias);

           -- Check whether the planning sheet date alias value is greater than or equal to sysdate
           IF l_dt_alias_val IS NOT NULL AND TRUNC (l_dt_alias_val) <= TRUNC (SYSDATE) THEN

              -- Get the planning sheet status at SPA TERMS records
              OPEN c_spat_check(p_person_id,p_course_cd,p_load_cal_type,p_load_seq_num);
              FETCH c_spat_check INTO l_spat_plan_flag;
              CLOSE c_spat_check;

              -- Planning sheet is allowed only when the SPA Terms record does not exists or
              -- planning sheet status flag is PLAN or NONE. Otherwise plannnig sheet is not
              -- active and user work with the planning sheet.
              IF l_spat_plan_flag IS NULL OR l_spat_plan_flag in ('PLAN','NONE') THEN
                  l_spat_plan_flag := NULL; -- nullifying it as it is getting re used down.
                  l_planning_open := TRUE;
              END IF;

           END IF;

         END IF;

 --if only planning is open
 IF l_planning_open AND NOT l_schedule_open THEN
        l_calling_object := 'PLAN';

 --if only schedule is open
 ElSIF NOT l_planning_open AND l_schedule_open THEN
            l_calling_object := 'SCHEDULE';

 --if both planning and schedule are not open
 ElSIF NOT l_planning_open AND NOT l_schedule_open THEN
    IF l_system_type = 'STUDENT' THEN
       p_message :='IGS_EN_PLAN_SCH_NOT_OPEN';
    ELSE
       p_message :='IGS_EN_SCH_NOT_OPEN';
    END IF;
    RETURN null;

 --if both planning and schedule are open
 ELSIF l_planning_open AND l_schedule_open THEN

  --check if term record exists
   OPEN c_spat_check(p_person_id,p_course_cd,p_load_cal_type,p_load_seq_num);
   FETCH c_spat_check INTO l_spat_plan_flag;

    --if term record exists
    IF (c_spat_check%FOUND)THEN
       IF(l_spat_plan_flag='PLAN') THEN
           l_calling_object := 'DECISION';
       ELSIF(l_spat_plan_flag='SUB_PLAN') THEN
           l_calling_object := 'CART';
          --no term record was found
       ELSIF (l_spat_plan_flag='NONE' OR
             l_spat_plan_flag='SKIP' OR
             l_spat_plan_flag='SUB_CART') THEN
          l_calling_object := 'SCHEDULE';
      END IF;
    ELSE
          l_calling_object := 'SCHEDULE';
    END IF; -- end of if (c_spat_check%FOUND)

     CLOSE c_spat_check;
 END IF;
 RETURN l_calling_object;

END get_calling_object;

FUNCTION parse_coreq1(p_coreq_string VARCHAR)
 RETURN VARCHAR2
 ------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to parse unit codes from string containing both unit
  --         codes and version numbers
  --         if passed in string contains ENGL100.1,MATH100.1,
  --         this functions parses and returns ENGL100 and MATH100
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
 As

l_dot_index NUMBER;
l_comma_index NUMBER;
l_coreq_string VARCHAR2(2000);

 BEGIN
l_coreq_string := p_coreq_string;
 LOOP
    L_dot_index := 0;
    L_comma_index := 0;

                          L_dot_index := INSTR(l_coreq_string,'.',1 );
                          EXIT when    L_dot_index =0;
                            L_comma_index := INSTR( l_coreq_string , ',',L_dot_index  );

                                l_coreq_string :=  SUBSTR( l_coreq_string,1, L_dot_index-1) || SUBSTR( l_coreq_string, L_comma_index);

                        END LOOP;

 return l_coreq_string;

end ;

FUNCTION parse_coreq2(p_coreq_string VARCHAR2)
 RETURN VARCHAR2
 ------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get all the unit codes for any unit codes containing
  --         wildcard characters as the unit code rule may contain %
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
As

l_comma_index NUMBER(38);
l_coreq_string VARCHAR2(2000);
l_final_coreq_string VARCHAR2(2000);
l_unit_cd VARCHAR2(2000);

CURSOR c_unit_cd(cp_unit_cd VARCHAR2) IS
SELECT DISTINCT unit_cd
FROM igs_ps_unit
WHERE unit_cd like cp_unit_cd;

 BEGIN
  l_coreq_string := p_coreq_string;
  L_comma_index := 0;
 LOOP
         l_coreq_string := LTRIM(l_coreq_string);
         L_comma_index:= INSTR(l_coreq_string,',',1 );

         EXIT when    L_comma_index =0;

         l_unit_cd :=  SUBSTR(l_coreq_string,1, L_comma_index - 1) ;

         FOR c_unit_cd_rec in c_unit_cd(l_unit_cd) LOOP
            IF l_final_coreq_string IS NOT NULL THEN
                l_final_coreq_string := l_final_coreq_string || ','|| c_unit_cd_rec.unit_cd ;
            ELSE
                l_final_coreq_string :=  c_unit_cd_rec.unit_cd ;
            END IF;
         END LOOP;
             l_coreq_string := SUBSTR( l_coreq_string, L_comma_index+1);
             EXIT when  l_coreq_string IS NULL;
  END LOOP;

  IF l_final_coreq_string IS NULL THEN
        l_final_coreq_string:= l_coreq_string;
  END IF;

return l_final_coreq_string;

end ;


FUNCTION get_coreq_units(p_uoo_id  IN NUMBER)
            RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: This function returns the string of unit codes, which have been defined
  --  as corequisite to the passed unit section. Only corequisite rule
  --  "Any co-req unit in {set of units}" is considered for this string.
  --  If the coreq rule contains any components other than this, this function will return null.
  --  The same pattern can exist more than once in the rule text; in this case we
  --  should concatenate all the unit code sets from all the occurances of this rule component
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
   /*** get the coreq rule defined at the unit section rules ***/
      Cursor c_coreq_usec(cp_uoo_id NUMBER) IS
      SELECT rul_sequence_number
      FROM igs_ps_usec_ru
      WHERE uoo_id = cp_uoo_id
      AND s_rule_call_cd = 'USECCOREQ';

         /*** get the coreq rule defined at the unit version rules ***/
     Cursor c_coreq_unit(cp_uoo_id NUMBER) IS
     SELECT rul_sequence_number
     FROM igs_ps_unit_ver_ru uvr, igs_ps_unit_ofr_opt uoo
     WHERE uvr.unit_cd = uoo.unit_cd
     AND uvr.version_number = uoo.version_number
     AND uoo_id = cp_uoo_id
     AND uvr.s_rule_call_cd = 'COREQ';

    l_rule_seq_num  igs_ps_usec_ru.rul_sequence_number%TYPE;
    l_rule_text  igs_ps_usec_ru_v.rule_text%TYPE;
    l_index NUMBER;
    l_coreq_units VARCHAR2(1000);
    l_coreq_string VARCHAR2(1000);
    l_start_index NUMBER;
    l_end_index NUMBER;
BEGIN
   l_index := 0;
   l_start_index := 0;
   l_end_index := 0;

  --check for rule at unit section level
  OPEN c_coreq_usec(p_uoo_id);
  FETCH c_coreq_usec INTO l_rule_seq_num;
    IF c_coreq_usec%FOUND THEN
      l_rule_text := IGS_RU_GEN_003.rulp_get_rule(l_rule_seq_num);
    END IF;
  CLOSE c_coreq_usec;



  --if rule is not found at unit section level, check at unit level
  IF l_rule_text IS NULL THEN
    OPEN c_coreq_unit(p_uoo_id);
    FETCH c_coreq_unit INTO l_rule_seq_num;
    IF c_coreq_unit%FOUND THEN
      l_rule_text := IGS_RU_GEN_003.rulp_get_rule(l_rule_seq_num);
    END IF;
    CLOSE c_coreq_unit;
  END IF;

  --if rule is not found at either unit section or at unit level
  IF l_rule_text IS NULL THEN
     RETURN NULL;
  END IF;

  --check if rule contains the pattern 'Any co-req unit in('
  IF(INSTR(l_rule_text,'Any co-req unit in {')<>0 ) THEN
     --check that rule does not contain any other pattern
      IF(INSTR(l_rule_text,'Any passed co-req unit in')=0
         AND INSTR(l_rule_text,'Any co-req unit set')=0
         AND INSTR(l_rule_text,'Must be enrolled')=0) THEN
           --parse the units enclosed between { }
          LOOP
                   l_index  := l_index + 1;
               l_start_index := INSTR(l_rule_text,'{',1,l_index);
                l_end_index := INSTR(l_rule_text,'}',1,l_index);
                EXIT WHEN l_start_index = 0;
                l_coreq_units := NULL;
               l_coreq_units :=  SUBSTR(l_rule_text, l_start_index+1, ( l_end_index-l_start_index)-1 );


                            IF  l_coreq_string IS NULL THEN
                                 l_coreq_string := l_coreq_units;
                            ELSE
                 l_coreq_string := l_coreq_string || ',' || l_coreq_units;
                    END IF;

                  END LOOP;

            l_coreq_string := l_coreq_string || ',' ;

            -- This string may contain unit_cd.version numbers also.
            --Hence we need to remove the version numbers from this string and only retain the unit codes
                    l_coreq_string  := parse_coreq1(p_coreq_string=>l_coreq_string);

           --This string may contain wild characters like 'unitcd%' also; hence we need to get all the units matching the criteria
          l_coreq_string  := parse_coreq2(l_coreq_string);
        RETURN l_coreq_string;
      END IF;
  END IF;

  RETURN NULL;

END get_coreq_units;

PROCEDURE get_ref_defn_lvls (  p_n_uoo_id IN NUMBER,
                                                            p_c_dfn_lvl OUT NOCOPY VARCHAR2,
                                                            p_c_unit_cd OUT NOCOPY VARCHAR2,
                                                            p_n_version OUT NOCOPY  NUMBER,
                                                            p_n_us_ref_id OUT NOCOPY NUMBER)
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: This function returns the reference code definition level
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
    CURSOR c_ref_id (cp_n_uoo_id IN NUMBER) IS
      SELECT unit_section_reference_id
      FROM igs_ps_usec_ref
      WHERE uoo_id = cp_n_uoo_id;
    rec_ref_id c_ref_id%ROWTYPE;

   CURSOR c_us_gen_ref (cp_n_ref_id IN NUMBER) IS
      SELECT 1
      FROM igs_ps_usec_ref_cd
      WHERE unit_section_reference_id =cp_n_ref_id
       AND   ROWNUM <2;

     CURSOR c_us_req_ref (cp_n_ref_id IN NUMBER) IS
      SELECT 1
      FROM igs_ps_us_req_ref_cd
      WHERE unit_section_reference_id =cp_n_ref_id
       AND   ROWNUM <2;

     CURSOR c_uv(cp_n_uoo_id IN NUMBER) IS
      SELECT unit_cd,
                      version_number
      FROM   igs_ps_unit_ofr_opt_all
      WHERE  uoo_id = cp_n_uoo_id;


      CURSOR c_uv_gen_ref(cp_c_unit_cd IN VARCHAR2, cp_n_version IN NUMBER) IS
      SELECT 1
      FROM   igs_ps_unit_ref_cd
      WHERE  unit_cd = cp_c_unit_cd
      AND       version_number = cp_n_version
      AND       ROWNUM < 2;

      CURSOR c_uv_req_ref(cp_c_unit_cd IN VARCHAR2, cp_n_version IN NUMBER) IS
      SELECT 1
      FROM   igs_ps_unitreqref_cd
      WHERE  unit_cd = cp_c_unit_cd
      AND        version_number = cp_n_version
      AND        ROWNUM <2 ;

     rec_uv c_uv%ROWTYPE;
     rec_us_gen_ref c_us_req_ref%ROWTYPE;
     l_b_us_gen boolean;
     l_b_us_req boolean;
     l_b_uv_gen boolean;
     l_b_uv_req boolean;
     l_n_temp NUMBER;

  BEGIN
       OPEN c_ref_id(p_n_uoo_id);
       FETCH c_ref_id INTO rec_ref_id;
       IF c_ref_id%FOUND THEN
           OPEN c_us_req_ref (rec_ref_id.unit_section_reference_id);
           FETCH c_us_req_ref INTO l_n_temp;
           IF c_us_req_ref%FOUND THEN
                l_b_us_req := TRUE;
           END IF;
              CLOSE c_us_req_ref;

           OPEN c_us_gen_ref (rec_ref_id.unit_section_reference_id);
           FETCH c_us_gen_ref INTO rec_us_gen_ref;
           IF c_us_gen_ref%FOUND THEN
                l_b_us_gen := TRUE;
           END IF;
           CLOSE c_us_gen_ref;

       END IF;
      CLOSE c_ref_id;

      IF (l_b_us_req IS NULL OR l_b_us_gen IS NULL) THEN
          OPEN c_uv(p_n_uoo_id);
          FETCH c_uv INTO rec_uv;
          CLOSE c_uv;
          IF l_b_us_req IS NULL THEN
               OPEN c_uv_req_ref (rec_uv.unit_cd, rec_uv.version_number);
               FETCH c_uv_req_ref INTO l_n_temp;
               IF c_uv_req_ref%FOUND THEN
                    l_b_uv_req := TRUE;
               END IF;
               CLOSE c_uv_req_ref;
          END IF;
          IF l_b_us_gen IS NULL THEN
                OPEN c_uv_gen_ref (rec_uv.unit_cd, rec_uv.version_number);
                FETCH c_uv_gen_ref INTO l_n_temp;
                IF c_uv_gen_ref%FOUND THEN
                    l_b_uv_gen := TRUE;
               END IF;
               CLOSE c_uv_gen_ref;
          END IF;
      END IF;

      IF    (l_b_us_req AND l_b_us_gen) OR
              (l_b_us_req AND l_b_us_gen IS NULL AND l_b_uv_gen IS NULL) OR
              (l_b_us_gen AND l_b_us_req IS NULL AND l_b_uv_req IS NULL) THEN
                   p_c_dfn_lvl := 'US';
                   p_n_us_ref_id := rec_ref_id.unit_section_reference_id;
      ELSIF (l_b_us_req AND l_b_uv_gen) THEN
                 p_c_dfn_lvl := 'US_REQ_UV_GEN';
                 p_n_us_ref_id := rec_ref_id.unit_section_reference_id;
                 p_c_unit_cd := rec_uv.unit_cd;
                 p_n_version := rec_uv.version_number;
      ELSIF (l_b_us_gen AND l_b_uv_req) THEN
                p_c_dfn_lvl := 'US_GEN_UV_REQ';
                p_n_us_ref_id := rec_ref_id.unit_section_reference_id;
                p_c_unit_cd := rec_uv.unit_cd;
                p_n_version := rec_uv.version_number;
       ELSE
                p_c_dfn_lvl := 'UV';
                p_c_unit_cd := rec_uv.unit_cd;
                p_n_version := rec_uv.version_number;
      END IF;

END get_ref_defn_lvls;



PROCEDURE get_definition_levels (p_n_uoo_id IN NUMBER,
                                 p_c_notes_lvl OUT NOCOPY VARCHAR2,
                                 p_c_ref_lvl OUT NOCOPY VARCHAR2,
                                 p_c_unit_cd OUT NOCOPY VARCHAR2,
                                 p_n_version OUT NOCOPY NUMBER,
                                 p_n_us_ref_id OUT NOCOPY NUMBER)
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: This procedure gets the notes, grading schema and reference codes definition levels
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
BEGIN
       get_notes_defn_lvl( p_n_uoo_id  => p_n_uoo_id,
                                           p_c_dfn_lvl => p_c_notes_lvl);

       get_ref_defn_lvls (  p_n_uoo_id    => p_n_uoo_id,
                                          p_c_dfn_lvl   => p_c_ref_lvl,
                                          p_c_unit_cd   => p_c_unit_cd,
                                          p_n_version   => p_n_version,
                                          p_n_us_ref_id => p_n_us_ref_id);


END get_definition_levels;


FUNCTION get_sua_core_disp_unit(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER )
RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function to get the unit cd/section with core indicator
  --         for a student unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS

--
--  Cursor to find the Unit Code
--
CURSOR cur_unit_cd (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT unit_cd, unit_class, CORE_INDICATOR_CODE
  FROM   igs_en_su_attempt
  WHERE   person_id = p_person_id
      AND course_cd = p_program_cd
      AND    uoo_id = p_uoo_id;

--
--  Cursor to find the meaning of lookup code CORE
--
CURSOR cur_get_lkp_meaning IS
  SELECT meaning
  FROM   igs_lookup_values lkup,  IGS_EN_SS_DISP_STPS en
  WHERE  lkup.lookup_type = 'IGS_EN_CORE_IND'
  AND    lkup.lookup_code = en.core_req_ind;


l_unit_cd                igs_ps_unit_ofr_opt.unit_cd%TYPE;
l_unit_class                igs_ps_unit_ofr_opt.unit_class%TYPE;
l_core_meaning           igs_lookup_values.meaning%TYPE;
l_core_ind_cd           igs_en_su_attempt_all.CORE_INDICATOR_CODE%TYPE;
BEGIN
  -- Get the Unit Code
  OPEN cur_unit_cd(p_uoo_id);
  FETCH cur_unit_cd INTO l_unit_cd,l_unit_class, l_core_ind_cd;
  CLOSE cur_unit_cd;

  IF l_core_ind_cd = 'CORE' THEN
     -- Get the meaning of lookup code
     OPEN cur_get_lkp_meaning;
     FETCH cur_get_lkp_meaning INTO l_core_meaning;
     CLOSE cur_get_lkp_meaning;

     RETURN l_unit_cd||'/'||l_unit_class||'('||l_core_meaning||')';
  ELSE
     RETURN l_unit_cd||'/'||l_unit_class;
  END IF;
END get_sua_core_disp_unit;


FUNCTION get_total_cart_credits(p_personid IN NUMBER,
                                p_course_cd IN VARCHAR2,
                                p_term_cal_type IN VARCHAR2,
                                p_term_seq_num IN NUMBER) RETURN NUMBER
------------------------------------------------------------------
  --Created by  : rvangala
  --Date created: 24-May-2005
  --
  --Purpose: Function returns the total credit points in the enrollment cart
  --         for a term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
AS
    --cursor to fetch the total credits from planning sheet unit attempts with cart_error_flag=Y
    CURSOR c_total_cart_credits(cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
    SELECT  SUM(igs_ss_enr_details.get_apor_credits ( uoo_id, override_enrolled_cp,
                 cp_term_cal_type,cp_term_seq_num)) apor_cp
    FROM IGS_EN_PLAN_UNITS pls
    WHERE pls.cart_error_flag= 'Y'
    AND  pls.person_id = p_personid
    AND  pls.course_cd = p_course_cd
    AND  pls.term_cal_type = cp_term_cal_type
    AND  pls.term_ci_sequence_number = cp_term_seq_num;

    --cursor to fetch the total credits for all unconfirmed unit attempts from student unit attempts
    CURSOR c_total_unconfirm_credits (cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
    SELECT   SUM(igs_ss_enr_details.get_apor_credits ( uoo_id, override_enrolled_cp,
                 cp_term_cal_type,cp_term_seq_num)) apor_cp
    FROM IGS_EN_SU_ATTEMPT sua
    WHERE sua.unit_attempt_status = 'UNCONFIRM'
    AND sua.person_id = p_personid
    AND  sua.course_cd = p_course_cd
    AND  (sua.cal_type , sua.ci_sequence_number) in (select teach_cal_type, teach_ci_sequence_number from igs_ca_teach_to_load_v where
                                                        load_cal_type = cp_term_cal_type and load_ci_sequence_number = cp_term_seq_num)
    AND ss_source_ind <> 'S';


   l_total_cart_credits NUMBER;
   l_total_unconfirm_credits NUMBER;

BEGIN

   -- fetch the total credits points of planning sheet cart units
   OPEN c_total_cart_credits(p_term_cal_type,p_term_seq_num);
   FETCH c_total_cart_credits INTO l_total_cart_credits;
   CLOSE c_total_cart_credits;

   --fetch the total credit points of unconfirmed unit attempts
   OPEN c_total_unconfirm_credits(p_term_cal_type,p_term_seq_num);
   FETCH c_total_unconfirm_credits INTO l_total_unconfirm_credits;
   CLOSE c_total_unconfirm_credits;

   --return the sum of planned cart units and unconfirmed unit attempts
   RETURN NVL(l_total_cart_credits,0) + NVL(l_total_unconfirm_credits,0);

END;

FUNCTION get_sca_unit_sets( p_person_id IN NUMBER ,
                            p_program_cd IN VARCHAR2 ,
                            p_term_cal_type IN VARCHAR2,
                            p_term_sequence_number IN NUMBER) RETURN VARCHAR2 AS
------------------------------------------------------------------
  --Created by  : Somasekar.IDC
  --Date created: 12-July-2005
  --
  --Purpose: Function returns the total credit points in the enrollment cart
  --         for a term
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
    -- cursor to fetch census date values
    CURSOR c_term_cen_dates (cp_cal_type IN VARCHAR2, cp_cal_seq_number IN NUMBER) IS
       SELECT   NVL (absolute_val,
                  igs_ca_gen_001.calp_get_alias_val (
                  dai.dt_alias,
                  dai.sequence_number,
                  dai.cal_type,
                  dai.ci_sequence_number
                      )
        ) AS term_census_date
        FROM     igs_ge_s_gen_cal_con sgcc,
                 igs_ca_da_inst dai
        WHERE    sgcc.s_control_num = 1
        AND      dai.dt_alias = sgcc.census_dt_alias
        AND      dai.cal_type = cp_cal_type
        AND      dai.ci_sequence_number = cp_cal_seq_number
        ORDER by 1 desc;

    -- cursor to fetch the unit set title
    CURSOR c_us_title (cp_person_id NUMBER,
                       cp_program_cd VARCHAR2,
                       cp_term_census_date DATE,
                       cp_unit_set  IN VARCHAR2,
                       cp_version   IN NUMBER) IS
       SELECT NVL(susa.override_title, us.title) title,
              NVL(susa.rqrmnts_complete_dt,NVL(susa.end_dt, cp_term_census_date)) end_date
       FROM  igs_as_su_setatmpt susa ,
             igs_en_unit_set us ,
             igs_en_unit_set_cat usc
       WHERE susa.person_id =  cp_person_id
       AND   susa.course_cd = cp_program_cd
       AND   susa.student_confirmed_ind = 'Y'
       AND  cp_term_census_date
            BETWEEN susa.selection_dt
            AND   NVL(susa.rqrmnts_complete_dt,NVL(susa.end_dt, cp_term_census_date))
       AND   susa.unit_set_cd = us.unit_set_cd
       AND   us.unit_set_cat = usc.unit_set_cat
       AND   usc.s_unit_set_cat  <> 'PRENRL_YR'
       AND   susa.unit_set_cd = cp_unit_set
       AND   susa.us_version_number = cp_version
       ORDER BY end_date, susa.selection_dt DESC;

    CURSOR c_unit_sets (cp_person_id IN NUMBER, cp_program_cd IN VARCHAR2) IS
       SELECT  DISTINCT susa.unit_set_cd, susa.us_version_number
       FROM    igs_as_su_setatmpt susa
       WHERE   susa.person_id =  cp_person_id
       AND   susa.course_cd = cp_program_cd
       AND   susa.student_confirmed_ind = 'Y';

    l_pre_title VARCHAR2(2000);
    l_oth_title VARCHAR2(2000);
    l_c_temp    igs_as_su_setatmpt.override_title%TYPE;
    l_c_title   VARCHAR2(4000);

  BEGIN
    l_pre_title := get_stud_yop_unit_set ( p_person_id            => p_person_id,
                                           p_program_cd           => p_program_cd,
                                           p_term_cal_type        =>p_term_cal_type,
                                           p_term_sequence_number => p_term_sequence_number);

    FOR rec_term_cen_dates IN c_term_cen_dates(p_term_cal_type, p_term_sequence_number) LOOP
        FOR rec_unit_sets IN c_unit_sets(p_person_id, p_program_cd) LOOP
            l_c_temp := NULL;
            FOR rec_us_title IN c_us_title( p_person_id, p_program_cd,rec_term_cen_dates.term_census_date,rec_unit_sets.unit_set_cd, rec_unit_sets.us_version_number) LOOP
                l_c_temp := rec_us_title.title;
                EXIT;
            END LOOP;
            IF l_c_temp IS NOT NULL THEN
               l_oth_title := l_oth_title || ',' || l_c_temp;
            END IF;
        END LOOP;
    END LOOP;
    IF l_pre_title IS NOT NULL AND l_oth_title IS NOT NULL THEN
        l_c_title := l_pre_title || ',' || SUBSTR(l_oth_title,2);
    ELSIF l_pre_title IS NOT NULL THEN
        l_c_title := l_pre_title;
    ELSIF l_oth_title IS NOT NULL  THEN
        l_c_title := SUBSTR(l_oth_title,2);
    ELSE
        l_c_title := NULL;
    END IF;

    RETURN l_c_title;

  END get_sca_unit_sets;

  FUNCTION get_sup_sub_text (
    p_uoo_id IN NUMBER,
    p_sup_uoo_id IN NUMBER,
    p_relation_type IN VARCHAR2
  )  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Somasekar, Oracle IDC
  --Date created: 12-July-2005
  --
  --Purpose: This Function returns teh relation type of the unit section.
  --if the parameter p_uoo_Id is superior , it returns 'SUPERIOR'
  --if subordiante it returns 'SBORDINATE' concatenated to the superior unit code
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR c_lkups (CP_LOOKUP_CODE IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE) IS
    SELECT meaning
    FROM igs_lookup_values
    WHERE lookup_code = cp_lookup_code
    AND lookup_type = 'UOO_RELATION_TYPE';

  CURSOR c_sup_unit_cd (CP_SUP_UOO_ID IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
    SELECT unit_cd
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = cp_sup_uoo_id;

  v_sup_unit_cd IGS_PS_UNIT_VER.UNIT_CD%TYPE;
  l_meaning IGS_LOOKUPS_VIEW.MEANING%TYPE;

  BEGIN

    IF NVL(p_relation_type,'NONE') = 'NONE' THEN
      RETURN NULL;
    END IF;

    OPEN c_lkups(p_relation_type);
    FETCH c_lkups INTO l_meaning;
    CLOSE c_lkups;

    IF p_relation_type = 'SUPERIOR' THEN
      RETURN '('||l_meaning||')';
    ELSIF p_relation_type = 'SUBORDINATE' THEN

      IF p_sup_uoo_id IS NOT NULL THEN
        OPEN c_sup_unit_cd(p_sup_uoo_id);
        FETCH c_sup_unit_cd INTO v_sup_unit_cd;
        IF c_sup_unit_cd%FOUND THEN
          CLOSE c_sup_unit_cd;
          RETURN '('|| FND_MESSAGE.GET_STRING('IGS','IGS_EN_SUBORDINATE_TO') || ' ' || v_sup_unit_cd||')';
        ELSE
          CLOSE c_sup_unit_cd;
          RETURN NULL;
        END IF;
      ELSE
        RETURN NULL;
      END IF;
    END IF;

  END get_sup_sub_text;

FUNCTION  is_enr_open(p_load_cal IN varchar2,
                      p_load_seq_num IN Number,
                      p_d_date IN DATE,
                      p_n_uoo_id IN NUMBER)
RETURN VARCHAR2
------------------------------------------------------------------
  --Created by  : vijrajag
  --Date created: 04-July-2005
  --
  --Purpose: Function to check whether enrollment open (record cutoff is open)
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
l_c_message VARCHAR2 (30);
l_n_uoo_id  NUMBER;
BEGIN
    IF igs_en_gen_004.enrp_get_rec_window(p_load_cal, p_load_seq_num, p_d_date,  p_n_uoo_id, l_c_message) THEN
      IF l_c_message IS NULL THEN
        RETURN 'Y';
      END IF;
     END IF;
     RETURN 'N';
END is_enr_open;

FUNCTION get_total_cart_units(p_personid NUMBER,
                              p_course_cd VARCHAR2,
                              p_term_cal_type VARCHAR2,
                              p_term_seq_num NUMBER)
RETURN NUMBER
------------------------------------------------------------------
  --Created by  : Siva Gurusamy, Oracle IDC
  --Date created: 12-Aug-05
  --
  --Purpose:
  --   This is a new function to get the total attempted units in the cart for a student, program and term
  --   Implementation:
  --     1. Get the total units in the planning sheet with cart error flag as Y for the student in selected program and term.
  --     2. Get the total units of all UNCONFIRM unit sections in the student unit attempt for the student in selected program and term.
  --     3. Sum and return the total units from the planning sheet and student unit attempts
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who       When        What
  --sgurusam  12-Aug-05   Created
  -------------------------------------------------------------------
AS
    --cursor to fetch the total planning sheet unit attempts with cart_error_flag=Y
    CURSOR c_total_cart_units(cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
    SELECT  count(uoo_id)
    FROM IGS_EN_PLAN_UNITS pls
    WHERE pls.cart_error_flag= 'Y'
    AND  pls.person_id = p_personid
    AND  pls.course_cd = p_course_cd
    AND  pls.term_cal_type = cp_term_cal_type
    AND  pls.term_ci_sequence_number = cp_term_seq_num;

    --cursor to fetch the total unconfirmed unit attempts
    CURSOR c_total_unconfirm_units(cp_term_cal_type VARCHAR2, cp_term_seq_num NUMBER) IS
    SELECT count(uoo_id)
    FROM   IGS_EN_SU_ATTEMPT sua
    WHERE  sua.unit_attempt_status = 'UNCONFIRM'
    AND    sua.person_id = p_personid
    AND    sua.course_cd = p_course_cd
    AND    sua.ss_source_ind <> 'S'
    AND    (sua.cal_type , sua.ci_sequence_number) in (SELECT teach_cal_type, teach_ci_sequence_number
                                                       FROM   igs_ca_teach_to_load_v
                                                       WHERE  load_cal_type = cp_term_cal_type
                                                       AND    load_ci_sequence_number = cp_term_seq_num);



   l_total_cart_units NUMBER;
   l_total_unconfirm_units NUMBER;
   l_total_units NUMBER;

BEGIN
   l_total_units :=0;

   -- fetch the total planning sheet unit attempts
   OPEN c_total_cart_units(p_term_cal_type,p_term_seq_num);
   FETCH c_total_cart_units INTO l_total_cart_units;
   CLOSE c_total_cart_units;

   --fetch the total unconfirmed unit attempts
   OPEN c_total_unconfirm_units(p_term_cal_type,p_term_seq_num);
   FETCH c_total_unconfirm_units INTO l_total_unconfirm_units;
   CLOSE c_total_unconfirm_units;

   IF l_total_cart_units IS NULL THEN
     l_total_cart_units := 0;
   END IF;

   IF l_total_unconfirm_units IS NULL THEN
     l_total_unconfirm_units := 0;
   END IF;

   --return the sum of planned and unconfirmed units
   l_total_units := l_total_cart_units + l_total_unconfirm_units;
   RETURN l_total_units;

END get_total_cart_units;



END igs_ss_enr_details;

/
