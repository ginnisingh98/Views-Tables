--------------------------------------------------------
--  DDL for Package Body IGS_HE_UV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_UV_PKG" AS
/*  $Header: IGSHE18B.pls 120.1 2006/02/07 14:53:31 jbaber noship $
 | HISTORY                                                                 |
 |                                                                         |
 | Date       Name              Comments                                   |
 | ---------  ----------------  ------------------------------             |
 | 02-Jan-02   M. S. GARCHA     Created                                    |
 | 08-Feb-02   A Kataria        Added TBH's                                |
 | 09-Apr-02   sbaliga          Changed code corresponding to the addition |
 |                              of location_cd to igs_he_st_unt_vs_all     |
 |                              table as part of #2278825                  |
 | 26-Jan-05   jbaber           Modified x_c2 for HE355 - Org Unit Cost    |
 |                              Centre Link                                |
 | 24-Nov-05   jbaber           Added exclude_flag to x_c1 for HE305       |
 +=========================================================================+
 */

  PROCEDURE copy_unit_version (
     p_c_old_unit_cd		IN      VARCHAR2
    ,p_n_old_version_number     IN      NUMBER
    ,p_c_new_unit_cd		IN	VARCHAR2
    ,p_n_new_version_number	IN	NUMBER
    ,p_n_status			OUT NOCOPY     NUMBER
    ,p_c_message                OUT NOCOPY     VARCHAR2
    ) IS

    x_err_msg           VARCHAR2(240);
    x_seq_id		NUMBER := '';
    x_org_id            NUMBER(15);
    l_location_cd	igs_he_st_unt_vs.location_cd%TYPE;

    CURSOR x_c1 IS
    SELECT  rowid
	   ,prop_of_teaching_in_welsh
	   ,credit_transfer_scheme
	   ,module_length
	   ,proportion_of_fte
	   ,location_cd
	   ,exclude_flag
    FROM   igs_he_st_unt_vs
    WHERE unit_cd = p_c_old_unit_cd
    AND   version_number = p_n_old_version_number
    AND NOT EXISTS (
			SELECT 'x'
			FROM   igs_he_st_unt_vs
			WHERE unit_cd = p_c_new_unit_cd
			AND   version_number = p_n_new_version_number
		   );

    CURSOR x_c2 IS
    SELECT  rowid
	   ,org_unit_cd
	   ,cost_centre
	   ,subject
	   ,proportion
    FROM   igs_he_unt_ou_cc
    WHERE unit_cd = p_c_old_unit_cd
    AND   version_number = p_n_old_version_number
    AND NOT EXISTS (
			SELECT 'x'
			FROM   igs_he_unt_ou_cc
			WHERE  unit_cd = p_c_new_unit_cd
			AND   version_number = p_n_new_version_number
		   );


  BEGIN

    p_n_status := 0;

    IF p_c_old_unit_cd is NULL OR
       p_n_old_version_number is NULL OR
       p_c_new_unit_cd is NULL OR
       p_n_new_version_number is NULL
    THEN
       p_n_status := 2;
       p_c_message := 'IGS_HE_INV_PARAMS';
       RETURN;
    END IF;

    x_org_id := IGS_GE_GEN_003.GET_ORG_ID;

    FOR x_c1_rec IN x_c1 LOOP
       IF  p_c_old_unit_cd = p_c_new_unit_cd THEN
          l_location_cd:= x_c1_rec.location_cd;
       ELSE
       	   l_location_cd:= NULL;
       END IF;

	-- p_c_message := 'WILL NOW INSERT INTO IGS_HE_ST_UNT_VS_ALL';
	-- IGSWI24B.pls
        IGS_HE_ST_UNT_VS_ALL_PKG.Insert_Row(
             X_ROWID                     =>  x_c1_rec.rowid,
             X_HESA_ST_UNT_VS_ID         =>  x_seq_id,--Sequence generated in handler!!
             X_ORG_ID                    =>  x_org_id,
             X_UNIT_CD                   =>  p_c_new_unit_cd,
             X_VERSION_NUMBER            =>  p_n_new_version_number,
             X_PROP_OF_TEACHING_IN_WELSH =>  x_c1_rec.prop_of_teaching_in_welsh,
             X_CREDIT_TRANSFER_SCHEME    =>  x_c1_rec.credit_transfer_scheme,
             X_MODULE_LENGTH             =>  x_c1_rec.module_length,
             X_PROPORTION_OF_FTE         =>  x_c1_rec.proportion_of_fte,
             X_LOCATION_CD		 =>  l_location_cd,
             X_MODE                      =>  'R',
             X_EXCLUDE_FLAG              =>  x_c1_rec.exclude_flag
             );
    END LOOP;


    FOR x_c2_rec IN x_c2 LOOP

	-- IGSWI46B.pls
	-- p_c_message := 'WILL NOW INSERT INTO IGS_HE_ST_UV_CC_ALL';
        IGS_HE_UNT_OU_CC_PKG.Insert_Row(
                    X_ROWID                     =>  x_c2_rec.rowid,
                    X_HESA_UNIT_CC_ID           =>  x_seq_id, --Sequence generated in handler!!
                    X_UNIT_CD                   =>  p_c_new_unit_cd,
                    X_VERSION_NUMBER            =>  p_n_new_version_number,
                    X_ORG_UNIT_CD               =>  x_c2_rec.org_unit_cd,
                    X_COST_CENTRE               =>  x_c2_rec.cost_centre,
                    X_SUBJECT                   =>  x_c2_rec.subject,
                    X_PROPORTION                =>  x_c2_rec.proportion,
                    X_MODE                      => 'R'
                                         );

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
	 p_n_status := 2;
         x_err_msg := SUBSTR(SQLERRM, 1, 240);
         RAISE_APPLICATION_ERROR (-20000, x_err_msg);
         App_Exception.Raise_Exception;
  END copy_unit_version;

END IGS_HE_UV_PKG;

/
