--------------------------------------------------------
--  DDL for Package Body IGS_OR_INST_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INST_IMP_001" AS
/* $Header: IGSOR14B.pls 120.7 2006/06/28 13:10:48 gmaheswa ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- kumma      14-JUN-2002     Uncommented call to message IGS_OR_INST_IMP_SUCC , 2410165
  -- kumma      08-JUL-2002     Bug 2446067, In all the three procedures numericAltidcomp, simpleAltidcomp and  exactAltidcomp,
  --                      Created two cursors c_cwlk_master_present and c_cwlk_detail_id.
  --                  Used these cursor before every call to IGS_OR_INST_IMP_002.Update_Crosswalk_master which includes
  --                  existing institution cd
  --                  and IGS_OR_INST_IMP_002.Create_Crosswalk_master.
  --                  In the Exception section of numericAltidcomp procedure, checked for the invalid_number exception,
  --                  as the alternate_id_value for this procedure should be neumeric, if it is not so then
  --                  we need to log a message stating that it should be neumeric only
  --pkpatel     26-OCT-2002   Bug No: 2613704
  --                          Modified the validation for INST_PRIORITY_CODE_ID, GOVT_INSTITUTION_CD, INST_CONTROL_TYPE to refer
  --                          the new lookups instead of the tables.
  -- ssawhney   2nd jan       No of updates reduced, performance tuning done, gather stats function used.
  -- ssaleem    24-SEP-03     The following changes have been done for IGS.L
  --                          1. Logging mechanism introduced, FND_FILE.PUT_LINE replaced with methods in FND_LOG package
  --                             log  writer procedure modified for this purpose and package level variables declared, intialised
  --                             to control logging.
  --                          2. Cursors that utilise variables in SELECT statements are replaced with cursor parameters
  --                          3. Gather statistics done for IGS_OR_ADRUSGE_INT table
  --                          4. New procedure validate_inst_code written to validate new and exst institution codes with
  --                             crosswalk institution code
  --                          5. New procedure delete_log_int_rec written to take statistics, log and delete completed
  --                             records in the interface tables. The IGS_OR_INST_INT table will also be updated be updated with
  --                             status 4 if there are any discrepency in the child records
  --mmkumar    19-JUL-2005   modified cursors c_inst_present, c_party_id to use igs_pe_hz_parties instead of using hz_parties
  --gmaheswa   22-Jun-06     Bug 5189180: Modified logging logic to log warning records also.
  -------------------------------------------------------------------------------------------
  g_records_processed  NUMBER(5) := 0;

PROCEDURE log_writer(p_which_rec IN varchar2,
                     p_error_code IN igs_or_inst_int.error_code%TYPE,
                     p_error_text igs_or_inst_int.error_text%TYPE) AS

 cursor c_error_log(p_err_cd igs_lookups_view.lookup_code%TYPE, cp_lookup_type igs_lookups_view.lookup_type%TYPE) is
  select rpad(lookup_code,10)||meaning LINEX from igs_lookups_view where lookup_code = p_err_cd
  and lookup_type = cp_lookup_type;

  v_error_log c_error_log%ROWTYPE;
BEGIN

  open c_error_log(p_error_code,'IMPORT_INST_ERROR_CODE');
  fetch c_error_log into v_error_log;
  close c_error_log;

   FND_MESSAGE.SET_NAME('IGS','IGS_OR_INST_IMP_FAIL');
   FND_MESSAGE.SET_TOKEN('INT_ID',p_which_rec);
   FND_MESSAGE.SET_TOKEN('ERROR_CODE',v_error_log.linex);
   FND_LOG.STRING_WITH_CONTEXT (fnd_log.level_exception,
                                'igs.plsql.igs_or_inst_imp_001.imp_or_institution.' || p_error_code,
                                fnd_message.get || '-' || p_error_text,NULL,NULL,NULL,NULL,NULL,g_request_id);

END log_writer;

-- Function to implement column lebel validation for interface table data.

FUNCTION validate_field_level_data(p_inst_rec IN IGS_OR_INST_INT%ROWTYPE,
                   ret_err_cd OUT NOCOPY IGS_OR_INST_INT.ERROR_CODE%TYPE)
/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         25-OCT-2002    Bug No: 2613704
  ||                                 Modified the validation for INST_PRIORITY_CODE_ID, GOVT_INSTITUTION_CD, INST_CONTROL_TYPE to refer
  ||                                 the new lookups instead of the tables.
  ||  gmaheswa        12-SEP-2003    Bug No: 2863933
  ||                                 Modified local institution indicator to be equal to N
  ||  (reverse chronological order - newest change first)
*/
return boolean is

 CURSOR c_lookup_type(cp_lookup_code igs_lookup_values.lookup_code%TYPE,
                      cp_lookup_type igs_lookup_values.lookup_type%TYPE,
                      cp_enabled_flag igs_lookup_values.enabled_flag%TYPE) IS
 SELECT 'X'
 FROM   igs_lookup_values where
        lookup_code = cp_lookup_code AND
        lookup_type = cp_lookup_type AND
        enabled_flag = cp_enabled_flag;

 c_lookup_type_rec c_lookup_type%rowtype;

cursor c_institution_type(cp_institution_type igs_or_inst_int.institution_type%TYPE,
                          cp_close_ind igs_or_org_inst_type.close_ind%TYPE) is
 select 'X' from
 igs_or_org_inst_type where --ssawhney, view to table
 institution_type = cp_institution_type
 and close_ind = cp_close_ind;

 c_institution_type_rec c_institution_type%rowtype;

cursor c_institution_stat(cp_institution_stat igs_or_inst_int.institution_status%TYPE,
                          cp_close_ind igs_or_inst_stat.closed_ind%TYPE) is select 'X' from
 igs_or_inst_stat where
 institution_status = cp_institution_stat
 and closed_ind = cp_close_ind;

 c_institution_stat_rec c_institution_stat%rowtype;

cursor c_sec_school_loc_id(cp_sec_school_location_id IGS_OR_INST_INT.sec_school_location_id%TYPE,
                           cp_class igs_ad_code_classes.class%TYPE,
                           cp_closed_ind igs_ad_code_classes.closed_ind%TYPE) is
select 'X' from
  igs_ad_code_classes acc  --ssawhney, view to table
  where class = cp_class and
  NVL(closed_ind,cp_closed_ind)=cp_closed_ind and
  code_id= cp_sec_school_location_id;

c_sec_school_loc_id_rec c_sec_school_loc_id%ROWTYPE;

BEGIN
--Validation for LOCAL_INSTITUTION_IND field
if p_inst_rec.local_institution_ind is NOT NULL THEN
  if p_inst_rec.local_institution_ind <>'N' THEN
    ret_err_cd:='E010';
    return false;
  end if;
end if;

--Validation for OS_IND field
if p_inst_rec.os_ind is NOT NULL THEN
  if p_inst_rec.os_ind <> 'N' THEN
    ret_err_cd:='E011';
    return false;
  end if;
end if;

--Validation for GOVT_INSTITUTION_CD field
IF p_inst_rec.govt_institution_cd IS NOT NULL THEN
open c_lookup_type(p_inst_rec.govt_institution_cd,'OR_INST_GOV_CD','Y');
fetch c_lookup_type into c_lookup_type_rec;
if c_lookup_type%NOTFOUND THEN
 ret_err_cd:='E012';
 return false;
end if;
close c_lookup_type;
END IF;

--Validation for INST_CONTROL_TYPE field
open c_lookup_type(p_inst_rec.inst_control_type,'OR_INST_CTL_TYPE','Y');
fetch c_lookup_type into c_lookup_type_rec;
if c_lookup_type%NOTFOUND THEN
 ret_err_cd:='E013';
 return false;
end if;
close c_lookup_type;

--Validation for INSTITUTION_TYPE field
open c_institution_type(p_inst_rec.institution_type,'N');
fetch c_institution_type into c_institution_type_rec;
if c_institution_type%NOTFOUND THEN
 ret_err_cd:='E014';
 return false;
end if;
close c_institution_type;

--Validation for INSTITUTION_STATUS field
open c_institution_stat(p_inst_rec.institution_status,'N');
fetch c_institution_stat into c_institution_stat_rec;
if c_institution_stat%NOTFOUND THEN
 ret_err_cd:='E015';
 return false;
end if;
close c_institution_stat;

--Validation for PRIORITY_CD field
IF p_inst_rec.INST_PRIORITY_CD IS NOT NULL THEN
open c_lookup_type(p_inst_rec.INST_PRIORITY_CD,'OR_INST_PRIORITY_CD','Y');
fetch c_lookup_type into c_lookup_type_rec;
if c_lookup_type%NOTFOUND THEN
 ret_err_cd:='E016';
 return false;
end if;
close c_lookup_type;
END IF;

--Validation for SEC_SCHOOL_LOCATION_ID field
IF p_inst_rec.sec_school_location_id IS NOT NULL THEN
open c_sec_school_loc_id(p_inst_rec.sec_school_location_id,'SEC_SCHOOL_LOCATION','N');
fetch c_sec_school_loc_id into c_sec_school_loc_id_rec;
if c_sec_school_loc_id%NOTFOUND THEN
 ret_err_cd:='E017';
 return false;
end if;
close c_sec_school_loc_id;
END IF;

return true;
END validate_field_level_data;

PROCEDURE imp_or_institution(
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY NUMBER,
    P_DATE IN VARCHAR2,
    P_BATCH_ID IN NUMBER,
    P_DATA_SOURCE IN VARCHAR2,
    P_DS_MATCH IN VARCHAR2,
    P_NUMERIC IN VARCHAR2,
    P_ADDR_USAGE IN VARCHAR2,
    P_PERSON_TYPE IN VARCHAR2,
    P_ORG_ID IN NUMBER)
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 13-JUL-2001
  Purpose : This Procedure calls the required procedure depending
            on the parameters passed to the job
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  gmaheswa      17-Jan-06        4938278: disable Business Events before starting bulk import process and enable after import.
				 Call IGS_PE_WF_GEN. ADDR_BULK_SYNCHRONIZATION to raise bulk address change notification.
  ***************************************************************/

   l_status       VARCHAR2(5);
   l_industry     VARCHAR2(5);
   l_schema       VARCHAR2(30);
   l_return       BOOLEAN;
   l_owner        VARCHAR2(30);

BEGIN

   IF FND_LOG.test(FND_LOG.LEVEL_EXCEPTION,'igs.plsql.igs_or_inst_imp_001') THEN
      gb_write_exception_log1 := TRUE;
   ELSE
      gb_write_exception_log1 := FALSE;
   END IF;

   IF FND_LOG.test(FND_LOG.LEVEL_EXCEPTION,'igs.plsql.igs_or_inst_imp_002') THEN
     gb_write_exception_log2 := TRUE;
   ELSE
     gb_write_exception_log2 := FALSE;
   END IF;

   IF FND_LOG.test(FND_LOG.LEVEL_EXCEPTION,'igs.plsql.igs_or_inst_imp_003') THEN
     gb_write_exception_log3 := TRUE;
   ELSE
     gb_write_exception_log3 := FALSE;
   END IF;

   g_request_id := FND_GLOBAL.conc_request_id;

   IGS_GE_GEN_003.Set_org_id(p_org_id);

   --Disable Business Event before running Bulk Process
   IGS_PE_GEN_003.TURNOFF_TCA_BE (
      P_TURNOFF  => 'Y'
   );

   l_return := fnd_installation.get_app_info('IGS', l_status, l_industry, l_schema);

   IF l_schema IS NOT NULL THEN
    -- gather statistics as the new INTERFACE batch program standard.
    -- 'IGS_OR_ADRUSGE_INT,IGS_OR_ADR_INT,IGS_OR_INST_CON_INT,IGS_OR_INST_CPHN_INT,IGS_OR_INST_INT,IGS_OR_INST_NTS_INT,IGS_OR_INST_SDTL_INT,
    --  IGS_OR_INST_STAT_INT,IGS_OR_CWLK_INT,IGS_OR_CWLK_DTL_INT,IGS_OR_INST_BTCH_INT';
    -- IGS.L change, added gather statistics for table IGS_OR_ADR_INT

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_ADR_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_ADRUSGE_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_CON_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_CPHN_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_NTS_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_SDTL_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_INST_STAT_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_CWLK_INT',cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,tabname => 'IGS_OR_CWLK_DTL_INT',cascade => TRUE);
   END IF;

    --
    IF p_ds_match IS NULL AND p_numeric = 'N' THEN
          FND_MESSAGE.Set_Name('IGS','IGS_OR_SIMPLE_ALT_ID');
          FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
          simpleAltidcomp(p_batch_id,p_data_source,p_addr_usage,p_person_type);
    ELSIF p_ds_match IS NOT NULL AND p_numeric = 'N' THEN
          FND_MESSAGE.Set_Name('IGS','IGS_OR_EXACT_ALT_ID');
          FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
          exactAltidcomp(p_batch_id,p_data_source,p_ds_match,p_addr_usage,p_person_type);
    ELSIF p_ds_match IS NOT NULL AND p_numeric = 'Y' THEN
          FND_MESSAGE.Set_Name('IGS','IGS_OR_NUMERIC_ALT_ID');
          FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
          numericAltidcomp(p_batch_id,p_data_source,p_ds_match,p_addr_usage,p_person_type);
    ELSE
          FND_MESSAGE.Set_Name('IGS','IGS_AD_INVALID_PARAM_COMB');
          FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
    END IF;

    --Raise Bulk address process notification
    IGS_PE_WF_GEN.ADDR_BULK_SYNCHRONIZATION(IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS);

    --Enable Business Event before quiting Bulk Process
    IGS_PE_GEN_003.TURNOFF_TCA_BE (
         P_TURNOFF  => 'N'
    );
 EXCEPTION
     WHEN OTHERS THEN
       retcode := 2;
       IF FND_LOG.test(FND_LOG.LEVEL_EXCEPTION,'igs.plsql.igs_or_inst_imp_001') THEN
               fnd_log.string_with_context (fnd_log.level_exception,
                                            'igs.plsql.igs_or_inst_imp_001.imp_or_institution.MainProc',
                                            ' ' || SQLERRM,NULL,NULL,NULL,NULL,NULL,g_request_id);
       END IF;

       --Enable Business Event before quiting Bulk Process
       IGS_PE_GEN_003.TURNOFF_TCA_BE (
           P_TURNOFF  => 'N'
       );
       IGS_GE_MSG_STACK.Conc_Exception_Hndl;
END imp_or_institution;

PROCEDURE simpleAltidcomp(
        p_batch_id  IN NUMBER,
    p_data_source IN VARCHAR2,
    p_addr_usage IN VARCHAR2,
    p_person_type IN VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 13-JUL-2001
  Purpose : This Procedure imports records from the Institution
           Interface Table to the institutions table if the user
       has choosen Simple Alternate Id comparison
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         6-JAN-2003      Bug No: 2528605
                                  Added the create_alternate_id procedures for the all the conditions.
                                                                  Made the data_source_value as UPPER at the beginning and initialize the record varuable to NULL
  kumma           08-JUL-2002     Bug 2446067, Created two cursors c_cwlk_master_present and c_cwlk_detail_id.
                  Used these cursor before every call to IGS_OR_INST_IMP_002.Update_Crosswalk_master
                  which includes the existing institution cd and IGS_OR_INST_IMP_002.Create_Crosswalk_master.
  ***************************************************************/
       CURSOR c_inst_cur (cp_data_source VARCHAR2,
                          cp_batch_id NUMBER,
                          cp_status IGS_OR_INST_INT.STATUS%TYPE) IS
       SELECT IO.*
       FROM IGS_OR_INST_INT IO
       WHERE IO.STATUS = cp_status AND
             IO.DATA_SOURCE_ID = cp_data_source AND
             IO.BATCH_ID = TO_NUMBER(cp_batch_id) ;

         p_inst_rec c_inst_cur%ROWTYPE;

       CURSOR  c_inst_code ( cp_data_source VARCHAR2 , cp_data_src_val VARCHAR2 ) IS
       SELECT orcv.crosswalk_id, orcv.crosswalk_dtl_id, orcv.inst_code
       FROM IGS_OR_CWLK_V ORCV
       WHERE ORCV.ALT_ID_TYPE = cp_data_source AND
             ORCV.ALT_ID_VALUE = cp_data_src_val ;

     --mmkumar, party number impact, changed the folllowing cursor to verify from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_inst_present ( cp_inst_code VARCHAR2 ) IS
       SELECT 'Y'
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;

     --mmkumar, party number impact, changed the folllowing cursor to pick party_id from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_party_id ( cp_inst_code VARCHAR2 ) IS
       SELECT party_id
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;

     -- kumma, 2446067
     -- Created the following cursor to check whether the code already exists in the cross walk master
     CURSOR c_cwlk_master_present (cp_inst_code VARCHAR2) IS
     SELECT institution_code, crosswalk_id
     FROM IGS_OR_CWLK
     WHERE institution_code = cp_inst_code;

       l_Count NUMBER;
       l_Instcount NUMBER;
       l_Newinstcd igs_or_institution.institution_cd%TYPE;
       l_Errind VARCHAR2(1);
       l_Crswlkid igs_or_cwlk.crosswalk_id%TYPE;
       l_party_id hz_parties.party_id%TYPE;
       l_cwlkinst_rec c_inst_code%ROWTYPE;
       l_val_err igs_or_inst_int.error_code%TYPE;
       l_error_code igs_or_inst_int.error_code%TYPE := null;  --ssawhney initialised
       l_error_text igs_or_inst_int.error_text%TYPE := null;  --ssawhney initialised
       l_exists     VARCHAR2(1);
       --kumma
       l_cwlk_master_present c_cwlk_master_present%ROWTYPE;


BEGIN
       FOR v_inst_rec IN c_inst_cur(p_data_source,p_batch_id,'2') LOOP

          g_records_processed := g_records_processed + 1;

            l_cwlkinst_rec.crosswalk_id := NULL;
                        l_cwlkinst_rec.crosswalk_dtl_id := NULL;
                        l_cwlkinst_rec.inst_code := NULL;
            v_inst_rec.data_source_value := UPPER(v_inst_rec.data_source_value);

	    v_inst_rec.local_institution_ind := UPPER(v_inst_rec.local_institution_ind);
    	    v_inst_rec.os_ind := UPPER(v_inst_rec.os_ind);
    	    v_inst_rec.govt_institution_cd := UPPER(v_inst_rec.govt_institution_cd);
    	    v_inst_rec.inst_control_type := UPPER(v_inst_rec.inst_control_type);
    	    v_inst_rec.inst_priority_cd := UPPER(v_inst_rec.inst_priority_cd);

          OPEN c_inst_code (v_inst_rec.data_source_id, v_inst_rec.data_source_value);
          FETCH c_inst_code INTO l_cwlkinst_rec;
          CLOSE c_inst_code ;

         IF l_cwlkinst_rec.crosswalk_dtl_id IS NOT NULL THEN -- Record is found in the Crosswalk detail table

            IF l_cwlkinst_rec.inst_code IS NOT NULL THEN   -- The Institution Code in the Crosswalk table is present.

               IF validate_inst_code(v_inst_rec.new_institution_cd,
                                     v_inst_rec.exst_institution_cd,
                                     l_cwlkinst_rec.inst_code,
                                     v_inst_rec.interface_id) THEN
                l_exists := NULL;

                OPEN c_inst_present(l_cwlkinst_rec.inst_code);
                FETCH c_inst_present INTO l_exists;
                CLOSE c_inst_present ;

                IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS

                  --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect

                  IF gb_write_exception_log1 = TRUE THEN
                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E001');
                  END IF;

                  -- Update error_code for this record
                  -- Update Status of the Record to 3 to indicate Error
                  UPDATE IGS_OR_INST_INT
                  SET ERROR_CODE = 'E001',ERROR_TEXT = NULL,  STATUS = '3'
                  WHERE INTERFACE_ID = v_inst_rec.interface_id;


                ELSE
                  IF validate_field_level_data(v_inst_rec,l_val_err) then
                    SAVEPOINT s_point;
                    -- Update the existing Institution

                    IGS_OR_INST_IMP_002.Update_Institution(l_cwlkinst_rec.inst_code, v_inst_rec,l_Errind,l_error_code,l_error_text);
                    -- No Records need to be either inserted or Updated in the Crosswalk Master and Crosswalk Detail Tables
                    /*  Rollback if there was an error during Update Institutions */
                        IF l_Errind = 'Y' THEN
                          ROLLBACK TO s_point;

                          --Log a message to the Log File that the Create of table failed
                          IF gb_write_exception_log1 = TRUE THEN
                            igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                          END IF;
                          -- Set error_code/error_text
                          UPDATE IGS_OR_INST_INT
                          SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                          WHERE INTERFACE_ID = v_inst_rec.interface_id;

                        ELSE

                          IGS_OR_INST_IMP_002.Create_Alternate_Id(l_cwlkinst_rec.inst_code,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);

                          IF l_errind = 'Y' THEN

                                ROLLBACK TO s_point;

                                --Log a message to the Log File that the Create of Alternate Id failed
                                IF gb_write_exception_log1 = TRUE THEN
                                   igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                END IF;

                                UPDATE IGS_OR_INST_INT
                                SET error_code = l_error_code,
                                    status = '3'
                                WHERE interface_id = v_inst_rec.interface_id;
                          ELSE

                                --Import of Institution is successful , import the Child
                                --Update error_code/error_text
                                UPDATE IGS_OR_INST_INT
                                SET error_code = NULL,error_text=NULL , STATUS = '1'
                                WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                 -- Call Child Process
                                OPEN c_party_id(l_cwlkinst_rec.inst_code);
                                FETCH c_party_id INTO l_party_id;
                                CLOSE c_party_id;
                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_cwlkinst_rec.inst_code);
                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                          END IF;
                       END IF;
                ELSE

                    --Log a message to the Log File that the validation of Institution failed
                    IF gb_write_exception_log1 = TRUE THEN
                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                    END IF;

                    --Update Error_code field
                    UPDATE IGS_OR_INST_INT
                    SET error_code = l_val_err, error_text= NULL , STATUS = '3'
                    WHERE INTERFACE_ID = v_inst_rec.interface_id;

                END IF;
              END IF;
           END IF;
          ELSE -- The Institution Code in the Crosswalk table is NULL
           IF v_inst_rec.exst_institution_cd IS NULL THEN -- If the exst_inst_code of the interface rec is null, then create
                IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                   SAVEPOINT s_point;

              IGS_OR_INST_IMP_002.Create_Institution(v_inst_rec,l_Newinstcd,l_Errind,l_error_code,l_error_text); -- Create a new institution
              /* Update the Crosswalk Master with the newly created Institution Code if no error has occured
                         during creation of new institution. If an error has occured then rollback to savepoint s_point */
              IF l_Errind = 'Y' THEN
                ROLLBACK TO s_point;

                         --Log a message to the Log File that the Create of inst failed with reason
                       IF gb_write_exception_log1 = TRUE THEN
                         igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                       END IF;
                         -- Set error_code/error_text
                   UPDATE IGS_OR_INST_INT
                   SET error_code = l_error_code, error_text= l_error_text , STATUS = '3'
                   WHERE INTERFACE_ID = v_inst_rec.interface_id;

              ELSE

                  IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,l_Newinstcd,l_Errind);


                     IF l_Errind = 'Y' THEN
                       ROLLBACK TO s_point;
                       --Log a message to the Log File that the Update of Crosswalk Master failed

                       IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                       END IF;

                       --Update Error_code field
                       UPDATE IGS_OR_INST_INT
                       SET error_code = 'E040', error_text= NULL , STATUS = '3'
                       WHERE INTERFACE_ID = v_inst_rec.interface_id;

                     ELSE
                           -- No records needs to be inserted to the Crosswalk Detail as the record is already found
                       /* Create a New Record in the table IGS_OR_ORG_ALT_ID  if no error has occured during
                           updation of Crosswalk Master. If an error has occured then rollback to savepoint s_point */

                           IGS_OR_INST_IMP_002.Create_Alternate_Id(l_Newinstcd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);

                       /* Rollback if there is an error during the create in the above step else call the import of child records */
                           IF l_Errind = 'Y' THEN    -- STEP A
                                  ROLLBACK TO s_point;

                                  --Log a message to the Log File that the Create of Alternate Id failed
                                  IF gb_write_exception_log1 = TRUE THEN
                                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                  END IF;

                                   -- Update the error_code field
                                  UPDATE IGS_OR_INST_INT
                                  SET ERROR_CODE = l_error_code,
                                      ERROR_TEXT =NULL,
                                      STATUS = '3'
                                  WHERE INTERFACE_ID = v_inst_rec.interface_id;
                           ELSE

                              -- Import of Institution is successful , import the Child
                              --Update error_code/error_text
                              UPDATE IGS_OR_INST_INT
                              SET error_code = NULL,error_text=NULL, STATUS = '1'
                              WHERE INTERFACE_ID = v_inst_rec.interface_id;

                              -- Call Child Process
                              OPEN c_party_id(l_Newinstcd);
                              FETCH c_party_id INTO l_party_id;
                              CLOSE c_party_id;
                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_Newinstcd);
                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                           END IF;                   -- STEP A
                         END IF;
              END IF;
           ELSE

                    --Log a message to the Log File that the validation of

                    IF gb_write_exception_log1 = TRUE THEN
                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                    END IF;

                    --Update Error_code field
                    UPDATE IGS_OR_INST_INT
                    SET error_code = l_val_err, error_text= NULL,  STATUS = '3'
                    WHERE INTERFACE_ID = v_inst_rec.interface_id;

            END IF;
          ELSE  -- If the exst_inst_code of the interface rec is NOT NULL
                             l_exists := NULL;
                          OPEN c_inst_present(v_inst_rec.exst_institution_cd);
                          FETCH c_inst_present INTO l_exists;
                          CLOSE c_inst_present ;

                  IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS
                         --Error Out
                         --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect

                        IF gb_write_exception_log1 = TRUE THEN
                           igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E006');
                        END IF;

                        -- Update ERROR_CODE/ERROR_TEXT
                        UPDATE IGS_OR_INST_INT
                        SET ERROR_CODE = 'E006',error_text = NULL, STATUS = '3'
                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                  ELSE   -- Institution is existing in the OSS system
                     IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                           SAVEPOINT s_point;

                          IGS_OR_INST_IMP_002.Update_Institution(v_inst_rec.exst_institution_cd, v_inst_rec,l_Errind,l_error_code,l_error_text);
                                      /* Update the Crosswalk Table if the Previous update is successful, else rollback to savepoint */
                          IF l_Errind = 'Y' THEN
                            ROLLBACK TO s_point;
                                     -- ssawhney moved all together
                                     --Log a message to the Log File that the Create of table failed
                                     IF gb_write_exception_log1 = TRUE THEN
                                       igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                                     END IF;
                                     -- Set error_code/error_text
                               UPDATE IGS_OR_INST_INT
                               SET error_code = l_error_code, error_text= l_error_text,  STATUS = '3'
                               WHERE INTERFACE_ID = v_inst_rec.interface_id;

                          ELSE
                            -- kumma, 2446067
                            -- this code checks whether the v_inst_rec.exst_institution_cd already exists in the crosswalk master, and if it exists then does it
                            -- exits for the same l_cwlkinst_rec.crosswalk_id..if the corresponding crosswalk_id is not same then data is wrong
                             OPEN c_cwlk_master_present(v_inst_rec.exst_institution_cd);
                             FETCH c_cwlk_master_present INTO l_cwlk_master_present;
                             CLOSE c_cwlk_master_present;

                             IF l_cwlk_master_present.institution_code IS NOT NULL then
                                IF l_cwlkinst_rec.CROSSWALK_ID <> l_cwlk_master_present.crosswalk_id THEN
                                    -- log the message that the data is not perfect, more than one crosswalk ids exists for the given
                                    -- alternater_id and alternater_id_value

                                    IF gb_write_exception_log1 = TRUE THEN
                                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id, 'E051');
                                    END IF;

                                     -- Set error_code/error_text
                                    UPDATE IGS_OR_INST_INT
                                    SET error_code = 'E051', error_text= 'crosswalk_id of crosswalk details table does not match with the master record', status = 3
                                    WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                    l_Errind := 'Y';
                                    l_error_code := 'E051';
                                ELSE
                                    IGS_OR_INST_IMP_002.Update_Crosswalk_master(l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                                END IF;
                             ELSE
                                IGS_OR_INST_IMP_002.Update_Crosswalk_master(l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                             END IF;

                        -- additition of code ends here, kumma


                            -- No records needs to be inserted to the Crosswalk Detail
                            /* Rollback if there is an error during the create in the above step else call the import of child records */
                                 IF l_Errind = 'Y' THEN
                                   ROLLBACK TO s_point;
                                   --Log a message to the Log File that the Update of Crosswalk Master failed
                                    IF l_error_code <> 'E051' THEN

                                       IF gb_write_exception_log1 = TRUE THEN
                                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                                       END IF;

                                               --Update error_code/error_text field
                                       UPDATE IGS_OR_INST_INT
                                       SET ERROR_CODE = 'E040', ERROR_TEXT=NULL, STATUS = '3'
                                       WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                    END IF;
                                 ELSE

                                    IGS_OR_INST_IMP_002.Create_Alternate_Id(v_inst_rec.exst_institution_cd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);

                                       IF l_Errind = 'Y' THEN
                                              ROLLBACK TO s_point;
                                              --Log a message to the Log File that the Create of Alternate Id failed

                                              IF gb_write_exception_log1 = TRUE THEN
                                                igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                              END IF;

                                               -- Update the error_code field
                                              UPDATE IGS_OR_INST_INT
                                              SET ERROR_CODE = l_error_code,
                                                  ERROR_TEXT =NULL,
                                                  STATUS = '3'
                                              WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                       ELSE
                                           -- Import of Institution is successful , import the Child
                                           --Update error_code/error_text
                                           UPDATE IGS_OR_INST_INT
                                           SET error_code = NULL,error_text=NULL, STATUS = '1'
                                           WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                           -- Call Child Process
                                              OPEN c_party_id(v_inst_rec.exst_institution_cd);
                                              FETCH c_party_id INTO l_party_id;
                                              CLOSE c_party_id;
                                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,v_inst_rec.exst_institution_cd);
                                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                              IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                        END IF;
                                 END IF;
                     END IF;
                   ELSE
                        --Log a message to the Log File that the Update of Crosswalk Master failed
                        IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                        END IF;
                        --Update Error_code field
                        -- ssawhney moved all together
                        UPDATE IGS_OR_INST_INT
                        SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                  END IF;
              END IF ;
            END IF;
          END IF;
      ELSE  -- l_exists = 'Y', implies that record was not found in the crosswalk table
          IF v_inst_rec.exst_institution_cd IS NULL THEN  -- Institution code is null
            IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                SAVEPOINT s_point;
                p_inst_rec := v_inst_rec;

                IGS_OR_INST_IMP_002.Create_Institution(p_inst_rec,l_Newinstcd,l_Errind,l_error_code,l_error_text);

                 IF l_Errind = 'Y' THEN
                   ROLLBACK TO s_point;
                        IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                        END IF;
                         -- Set error_code/error_text
                        UPDATE IGS_OR_INST_INT
                        SET error_code = l_error_code, error_text= l_error_text , STATUS = '3'
                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                ELSE
         /* Create a Record in Crosswalk Master if the Previous Create was successful else rollback to the savepoint */


                  -- kumma, 2446067
                  -- Added the following code to check that the institution_code already exists in the cross walk
                  -- master table , if it exists then update it else create the new

                  OPEN c_cwlk_master_present(l_Newinstcd);
                  FETCH c_cwlk_master_present INTO l_cwlk_master_present;
                  CLOSE c_cwlk_master_present;
                      IF l_cwlk_master_present.institution_code IS NULL THEN
                           IGS_OR_INST_IMP_002.Create_Crosswalk_Master(l_Newinstcd,v_inst_rec.NAME,l_Errind,l_Crswlkid);
                      ELSE
                          l_Crswlkid := l_cwlk_master_present.crosswalk_id;
                      END IF;

           /* Create a Record in the Crosswalk Detail if the Previous Create is successful else rollback to the savepoint */
              IF l_Errind = 'Y' THEN
                  ROLLBACK TO s_point;
                  --Log a message to the Log File that the Create of Crosswalk Master failed

                    IF gb_write_exception_log1 = TRUE THEN
                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E004');
                    END IF;

                      UPDATE IGS_OR_INST_INT
                      SET ERROR_CODE = 'E004',error_text =NULL, STATUS = '3'
                      WHERE INTERFACE_ID = v_inst_rec.interface_id;

              ELSE
                      IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Crswlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind);
              /* Create a Record in the Alternate Ids table IGS_OR_ORG_ALT_IDS if the Previous Create is successful else rollback to the savepoint */
                IF l_Errind = 'Y' THEN
                  ROLLBACK TO s_point;
                    --Log a message to the Log File that the Update of Crosswalk Master failed
                    IF gb_write_exception_log1 = TRUE THEN
                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                    END IF;

                    UPDATE IGS_OR_INST_INT
                    SET error_code = 'E007',error_text=NULL , STATUS = '3'
                    WHERE INTERFACE_ID = v_inst_rec.interface_id;

                ELSE
                    IGS_OR_INST_IMP_002.Create_Alternate_Id(l_Newinstcd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                 /* Call the Child process if the Above Create is successful else rollback */
                       IF l_Errind = 'Y' THEN
                          ROLLBACK TO s_point;
                           --Log a message to the Log File that the Create of Alternate Id failed
                           IF gb_write_exception_log1 = TRUE THEN
                             igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                           END IF;

                           UPDATE IGS_OR_INST_INT
                           SET error_code = l_error_code,
                               error_text=NULL ,
                               status = '3'
                           WHERE interface_id = v_inst_rec.interface_id;

                       ELSE
                           -- Import of Institution is successful , import the Child
                           UPDATE IGS_OR_INST_INT
                           SET error_code = NULL,error_text=NULL, STATUS = '1'
                           WHERE INTERFACE_ID = v_inst_rec.interface_id;
                           --Update status to show success

                           -- Child Process
                           OPEN c_party_id(l_Newinstcd);
                           FETCH c_party_id INTO l_party_id;
                           CLOSE c_party_id;

                           IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_Newinstcd);
                           IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                           IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                           IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                       END IF;
                END IF;
              END IF;
             END IF;
           ELSE
                --Log a message to the Log File that the Update of Crosswalk Master failed
                IF gb_write_exception_log1 = TRUE THEN
                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                END IF;
                --Update Error_code field
                -- ssawhney moved all together
                UPDATE IGS_OR_INST_INT
                SET error_code = l_val_err, error_text= NULL , STATUS = '3'
                WHERE INTERFACE_ID = v_inst_rec.interface_id;
           END IF;

        ELSE    -- Institution code is not null
                  l_exists  := NULL;
            OPEN c_inst_present(v_inst_rec.exst_institution_cd);
            FETCH c_inst_present INTO l_exists;
            CLOSE c_inst_present ;
             IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS
                --Error Out
               --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect
                 IF gb_write_exception_log1 = TRUE THEN
                   igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E006');
                 END IF;
                 -- Update error_code/error_text
                 UPDATE IGS_OR_INST_INT
                 SET error_code = 'E006', error_text=NULL , STATUS = '3'
                 WHERE INTERFACE_ID = v_inst_rec.interface_id;

            ELSE   -- Institution is existing in the OSS system
             IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                    SAVEPOINT s_point ;

                    IGS_OR_INST_IMP_002.Update_Institution(v_inst_rec.exst_institution_cd, v_inst_rec,l_Errind,l_error_code,l_error_text);
                    /* Create a Record in Crosswalk Master if the Previous Create was successful else rollback to the savepoint */
                IF l_Errind = 'Y' THEN
                     ROLLBACK TO s_point;
                       --Log a message to the Log File that the Create of table failed
                       IF gb_write_exception_log1 = TRUE THEN
                         igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                       END IF;
                         -- Set error_code/error_text
                       UPDATE IGS_OR_INST_INT
                       SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                       WHERE INTERFACE_ID = v_inst_rec.interface_id;
                ELSE
                      -- kumma, 2446067
                      -- Added the following code to check that the institution_code already exists in the cross walk
                      -- master table , if it exists then update it else create the new

                      OPEN c_cwlk_master_present(v_inst_rec.exst_institution_cd);
                      FETCH c_cwlk_master_present INTO l_cwlk_master_present;
                      CLOSE c_cwlk_master_present;
                      IF l_cwlk_master_present.institution_code IS NULL THEN
                              IGS_OR_INST_IMP_002.Create_Crosswalk_Master(v_inst_rec.exst_institution_cd,v_inst_rec.name,l_Errind,l_Crswlkid);
                      ELSE
                              l_Crswlkid := l_cwlk_master_present.crosswalk_id;
                      END IF;

                              /* Create a Record in the Crosswalk Detail if the Previous Create is successful else rollback to the savepoint */
                          IF l_Errind = 'Y' THEN
                             ROLLBACK TO s_point;
                                     --Log a message to the Log File that the Creation of Crosswalk Master failed
                               IF gb_write_exception_log1 = TRUE THEN
                                 igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E004');
                               END IF;

                                     UPDATE IGS_OR_INST_INT
                                     SET error_code = 'E004' , error_text =NULL,  STATUS = '3'
                                     WHERE INTERFACE_ID = v_inst_rec.interface_id;

                          ELSE
                             IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Crswlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind);
                            /* Create a Record in the Alternate Ids table IGS_OR_ORG_ALT_IDS if the Previous Create is successful else rollback to the savepoint */
                                 IF l_Errind = 'Y' THEN
                                   ROLLBACK TO s_point;
                                   --Log a message to the Log File that the Creation of Crosswalk detail failed
                                   IF gb_write_exception_log1 = TRUE THEN
                                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                   END IF;
                                       --update error_code/error_text -- ssawhney moved all together
                                       UPDATE IGS_OR_INST_INT
                                       SET ERROR_code = 'E007', error_text = NULL, STATUS = '3'
                                       WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                 ELSE

                                   IGS_OR_INST_IMP_002.Create_Alternate_Id(v_inst_rec.exst_institution_cd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);

                           /* Call the Child process if the Above Create is successful else rollback */
                                   IF l_Errind = 'Y' THEN
                                     ROLLBACK TO s_point;
                                         --Log a message to the Log File that the Creation of Alternate Id failed
                                         IF gb_write_exception_log1 = TRUE THEN
                                           igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                         END IF;
                                         --set error_code/error_text -- ssawhney moved all together
                                         UPDATE IGS_OR_INST_INT
                                         SET error_code = l_error_code,
                                             error_text = NULL,
                                             status = '3'
                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                   ELSE
                                     -- Import of Institution is successful , import the Child
                                     --Update error_code/error_text -- ssawhney moved all together
                                         UPDATE IGS_OR_INST_INT
                                         SET error_code = NULL,error_text=NULL, STATUS = '1'
                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                 -- Child Process
                                         OPEN c_party_id(v_inst_rec.exst_institution_cd);
                                         FETCH c_party_id INTO l_party_id;
                                         CLOSE c_party_id;
                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,v_inst_rec.exst_institution_cd);
                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);

                                   END IF;
                                 END IF;
                  END IF;
            END IF;
        ELSE
            --Log a message to the Log File that the Update of Crosswalk Master failed
            IF gb_write_exception_log1 = TRUE THEN
               igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
            END IF;
            --Update Error_code field -- ssawhney moved all together
            UPDATE IGS_OR_INST_INT
            SET error_code = l_val_err, error_text= NULL, STATUS = '3'
            WHERE INTERFACE_ID = v_inst_rec.interface_id;

        END IF;
       END IF;
      END IF;
    END IF;

    IF g_records_processed = 100 THEN
      COMMIT;
      g_records_processed := 0;
    END IF;
  END LOOP;

  delete_log_int_rec(p_batch_id);
  commit;

 EXCEPTION
     WHEN OTHERS THEN
       IF gb_write_exception_log1 THEN
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_001.simplealtidcomp.others',
                                       SQLERRM, NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
       APP_EXCEPTION.Raise_Exception;
END simpleAltidcomp;


PROCEDURE exactAltidcomp(
        p_batch_id  IN NUMBER,
    p_data_source IN VARCHAR2,
    p_ds_match IN VARCHAR2,
    p_addr_usage IN VARCHAR2,
    p_person_type IN VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 13-JUL-2001
  Purpose : This Procedure imports records from the Institution
           Interface Table to the institutions table if the user
       has choosen Exact Alternate Id comparison
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         6-JAN-2003      Bug No: 2528605
                                                                  Made the data_source_value as UPPER at the beginning and initialize the record varuable to NULL
  kumma           08-JUL-2002     Bug 2446067, Created two cursors c_cwlk_master_present and c_cwlk_detail_id.
                  Used these cursor before every call to IGS_OR_INST_IMP_002.Update_Crosswalk_master
                  which includes the existing institution cd and IGS_OR_INST_IMP_002.Create_Crosswalk_master.
  ***************************************************************/

     CURSOR c_inst_cur(cp_status IGS_OR_INST_INT.STATUS%TYPE,
                       cp_data_source VARCHAR2,
                       cp_ds_match VARCHAR2,
                       cp_batch_id NUMBER) IS
       SELECT *
       FROM IGS_OR_INST_INT IO
       WHERE IO.STATUS = cp_status AND
             IO.DATA_SOURCE_ID = cp_data_source AND
             cp_ds_match = NVL(IO.ALT_ID_TYPE,cp_ds_match) AND
             IO.BATCH_ID = cp_batch_id ;

     CURSOR  c_inst_code ( p_data_source VARCHAR2 , p_data_src_val VARCHAR2 ) IS
       SELECT crosswalk_id, crosswalk_dtl_id, inst_code
       FROM IGS_OR_CWLK_V ORCV
       WHERE ORCV.ALT_ID_TYPE = p_data_source AND
             ORCV.ALT_ID_VALUE = p_data_src_val ;

     --mmkumar, party number impact, changed the folllowing cursor to verify from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_inst_present ( cp_inst_code VARCHAR2 ) IS
       SELECT 'Y'
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;

     CURSOR c_cwlk_id(cp_inst_cd VARCHAR2 ) IS
       SELECT crosswalk_id
       FROM IGS_OR_CWLK
       WHERE institution_code = cp_inst_cd;

     --mmkumar, party number impact, changed the folllowing cursor to pick party_id from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_party_id ( cp_inst_code VARCHAR2 ) IS
       SELECT party_id
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;

     -- kumma, 2446067
     -- Created the following cursor to check whether the code already exists in the cross walk master
     CURSOR c_cwlk_master_present (cp_inst_code VARCHAR2) IS
    SELECT institution_code, crosswalk_id
    FROM IGS_OR_CWLK
    WHERE institution_code = cp_inst_code;


       l_Count NUMBER;
       l_Instcount NUMBER;
       l_Cwlkid igs_or_cwlk.crosswalk_id%TYPE;
       l_Newinstcd igs_or_institution.institution_cd%TYPE;
       l_Errind VARCHAR2(1);
       l_party_id hz_parties.party_id%TYPE;
       l_cwlkinst_rec c_inst_code%ROWTYPE;
       l_val_err igs_or_inst_int.error_code%TYPE;
       l_error_code igs_or_inst_int.error_code%TYPE := null;  --ssawhney initialised
       l_error_text igs_or_inst_int.error_text%TYPE := null;  --ssawhney initialised
       l_exists     VARCHAR2(1);
       l_cwlk_master_present c_cwlk_master_present%ROWTYPE;


BEGIN


       FOR v_inst_rec IN c_inst_cur('2',p_data_source,p_ds_match,p_batch_id) LOOP

          g_records_processed := g_records_processed + 1;

            v_inst_rec.data_source_value := UPPER(v_inst_rec.data_source_value);

	    v_inst_rec.local_institution_ind := UPPER(v_inst_rec.local_institution_ind);
    	    v_inst_rec.os_ind := UPPER(v_inst_rec.os_ind);
    	    v_inst_rec.govt_institution_cd := UPPER(v_inst_rec.govt_institution_cd);
    	    v_inst_rec.inst_control_type := UPPER(v_inst_rec.inst_control_type);
    	    v_inst_rec.inst_priority_cd := UPPER(v_inst_rec.inst_priority_cd);

            v_inst_rec.alt_id_value      := UPPER(v_inst_rec.alt_id_value);
            l_cwlkinst_rec.crosswalk_id  := NULL;
            l_cwlkinst_rec.crosswalk_dtl_id := NULL;
            l_cwlkinst_rec.inst_code     := NULL;

       IF v_inst_rec.alt_id_value  IS NOT NULL THEN

          OPEN c_inst_code (p_ds_match, v_inst_rec.alt_id_value);
          FETCH c_inst_code INTO l_cwlkinst_rec;
          CLOSE c_inst_code ;

          IF l_cwlkinst_rec.crosswalk_dtl_id IS NOT NULL THEN  -- Record is found in the Crosswalk detail table with Alt id Value and Match Data source


               IF l_cwlkinst_rec.inst_code IS NOT NULL THEN   -- The Institution Code in the Crosswalk table is present.

                 IF validate_inst_code(v_inst_rec.new_institution_cd,
                                       v_inst_rec.exst_institution_cd,
                                       l_cwlkinst_rec.inst_code,
                                       v_inst_rec.interface_id) THEN

                    l_exists := NULL;
                    OPEN c_inst_present(l_cwlkinst_rec.inst_code);
                    FETCH c_inst_present INTO l_exists;
                    CLOSE c_inst_present ;
                    IF  l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS

                      --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect
                      IF gb_write_exception_log1 = TRUE THEN
                        igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E001');
                      END IF;
                      -- Update Error_code/error_text field   -- ssawhney moved all together
                      UPDATE IGS_OR_INST_INT
                      SET error_code = 'E001', error_text=NULL, STATUS = '3'
                      WHERE INTERFACE_ID = v_inst_rec.interface_id;


                    ELSE -- The Institution Code in the Crosswalk is present in the OSS System
                         IF validate_field_level_data(v_inst_rec,l_val_err) then
                              SAVEPOINT s_point;

                                     IGS_OR_INST_IMP_002.Update_Institution(l_cwlkinst_rec.inst_code, v_inst_rec,l_Errind,l_error_code,l_error_text);
                                         -- No Record Needs to Be created in Crosswalk Master
                                        -- Fetch the Crosswalk Id from the Master
                                         OPEN c_cwlk_id(l_cwlkinst_rec.inst_code);
                                         FETCH c_cwlk_id INTO l_Cwlkid;
                                         CLOSE c_cwlk_id;
                                         /* Create a Record if the above Update is Successful , else rollback to the savepoint */
                                         IF l_Errind  = 'Y' THEN
                                                        ROLLBACK TO s_point;

                                                   --Log a message to the Log File that the Create of table failed
                                                   IF gb_write_exception_log1 = TRUE THEN
                                                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                                                   END IF;

                                                   -- Set error_code/error_text
                                                   UPDATE IGS_OR_INST_INT
                                                   SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                                                   WHERE INTERFACE_ID = v_inst_rec.interface_id;


                         ELSE
                           IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value
                               /* Create a Record in the Alternate Ids table IGS_OR_ORG_ALT_IDS if the Previous Create is successful else rollback to the savepoint */
                           IF l_Errind = 'Y' THEN
                                         ROLLBACK TO s_point;
                                                             --Log a message to the Log File that the Create of Crosswalk Detail failed
                                IF gb_write_exception_log1 = TRUE THEN
                                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                END IF;
                                --Update the error_code/error_text field -- ssawhney moved all together
                                                 UPDATE IGS_OR_INST_INT
                                                                 SET error_code = 'E007' , error_text=NULL, STATUS = '3'
                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;

                           ELSE
                                  IGS_OR_INST_IMP_002.Create_Alternate_Id(l_cwlkinst_rec.inst_code,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                                          IF l_Errind  = 'Y' THEN
                                                     ROLLBACK TO s_point;
                                                                         --Log a message to the Log File that the Create of Alternate Id failed
                                  IF gb_write_exception_log1 = TRUE THEN
                                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                  END IF;
                                     --Update error_code/text
                                                     UPDATE IGS_OR_INST_INT
                                                         SET error_code = l_error_code,error_text=NULL, STATUS = '3'
                                                                 WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                          ELSE
                                                                                 -- Import of Institution is successful , import the Child
                                                                                                 --Update error_code/error_text -- ssawhney moved all together
                                                                         UPDATE IGS_OR_INST_INT
                                                                         SET error_code = NULL,error_text=NULL, STATUS = '1'
                                                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                                         -- Call Child Process
                                                                         OPEN c_party_id(l_cwlkinst_rec.inst_code);
                                                                         FETCH c_party_id INTO l_party_id;
                                                                         CLOSE c_party_id;

                                                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_cwlkinst_rec.inst_code);
                                                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                                                         IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                              END IF;
                           END IF;
                     END IF;
                        ELSE
                                --Log a message to the Log File that the Update of Crosswalk Master failed
                                IF gb_write_exception_log1 = TRUE THEN
                                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                                END IF;
                                --Update Error_code field -- ssawhney moved all together
                                UPDATE IGS_OR_INST_INT
                                SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                                WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                --update status field

                        END IF;
                END IF;
           END IF;
         ELSE -- The Institution Code in the Crosswalk table is NULL
             IF v_inst_rec.exst_institution_cd IS NULL THEN -- If the exst_inst_code of the interface rec is null, then create
                                IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                      SAVEPOINT s_point;

                                IGS_OR_INST_IMP_002.Create_Institution(v_inst_rec,l_Newinstcd,l_Errind,l_error_code,l_error_text);
                                    IF l_Errind  = 'Y' THEN
                               ROLLBACK TO s_point;

                         --Log a message to the Log File that the Create of inst failed
                         IF gb_write_exception_log1 = TRUE THEN
                           igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                         END IF;
                         -- Set error_code/error_text -- ssawhney moved all together
                                       UPDATE IGS_OR_INST_INT
                                           SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                                           WHERE INTERFACE_ID = v_inst_rec.interface_id;



                          ELSE

                     IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,l_Newinstcd,l_Errind);

               IF l_Errind  = 'Y' THEN
                 ROLLBACK TO s_point;
                             --Log a message to the Log File that the Update of Crosswalk Master failed
                             IF gb_write_exception_log1 = TRUE THEN
                               igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                             END IF;
                             --update error_code/error_text  -- ssawhney moved all together
                                 UPDATE IGS_OR_INST_INT
                     SET error_code = 'E040', error_text=NULL, STATUS = '3'
                     WHERE INTERFACE_ID = v_inst_rec.interface_id;

               ELSE
                 OPEN c_cwlk_id(l_Newinstcd);
                 FETCH c_cwlk_id INTO l_Cwlkid;
                 CLOSE c_cwlk_id;
                             IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value
                 IF l_Errind  = 'Y' THEN
                   ROLLBACK TO s_point;
                               --Log a message to the Log File that the Create of Crosswalk Detail failed
                               IF gb_write_exception_log1 = TRUE THEN
                                 igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                               END IF;
                               --Update error_code/error_text -- ssawhney moved all together
                                       UPDATE IGS_OR_INST_INT
                       SET error_code = 'E007',error_text=NULL, STATUS = '3'
                       WHERE INTERFACE_ID = v_inst_rec.interface_id;

                 ELSE
                      IGS_OR_INST_IMP_002.Create_Alternate_Id(l_Newinstcd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                       IF l_Errind  = 'Y' THEN
                                              ROLLBACK TO s_point;
                                  --Log a message to the Log File that the Create of Alternate Id failed
                                  IF gb_write_exception_log1 = TRUE THEN
                                    igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                  END IF;
                                  --update error_code/error_text -- ssawhney moved all together
                                          UPDATE IGS_OR_INST_INT
                              SET error_code = l_error_code, error_text=NULL,  STATUS = '3'
                                  WHERE INTERFACE_ID = v_inst_rec.interface_id;
                       ELSE
                          -- Import of Institution is successful , import the Child
                                  --Update error_code/error_text -- ssawhney moved all together
                                  UPDATE IGS_OR_INST_INT
                          SET error_code = NULL,error_text=NULL, STATUS = '1'
                          WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                          --update status to show success

                                   -- Call Child Process
                                                                   OPEN c_party_id(l_Newinstcd);
                                                                   FETCH c_party_id INTO l_party_id;
                                                                   CLOSE c_party_id;

                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_Newinstcd);
                                                           IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                      END IF;
                END IF;
            END IF;
          END IF;
        ELSE
                        --Log a message to the Log File that the Update of Crosswalk Master failed
                        IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                        END IF;
                        --Update Error_code field
                                UPDATE IGS_OR_INST_INT
                                SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                                WHERE INTERFACE_ID = v_inst_rec.interface_id;

                END IF;
    ELSE  -- -- If the exst_inst_code of the interface rec is NOT null,
                     l_exists := NULL;
                    OPEN c_inst_present(v_inst_rec.exst_institution_cd);
                    FETCH c_inst_present INTO l_exists;
                    CLOSE c_inst_present ;
                        IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS
                          --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect
                          IF gb_write_exception_log1 = TRUE THEN
                            igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E006');
                          END IF;
                           -- Update error_code/error_text -- ssawhney moved all together
                                      UPDATE IGS_OR_INST_INT
                          SET error_code = 'E006',error_text=NULL, STATUS = '3'
                                              WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                       -- Update Status of the Record to 3 to indicate Error

                                                ELSE   -- Institution is existing in the OSS system
                                                        IF validate_field_level_data(v_inst_rec,l_val_err) then
                                                          SAVEPOINT s_point;
                                                          IGS_OR_INST_IMP_002.Update_Institution(v_inst_rec.exst_institution_cd, v_inst_rec,l_Errind,l_error_code,l_error_text);
                                                          IF l_Errind  = 'Y' THEN
                                                                   ROLLBACK TO s_point;

                                                                   IF gb_write_exception_log1 = TRUE THEN
                                                                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                                                                   END IF;

                                                                    -- Set error_code/error_text  -- ssawhney moved all together
                                                                   UPDATE IGS_OR_INST_INT
                                                                   SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                                                                   WHERE INTERFACE_ID = v_inst_rec.interface_id;


                                                  ELSE
                                                                        ----------
                                                                          --kumma,2446067
                                                                                          -- this code checks whether the l_newinstcd already exists in the crosswalk master, and if it exists then does it
                                                                  -- exits for the same l_cwlkinst_rec.crosswalk_id..if the corresponding crosswalk_id is not same then data is wrong
                                                                         OPEN c_cwlk_master_present(v_inst_rec.exst_institution_cd);
                                                                         FETCH c_cwlk_master_present INTO l_cwlk_master_present;
                                                                         CLOSE c_cwlk_master_present;
                                                                         IF l_cwlk_master_present.institution_code IS NOT NULL THEN
                                                                                IF l_cwlkinst_rec.CROSSWALK_ID <> l_cwlk_master_present.crosswalk_id THEN
                                                                                        -- log the message that the data is not perfect, more than one crosswalk ids exists for the given
                                                                                        -- alternater_id and alternater_id_value
                                                                                        IF gb_write_exception_log1 = TRUE THEN
                                                                                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id, 'E051');
                                                                                        END IF;
                                                                                         -- Set error_code/error_text
                                                                                        UPDATE IGS_OR_INST_INT
                                                                                        SET error_code = 'E051', error_text= 'crosswalk_id of crosswalk details table does not match with the master record', status = 3
                                                                                        WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                                                                        l_Errind  := 'Y';
                                                                                        l_error_code := 'E051';

                                                                                ELSE
                                                                                        IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                                                                                END IF;
                                                         ELSE
                                                                    IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                                                         END IF;
                                                                           -- additition of code ends here, kumma
                                                                                -----------

                          IF l_Errind  = 'Y' THEN
                                       ROLLBACK TO s_point;
                                                           IF l_error_code <> 'E051' THEN
                                                               --Log a message to the Log File that the Update of Crosswalk master failed
                                                               IF gb_write_exception_log1 = TRUE THEN
                                                                   igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                                                               END IF;
                                                                       --Update error_code/error_text -- ssawhney moved all together
                                                       UPDATE IGS_OR_INST_INT
                                                               SET error_code = 'E040', error_text=NULL, STATUS = '3'
                                                                           WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                        END IF;
                                      ELSE
                                           OPEN c_cwlk_id(v_inst_rec.exst_institution_cd);
                                               FETCH c_cwlk_id INTO l_Cwlkid;
                                                           CLOSE c_cwlk_id;
                               IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value
                                                   IF l_Errind  = 'Y' THEN
                                                                     ROLLBACK TO s_point;
                                                                                 --Log a message to the Log File that the Create Crosswalk detail failed
                                                                   IF gb_write_exception_log1 = TRUE THEN
                                                                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                                                   END IF;

                                                         --Update error_code/error_text -- ssawhney moved all together
                                                                                 UPDATE IGS_OR_INST_INT
                                                     SET error_code = 'E007', error_text=NULL, STATUS = '3'
                                                                     WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                  ELSE
                                         IGS_OR_INST_IMP_002.Create_Alternate_Id(v_inst_rec.exst_institution_cd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                                             IF l_Errind  = 'Y' THEN
                                                           ROLLBACK TO s_point;
                                                               --Log a message to the Log File that the Create Alternate Id failed
                                                                   IF gb_write_exception_log1 = TRUE THEN
                                                                     igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                                                   END IF;
                                                                       --update status
                                                           UPDATE IGS_OR_INST_INT
                                                                   SET error_code = l_error_code, error_text=NULL, STATUS = '3'
                                                   WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                                         ELSE
                                                                                        -- Import of Institution is successful , import the Child
                                                                                        --Update error_code/error_text
                                                                                        UPDATE IGS_OR_INST_INT
                                                                                        SET error_code = NULL,error_text=NULL, STATUS = '1'
                                                                                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                                                                           -- Call Child Process
                                                                                   OPEN c_party_id(v_inst_rec.exst_institution_cd);
                                                                                   FETCH c_party_id INTO l_party_id;
                                                                                   CLOSE c_party_id;

                                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,v_inst_rec.exst_institution_cd);
                                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                                                                   IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                   END IF;
                                  END IF;
                            END IF;
                         END IF;
                                ELSE
                                        --Log a message to the Log File that the Update of Crosswalk Master failed
                                        IF gb_write_exception_log1 = TRUE THEN
                                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                                        END IF;
                                        --Update Error_code field -- ssawhney moved all together
                                        UPDATE IGS_OR_INST_INT
                                        SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                END IF;

            END IF ;
           END IF;
          END IF;  -- The Institution Code in the Crosswalk table is present
       ELSE  -- l_count = 0
              --Log a message to the Log File in the Conc Manager  that the record for exact match is not found in the crosswalk dtl table
                   IF gb_write_exception_log1 = TRUE THEN
                    igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E041');
                   END IF;
                  --Update error_code/error_text

                  UPDATE IGS_OR_INST_INT
                  SET error_code = 'E041', error_text=NULL, STATUS = '3'
                  WHERE INTERFACE_ID = v_inst_rec.interface_id;

       END IF;
     ELSE  -- The Alternate Id value is Null

               --Log a message to the Log File in the Conc Manager  that the Alternate Id Value cannot be Null for Exact Match
           IF gb_write_exception_log1 = TRUE THEN
             igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E042');
           END IF;

           -- Update error_code/error_text
           UPDATE IGS_OR_INST_INT
           SET error_code = 'E042', error_text=NULL,  STATUS = '3'
           WHERE INTERFACE_ID = v_inst_rec.interface_id;

     END IF;

                IF g_records_processed = 100 THEN
           COMMIT;
           g_records_processed := 0;
        END IF;

    END LOOP;

    delete_log_int_rec(p_batch_id);
    commit;

  EXCEPTION
     WHEN OTHERS THEN
       IF gb_write_exception_log1 THEN
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_001.exactAltidcomp.others',
                                       SQLERRM, NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
       APP_EXCEPTION.Raise_Exception;
END exactAltidcomp;


PROCEDURE numericAltidcomp(
        p_batch_id  IN NUMBER,
    p_data_source IN VARCHAR2,
    p_ds_match IN VARCHAR2,
    p_addr_usage IN VARCHAR2,
    p_person_type IN VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 13-JUL-2001
  Purpose : This Procedure imports records from the Institution
           Interface Table to the institutions table if the user
       has choosen Numeric Alternate Id comparison
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         6-JAN-2003      Bug No: 2528605
                                                                  Made the data_source_value as UPPER at the beginning and initialize the record varuable to NULL
  kumma           08-JUL-2002     Bug 2446067, Created two cursors c_cwlk_master_present and c_cwlk_detail_id.
                  Used these cursor before every call to IGS_OR_INST_IMP_002.Update_Crosswalk_master
                  which includes the existing institution cd and IGS_OR_INST_IMP_002.Create_Crosswalk_master.
                  In the Exception section checked for the invalid_number exception, as if the alternate_id_value
                  is not neumeric we need to log a message stating that it should be neumeric only.
                  Created a new cursor c_neumeric_test to check whether the Alternate Id value is neumeric or not.
                  In cursor c_record_found and c_inst_code removed the to_number function.
  gmaheswa	  24 March 2006   Bug 3370808 Update interface record with E043 only when error code is null.
  ***************************************************************/

       CURSOR c_inst_cur(cp_status IGS_OR_INST_INT.STATUS%TYPE,
                         cp_data_source VARCHAR2,
                         cp_ds_match VARCHAR2,
                         cp_batch_id VARCHAR2) IS
       SELECT *
       FROM IGS_OR_INST_INT IO
       WHERE IO.STATUS = cp_status AND
             IO.DATA_SOURCE_ID = cp_data_source AND
             cp_ds_match = NVL(IO.ALT_ID_TYPE,cp_ds_match) AND
             IO.BATCH_ID = cp_batch_id;


     -- KUMMA, 2446007
     -- removed the to_number function from cp_data_src_val and put the like instead of =
     -- and added one more column ALT_ID_VALUE in the select query
     CURSOR  c_inst_code ( cp_data_source VARCHAR2 , cp_data_src_val VARCHAR2 ) IS
       SELECT crosswalk_id, crosswalk_dtl_id,inst_code, ALT_ID_VALUE
       FROM IGS_OR_CWLK_V ORCV
       WHERE ORCV.ALT_ID_TYPE = cp_data_source AND
             ORCV.ALT_ID_VALUE like '%' || cp_data_src_val;

     --mmkumar, party number impact, changed the folllowing cursor to verify from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_inst_present ( cp_inst_code VARCHAR2 ) IS
       SELECT 'Y'
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;

     CURSOR c_cwlk_id (cp_inst_cd VARCHAR2 ) IS
       SELECT crosswalk_id
       FROM IGS_OR_CWLK
       WHERE institution_code = cp_inst_cd;

     --mmkumar, party number impact, changed the folllowing cursor to pick party_id from igs_pe_hz_parties instead of from hz_parties
     CURSOR  c_party_id ( cp_inst_code VARCHAR2 ) IS
       SELECT party_id
       FROM igs_pe_hz_parties
       WHERE oss_org_unit_cd = cp_inst_code;


     -- kumma, 2446067
     -- Created the following cursor to check whether the code already exists in the cross walk master
     CURSOR c_cwlk_master_present (cp_inst_code VARCHAR2) IS
    SELECT institution_code, crosswalk_id
    FROM IGS_OR_CWLK
    WHERE institution_code = cp_inst_code;

      -- kumma, 2446007
      CURSOR c_neumeric_test (cp_data_src_val VARCHAR2) IS
           SELECT to_number(cp_data_src_val) FROM DUAL;

       l_Count NUMBER;
       l_Instcount NUMBER;
       l_Cwlkid NUMBER;
       l_Newinstcd VARCHAR2(30);
       l_Errind    VARCHAR2(1);
       l_party_id NUMBER(15);

       l_cwlkinst_rec c_inst_code%ROWTYPE;
       l_val_err igs_or_inst_int.error_code%TYPE;
       l_error_code igs_or_inst_int.error_code%TYPE := null; --ssawhney initialised
       l_error_text igs_or_inst_int.error_text%TYPE := null; --ssawhney initialised
       l_exists     VARCHAR2(1);
       --kumma
       l_cwlk_master_present c_cwlk_master_present%ROWTYPE;
       v_inst_record c_inst_cur%ROWTYPE;
       l_neumeric_test c_neumeric_test%ROWTYPE;
       l_rec_count number := 1;
BEGIN
       FOR v_inst_rec IN c_inst_cur('2',p_data_source,p_ds_match,p_batch_id) LOOP

          g_records_processed := g_records_processed + 1;

          v_inst_rec.data_source_value := UPPER(v_inst_rec.data_source_value);

	  v_inst_rec.local_institution_ind := UPPER(v_inst_rec.local_institution_ind);
    	  v_inst_rec.os_ind := UPPER(v_inst_rec.os_ind);
    	  v_inst_rec.govt_institution_cd := UPPER(v_inst_rec.govt_institution_cd);
    	  v_inst_rec.inst_control_type := UPPER(v_inst_rec.inst_control_type);
    	  v_inst_rec.inst_priority_cd := UPPER(v_inst_rec.inst_priority_cd);

          v_inst_rec.alt_id_value      := UPPER(v_inst_rec.alt_id_value);
          l_cwlkinst_rec.crosswalk_id  := NULL;
          l_cwlkinst_rec.crosswalk_dtl_id := NULL;
          l_cwlkinst_rec.inst_code       := NULL;

       --kumma, 2446007, starting the annonymous procedure
       BEGIN
       -- kumma, 2446067
       -- copied the record into another record, as the variable v_inst_rec is not accessible inside the exception block
       -- setting the default value of the error indicator to 'Y'
       v_inst_record := v_inst_rec;
       l_Errind := 'Y';

        FOR cwlkinst_rec IN c_inst_code (p_ds_match, v_inst_rec.data_source_value) LOOP
             BEGIN

                   OPEN c_neumeric_test(cwlkinst_rec.ALT_ID_VALUE);
                           FETCH c_neumeric_test INTO l_neumeric_test;
                                   CLOSE c_neumeric_test;

           IF to_number(cwlkinst_rec.ALT_ID_VALUE) = to_number(v_inst_rec.data_source_value) THEN -- if both are equal

            -- kumma, 2446007
            l_rec_count := l_rec_count + 1;
            IF l_rec_count > 2 THEN
                IF gb_write_exception_log1 = TRUE THEN
                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id, 'E051');
                END IF;
                -- Set error_code/error_text
                 UPDATE IGS_OR_INST_INT
                 SET error_code = 'E051', error_text= 'crosswalk_id of crosswalk details table does not match with the master record', status = 3
                 WHERE INTERFACE_ID = v_inst_rec.interface_id;
                 l_Errind := 'Y';
                 l_error_code := 'E051';
                 EXIT;
                        ELSE
                 l_Errind := 'N';
                 l_error_code := '';
            END IF;
            l_cwlkinst_rec := cwlkinst_rec;
                END IF; -- if l_cwlkinst_rec.ALT_ID_VALUE = v_inst_rec.data_source_value
         EXCEPTION
          WHEN INVALID_NUMBER THEN
            --Log a message to the Log File that for neumeric match Alternater Id should be neumeric value.
            IF gb_write_exception_log1 = TRUE THEN
               igs_or_inst_imp_001.log_writer(v_inst_record.interface_id,'E052');
            END IF;
            -- Update Error_code/error_text
            IF c_neumeric_test%ISOPEN THEN
               CLOSE c_neumeric_test;
            END IF;

            UPDATE IGS_OR_INST_INT
                   SET error_code = 'E052', error_text=NULL, STATUS =3
                   WHERE INTERFACE_ID = v_inst_record.interface_id;

            RAISE INVALID_NUMBER;
          WHEN OTHERS THEN
            IF c_neumeric_test%ISOPEN THEN
               CLOSE c_neumeric_test;
            END IF;
         END; -- end of annanomyous procedure
        END LOOP;
        l_rec_count := 1; -- setting back to 1

      --kumma, 2446007, added this condition
      IF l_Errind = 'N' THEN

          IF l_cwlkinst_rec.crosswalk_dtl_id IS NOT NULL THEN

            IF l_cwlkinst_rec.inst_code IS NOT NULL THEN   -- The Institution Code in the Crosswalk table not null fnd_file.put_line(fnd_file.log,'fould in dtl');

              IF validate_inst_code(v_inst_rec.new_institution_cd,
                                    v_inst_rec.exst_institution_cd,
                                    l_cwlkinst_rec.inst_code,
                                    v_inst_rec.interface_id) THEN


                l_exists := NULL;
                OPEN c_inst_present(l_cwlkinst_rec.inst_code);
                FETCH c_inst_present INTO l_exists;
                CLOSE c_inst_present ;


                IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS
                  --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect
                  IF gb_write_exception_log1 = TRUE THEN
                    igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E001');
                  END IF;
                  -- Update error_code/error_text  -- ssawhney moved all together
                  UPDATE IGS_OR_INST_INT
                  SET error_code = 'E001',error_text=NULL, STATUS = '3'
                                 WHERE INTERFACE_ID = v_inst_rec.interface_id;
                 -- Update Status of the Record to 3 to indicate Error

                  ELSE -- The Institution Code in the Crosswalk is present in the OSS System
                                IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                                SAVEPOINT s_point;
                                IGS_OR_INST_IMP_002.Update_Institution(l_cwlkinst_rec.inst_code, v_inst_rec,l_Errind,l_error_code,l_error_text);
                                -- No Record Needs to Be created in Crosswalk Master
                                    IF l_Errind  = 'Y' THEN
                                  ROLLBACK TO s_point;

                         --Log a message to the Log File that the Create of table failed
                           IF gb_write_exception_log1 = TRUE THEN
                             igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                           END IF;
                         -- Set error_code/error_text  -- ssawhney moved all together
                                                 UPDATE IGS_OR_INST_INT
                                 SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                ELSE

                                                OPEN c_cwlk_id(l_cwlkinst_rec.inst_code);
                                                FETCH c_cwlk_id INTO l_Cwlkid;
                                CLOSE c_cwlk_id;

                           IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value
                                       IF l_Errind  = 'Y' THEN
                                                         ROLLBACK TO s_point;
                                     --Log a message to the Log File that the Create of Crosswalk Detail failed
                                             IF gb_write_exception_log1 = TRUE THEN
                                               igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                             END IF;
                                                     --Update error_code/error_text  -- ssawhney moved all together
                                             UPDATE IGS_OR_INST_INT
                                                     SET error_code = 'E007', error_text=NULL,  STATUS = '3'
                                     WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                           ELSE
                                                         IGS_OR_INST_IMP_002.Create_Alternate_Id(l_cwlkinst_rec.inst_code,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                                     IF l_Errind  = 'Y' THEN
                                                    ROLLBACK TO s_point;
                                    --Log a message to the Log File that the Create of Alternate Id failed
                                        IF gb_write_exception_log1 = TRUE THEN
                                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                        END IF;
                                            --update error_code/error_text
                                            UPDATE IGS_OR_INST_INT
                                                SET error_code = l_error_code, error_text=NULL, STATUS = '3'
                                                        WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                     ELSE
                                        -- Import of Institution is successful , import the Child
                                            --Update error_code/error_text -- ssawhney moved all together
                                            UPDATE IGS_OR_INST_INT
                                        SET error_code = NULL,error_text=NULL, STATUS = '1'
                                                    WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                -- Call the Child Process
                                                        OPEN c_party_id(l_cwlkinst_rec.inst_code);
                                    FETCH c_party_id INTO l_party_id;
                                            CLOSE c_party_id;
                                            IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_cwlkinst_rec.inst_code);
                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                            IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                            IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                             END IF;
                                           END IF;
                          END IF;
                        ELSE
                                --Log a message to the Log File that the Update of Crosswalk Master failed
                                IF gb_write_exception_log1 = TRUE THEN
                                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                                END IF;
                                --Update Error_code field -- ssawhney moved all together
                                UPDATE IGS_OR_INST_INT
                                SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                                WHERE INTERFACE_ID = v_inst_rec.interface_id;

                        END IF;
                END IF;
           END IF;
        ELSE -- The Institution Code in the Crosswalk table is NULL
              IF v_inst_rec.exst_institution_cd IS NULL THEN -- If the exst_inst_code of the interface rec is null, then create
                                IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                                SAVEPOINT s_point;
                                IGS_OR_INST_IMP_002.Create_Institution(v_inst_rec,l_Newinstcd,l_Errind,l_error_code,l_error_text);

                                    IF l_Errind  = 'Y' THEN
                                  ROLLBACK TO s_point;

                         --Log a message to the Log File that the Create of inst failed
                                IF gb_write_exception_log1 = TRUE THEN
                                   igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                                END IF;
                         -- Set error_code/error_text
                                           UPDATE IGS_OR_INST_INT
                                           SET error_code = l_error_code, error_text= l_error_text, STATUS = '3'
                           WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                    ELSE

                              IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,l_Newinstcd,l_Errind);

                                          IF l_Errind  = 'Y' THEN
                                    ROLLBACK TO s_point;
                                            --Log a message to the Log File that the Update of Crosswalk master failed
                                            IF gb_write_exception_log1 = TRUE THEN
                                                igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                                            END IF;
                                    --Update error_code/error_text  -- ssawhney moved all together
                                                    UPDATE IGS_OR_INST_INT
                                    SET error_code = 'E040' ,error_text=NULL, STATUS = '3'
                                                WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                  ELSE
                                            OPEN c_cwlk_id(l_Newinstcd);
                                                    FETCH c_cwlk_id INTO l_Cwlkid;
                                    CLOSE c_cwlk_id;

                                            IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value

                                            IF l_Errind  = 'Y' THEN
                                                          ROLLBACK TO s_point;
                                          --Log a message to the Log File that the Create of Crosswalk Detail failed
                                               IF gb_write_exception_log1 = TRUE THEN
                                                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                               END IF;
                                                          --Update error_code/error_text  -- ssawhney moved all together
                                              UPDATE IGS_OR_INST_INT
                                      SET error_code = 'E007',error_text=NULL, STATUS = '3'
                                                  WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                            ELSE
                                                      IGS_OR_INST_IMP_002.Create_Alternate_Id(l_Newinstcd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                                                  IF l_Errind  = 'Y' THEN
                                                    ROLLBACK TO s_point;
                                                                        --Log a message to the Log File that the Create of Alternate Id failed
                                                            IF gb_write_exception_log1 = TRUE THEN
                                                              igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                                            END IF;
                                                            --Update error_code/error_text -- ssawhney moved all together
                                                            UPDATE IGS_OR_INST_INT
                                                SET error_code = l_error_code,error_text=NULL, STATUS = '3'
                                                                WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                              ELSE
                                                                -- Import of Institution is successful , import the Child
                                                                                        --Update error_code/error_text  -- ssawhney moved all together
                                                                UPDATE IGS_OR_INST_INT
                                                                SET error_code = NULL,error_text=NULL, STATUS = '1'
                                                                WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                                                                        -- Call the Child Process
                                                                                OPEN c_party_id(l_Newinstcd);
                                                                                FETCH c_party_id INTO l_party_id;
                                                                                CLOSE c_party_id;
                                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,l_Newinstcd);
                                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                                          END IF;
                                    END IF;
                  END IF;
                END IF;
                ELSE
                        --Log a message to the Log File that the Update of Crosswalk Master failed
                        IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                        END IF;
                        --Update Error_code field  -- ssawhney moved all together
                        UPDATE IGS_OR_INST_INT
                        SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                END IF;

      ELSE  -- -- If the exst_inst_code of the interface rec is NOT null,
               l_exists := NULL;
        OPEN c_inst_present(v_inst_rec.exst_institution_cd);
        FETCH c_inst_present INTO l_exists;
        CLOSE c_inst_present ;
            IF l_exists IS NULL THEN -- Error Has occured, as the institution code is not Present in the OSS
                                    --Log a message to the Log File in the Conc Manager  that the INSTITUTION CODE in the cwlk table is incorrect
                   IF gb_write_exception_log1 = TRUE THEN
                      igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E001');
                   END IF;
                   -- Update Error_code/error_text
                          UPDATE IGS_OR_INST_INT
                                  SET error_code = 'E001',error_text=NULL, STATUS = '3'
                  WHERE INTERFACE_ID = v_inst_rec.interface_id;

                ELSE   -- Institution is existing in the OSS system
                                IF validate_field_level_data(v_inst_rec,l_val_err) THEN
                          SAVEPOINT s_point;

                                  IGS_OR_INST_IMP_002.Update_Institution(v_inst_rec.exst_institution_cd, v_inst_rec,l_Errind,l_error_code,l_error_text);
                                          IF l_Errind  = 'Y' THEN
                                                ROLLBACK TO s_point;

                       IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code,l_error_text);
                       END IF;
                         -- Set error_code/error_text
                               UPDATE IGS_OR_INST_INT
                                   SET error_code = l_error_code , error_text= l_error_text,STATUS = '3'
                                       WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                  ELSE
                                     ----
                                         --kumma,2446067..l_cwlkinst_rec
                         -- this code checks whether the l_newinstcd already exists in the crosswalk master, and if it exists then does it
                                                 -- exits for the same l_cwlkinst_rec.crosswalk_id..if the corresponding crosswalk_id is not same then data is wrong
                                    OPEN c_cwlk_master_present(v_inst_rec.exst_institution_cd);
                                                FETCH c_cwlk_master_present INTO l_cwlk_master_present;
                                    CLOSE c_cwlk_master_present;
                                                IF l_cwlk_master_present.institution_code IS NOT NULL then

                                        IF l_cwlkinst_rec.CROSSWALK_ID <> l_cwlk_master_present.crosswalk_id THEN

                                                                -- log the message that the data is not perfect, more than one crosswalk ids exists for the given
                                                                -- alternater_id and alternater_id_value
                                                                ROLLBACK TO s_point;
                                                                IF gb_write_exception_log1 = TRUE THEN
                                                                  igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id, 'E051');
                                                                END IF;
                                                                 -- Set error_code/error_text
                                                                UPDATE IGS_OR_INST_INT
                                                                SET error_code = 'E051', error_text= 'crosswalk_id of crosswalk details table does not match with the master record', status = 3
                                                                WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                                                l_Errind  := 'Y';
                                                                l_error_code := 'E051';

                                        ELSE

                                IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                                                    END IF;
                                    ELSE
                            IGS_OR_INST_IMP_002.Update_Crosswalk_master (l_cwlkinst_rec.crosswalk_id,v_inst_rec.exst_institution_cd,l_Errind);
                                    END IF;
            -- additition of code ends here, kumma
           ----

                                IF l_Errind  = 'Y' THEN

                      IF l_error_code <> 'E051' THEN
                   ROLLBACK TO s_point;
                  --Log a message to the Log File that the Update of Crosswalk Master failed
                          IF gb_write_exception_log1 = TRUE THEN
                            igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E040');
                          END IF;
                              --update error_code/error_text
                                          UPDATE IGS_OR_INST_INT
                          SET error_code = 'E040',error_text=NULL, STATUS = '3'
                                              WHERE INTERFACE_ID = v_inst_rec.interface_id;

                           END IF;
                    ELSE
                                          OPEN c_cwlk_id(v_inst_rec.exst_institution_cd);
                      FETCH c_cwlk_id INTO l_Cwlkid;
                      CLOSE c_cwlk_id;

                                          IGS_OR_INST_IMP_002.Create_Crosswalk_Detail(l_Cwlkid,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_Errind); -- create an entry for data_source, data_source_value
                                      IF l_Errind  = 'Y' THEN
                                                     ROLLBACK TO s_point;
                                           --Log a message to the Log File that the Create of Crosswalk Detail failed
                                               IF gb_write_exception_log1 = TRUE THEN
                                                 igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E007');
                                               END IF;
                                                    --Update error_code/error_text
                                             UPDATE IGS_OR_INST_INT
                                                 SET error_code = 'E007',error_text=NULL, STATUS = '3'
                                                         WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                      ELSE
                                             IGS_OR_INST_IMP_002.Create_Alternate_Id(v_inst_rec.exst_institution_cd,v_inst_rec.data_source_id,v_inst_rec.data_source_value,l_error_code,l_Errind);
                                             IF l_Errind  = 'Y' THEN
                                               ROLLBACK TO s_point;
                                               --Log a message to the Log File that the Create of Alternate Id failed
                                               IF gb_write_exception_log1 = TRUE THEN
                                                   igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_error_code);
                                               END IF;
                                                       --update error_code/error_text
                                               UPDATE IGS_OR_INST_INT
                                                   SET error_code = l_error_code, error_text=NULL, STATUS = '3'
                                                           WHERE INTERFACE_ID = v_inst_rec.interface_id;
                                             ELSE
                            -- Import of Institution is successful , import the Child
                                                                                        --Update error_code/error_text
                                                                UPDATE IGS_OR_INST_INT
                                                                        SET error_code = NULL,error_text=NULL, STATUS = '1'
                                                                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                                    -- Child Process
                                        OPEN c_party_id(v_inst_rec.exst_institution_cd);
                                            FETCH c_party_id INTO l_party_id;
                                                            CLOSE c_party_id;
                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Notes(v_inst_rec.interface_id,l_party_id,v_inst_rec.exst_institution_cd);
                                                        IGS_OR_INST_IMP_003_PKG.Process_Institution_Statistics(v_inst_rec.interface_id,l_party_id);
                                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Address(v_inst_rec.interface_id,p_addr_usage,l_party_id);
                                                IGS_OR_INST_IMP_003_PKG.Process_Institution_Contacts(v_inst_rec.interface_id,p_person_type,l_party_id);
                                                         END IF;
                              END IF;
                    END IF;
          END IF;
                ELSE
                        --Log a message to the Log File that the Update of Crosswalk Master failed
                        IF gb_write_exception_log1 = TRUE THEN
                          igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,l_val_err);
                        END IF;
                        --Update Error_code field
                        UPDATE IGS_OR_INST_INT
                        SET error_code = l_val_err, error_text= NULL, STATUS = '3'
                        WHERE INTERFACE_ID = v_inst_rec.interface_id;

                END IF;
           END IF ;
          END IF;
         END IF;

    END IF; -- kumma , 2446007 added this new condition,
   ELSE  -- l_count = 0
          IF l_error_code IS NULL THEN -- gmaheswa 3370808 Update interface record only when error code is null.
               --Log a message to the Log File in the Conc Manager  that the record for numeric match is not found in the crosswalk dtl table
               IF gb_write_exception_log1 = TRUE THEN
                 igs_or_inst_imp_001.log_writer(v_inst_rec.interface_id,'E043');
               END IF;

            -- Update Error_code/error_text
                    UPDATE IGS_OR_INST_INT
            SET error_code = 'E043', error_text=NULL, STATUS = '3'
            WHERE INTERFACE_ID = v_inst_rec.interface_id;
        END IF;   --End l_error_code IS NULL

   END IF;

         --kumma,2446007
 EXCEPTION
      WHEN INVALID_NUMBER THEN
           -- Handling of Invalid Number exception is done in the anonymous block before, so
           -- no code is written here.
           NULL;
 END; -- annonymous procedure ends

                  IF g_records_processed = 100 THEN
             COMMIT;
             g_records_processed := 0;
          END IF;

 END LOOP;
 delete_log_int_rec(p_batch_id);
 commit;

 EXCEPTION
     WHEN OTHERS THEN
       IF gb_write_exception_log1 THEN
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_001.numericAltidcomp.others',
                                       SQLERRM, NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
       APP_EXCEPTION.Raise_Exception;
      -- CLOSE c_inst_cur;
END numericAltidcomp;

PROCEDURE delete_log_int_rec(p_batch_id IN IGS_OR_INST_INT.BATCH_ID%TYPE) AS
 /*************************************************************
  Created By :ssaleem
  Date Created By : 19-SEP-2003
  Purpose : This procedure deletes all the completed records
            from the INT tables and updates the status
            of master table appropriately. Also it takes
            statistics of the operations and logs them.
  Know limitations, enhancements or remarks

  Remarks:
  * If IGS_OR_INST_INT has more than one error in one record,
    say for eg one record having both erroneous contact phone
    and erroneous statistics details, the record in
    IGS_OR_INST_INT will be updated with status 4 - Warning
    and with any one of the error code that is first processed,
    In the above case it will be E055.

  Change History
  Who             When            What
  ***************************************************************/

  CURSOR inst_lookup_cur(cp_lookup_type IGS_LOOKUP_VALUES.LOOKUP_TYPE%TYPE) IS
         SELECT lookup_code,meaning
         FROM IGS_LOOKUP_VALUES
         WHERE
           LOOKUP_TYPE = cp_lookup_type;

  l_lookup_rec inst_lookup_cur%ROWTYPE;

  l_inst_meaning            IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_note_meaning       IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_stat_meaning       IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_stat_dtl_meaning   IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_cont_meaning       IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_cont_phone_meaning IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_addr_meaning       IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_addr_usage_meaning IGS_LOOKUP_VALUES.MEANING%TYPE;
  l_inst_rec_err_meaning    IGS_LOOKUP_VALUES.MEANING%TYPE;

  -- Cursor for taking logging statistics, done after updating the status of  IGS_OR_INST_INT
  CURSOR log_inst_err_cur (cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE,cp_status_error IGS_OR_INST_INT.STATUS%TYPE,cp_status_warn IGS_OR_INST_INT.STATUS%TYPE) IS
         SELECT RPAD(INTERFACE_ID,12) || '    ' || LPAD(STATUS,7) || '     ' || ERROR_CODE EREC
         FROM IGS_OR_INST_INT
         WHERE BATCH_ID = cp_batch_id AND
               (STATUS = cp_status_error OR STATUS = cp_status_warn);

  l_inst_err_rec log_inst_err_cur%ROWTYPE;

  -- Cursor for taking statistics, done before deleting completed records
  CURSOR log_inst_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,STATUS STAT
         FROM IGS_OR_INST_INT
         WHERE BATCH_ID = cp_batch_id
         GROUP BY STATUS;

  l_inst_rec log_inst_rcount_cur%ROWTYPE;
  l_tot_inst  NUMBER(6);
  l_comp_inst NUMBER(6);
  l_err_inst NUMBER(6);
  l_warn_inst NUMBER(6);

  CURSOR log_inst_note_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,NT.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_INST_NTS_INT NT
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = NT.INTERFACE_ID
         GROUP BY NT.STATUS;

  l_inst_note_rec log_inst_note_rcount_cur%ROWTYPE;
  l_tot_inst_note  NUMBER(6);
  l_comp_inst_note NUMBER(6);
  l_err_inst_note  NUMBER(6);
  l_warn_inst_note NUMBER(6);

  CURSOR log_inst_stat_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,STAT.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_INST_STAT_INT STAT
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = STAT.INTERFACE_ID
         GROUP BY STAT.STATUS;

  l_inst_stat_rec log_inst_stat_rcount_cur%ROWTYPE;
  l_tot_inst_stat  NUMBER(6);
  l_comp_inst_stat NUMBER(6);
  l_err_inst_stat  NUMBER(6);
  l_warn_inst_stat NUMBER(6);

  CURSOR log_inst_sdtl_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,SDTL.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_INST_STAT_INT STAT,
              IGS_OR_INST_SDTL_INT SDTL
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = STAT.INTERFACE_ID AND
               STAT.INTERFACE_INST_STAT_ID = SDTL.INTERFACE_INST_STAT_ID
         GROUP BY SDTL.STATUS;

  l_inst_sdtl_rec log_inst_sdtl_rcount_cur%ROWTYPE;
  l_tot_inst_sdtl  NUMBER(6);
  l_comp_inst_sdtl NUMBER(6);
  l_err_inst_sdtl  NUMBER(6);
  l_warn_inst_sdtl NUMBER(6);

  CURSOR log_inst_con_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,CON.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_INST_CON_INT CON
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = CON.INTERFACE_ID
         GROUP BY CON.STATUS;

  l_inst_con_rec log_inst_con_rcount_cur%ROWTYPE;
  l_tot_inst_con  NUMBER(6);
  l_comp_inst_con NUMBER(6);
  l_err_inst_con  NUMBER(6);
  l_warn_inst_con NUMBER(6);

  CURSOR log_inst_cphn_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,CPHN.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_INST_CON_INT CON,
              IGS_OR_INST_CPHN_INT CPHN
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = CON.INTERFACE_ID AND
               CON.INTERFACE_CONTACTS_ID = CPHN.INTERFACE_CONT_ID
         GROUP BY CPHN.STATUS;

  l_inst_cphn_rec log_inst_cphn_rcount_cur%ROWTYPE;
  l_tot_inst_cphn  NUMBER(6);
  l_comp_inst_cphn NUMBER(6);
  l_err_inst_cphn  NUMBER(6);
  l_warn_inst_cphn NUMBER(6);

  CURSOR log_inst_adr_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,ADR.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_ADR_INT ADR
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = ADR.INTERFACE_ID
         GROUP BY ADR.STATUS;

  l_inst_adr_rec log_inst_adr_rcount_cur%ROWTYPE;
  l_tot_inst_adr  NUMBER(6);
  l_comp_inst_adr NUMBER(6);
  l_err_inst_adr  NUMBER(6);
  l_warn_inst_adr NUMBER(6);

  CURSOR log_inst_adru_rcount_cur(cp_batch_id IGS_OR_INST_INT.BATCH_ID%TYPE) IS
         SELECT COUNT(1) CNT,ADRU.STATUS STAT
         FROM IGS_OR_INST_INT INST,
              IGS_OR_ADR_INT ADR,
              IGS_OR_ADRUSGE_INT ADRU
         WHERE INST.BATCH_ID = cp_batch_id AND
               INST.INTERFACE_ID = ADR.INTERFACE_ID AND
               ADR.INTERFACE_ADDR_ID = ADRU.INTERFACE_ADDR_ID
         GROUP BY ADRU.STATUS;

  l_inst_adru_rec log_inst_adru_rcount_cur%ROWTYPE;
  l_tot_inst_adru  NUMBER(6);
  l_comp_inst_adru NUMBER(6);
  l_err_inst_adru  NUMBER(6);
  l_warn_inst_adru NUMBER(6);

BEGIN
  l_tot_inst        := 0;
  l_comp_inst       := 0;
  l_err_inst        := 0;
  l_warn_inst	    := 0;

  l_tot_inst_stat   := 0;
  l_comp_inst_stat  := 0;
  l_err_inst_stat   := 0;
  l_warn_inst_stat  := 0;

  l_tot_inst_sdtl   := 0;
  l_comp_inst_sdtl  := 0;
  l_err_inst_sdtl   := 0;
  l_warn_inst_sdtl  := 0;

  l_tot_inst_con    := 0;
  l_comp_inst_con   := 0;
  l_err_inst_con    := 0;
  l_warn_inst_con   := 0;

  l_tot_inst_cphn   := 0;
  l_comp_inst_cphn  := 0;
  l_err_inst_cphn   := 0;
  l_warn_inst_cphn  := 0;

  l_tot_inst_adr    := 0;
  l_comp_inst_adr   := 0;
  l_err_inst_adr    := 0;
  l_warn_inst_adr   := 0;

  l_tot_inst_adru   := 0;
  l_comp_inst_adru  := 0;
  l_err_inst_adru   := 0;
  l_warn_inst_adru  := 0;

  l_tot_inst_note   := 0;
  l_comp_inst_note  := 0;
  l_err_inst_note   := 0;
  l_warn_inst_note  := 0;

  FOR l_lookup_rec IN inst_lookup_cur('OR_INST_IMPORT_LOG') LOOP

    IF l_lookup_rec.lookup_code = 'INST' THEN
      l_inst_meaning      := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_NOTE' THEN
      l_inst_note_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_STAT' THEN
      l_inst_stat_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_STAT_DTL' THEN
      l_inst_stat_dtl_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_CONT' THEN
      l_inst_cont_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_CONT_PHONE' THEN
      l_inst_cont_phone_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_ADDR' THEN
      l_inst_addr_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_ADDR_USAGE' THEN
      l_inst_addr_usage_meaning := l_lookup_rec.meaning;
    ELSIF l_lookup_rec.lookup_code = 'INST_REC_ERR_WARN' THEN
      l_inst_rec_err_meaning := l_lookup_rec.meaning;
    END IF;

  END LOOP;


  FOR l_inst_note_rec IN log_inst_note_rcount_cur(p_batch_id) LOOP
    IF l_inst_note_rec.STAT =  '1' THEN
      l_comp_inst_note := l_inst_note_rec.CNT;
    ELSIF l_inst_note_rec.STAT =  '3' THEN
      l_err_inst_note := l_inst_note_rec.CNT;
    ELSIF l_inst_note_rec.STAT =  '4' THEN
      l_warn_inst_note := l_inst_note_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_note := l_comp_inst_note + l_err_inst_note + l_warn_inst_note;

  FOR l_inst_stat_rec IN log_inst_stat_rcount_cur(p_batch_id) LOOP
    IF l_inst_stat_rec.STAT =  '1' THEN
      l_comp_inst_stat := l_inst_stat_rec.CNT;
    ELSIF l_inst_stat_rec.STAT =  '3' THEN
      l_err_inst_stat := l_inst_stat_rec.CNT;
    ELSIF l_inst_stat_rec.STAT =  '4' THEN
      l_warn_inst_stat := l_inst_stat_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_stat := l_comp_inst_stat + l_err_inst_stat + l_warn_inst_stat;

  FOR l_inst_sdtl_rec IN log_inst_sdtl_rcount_cur(p_batch_id) LOOP
    IF l_inst_sdtl_rec.STAT =  '1' THEN
      l_comp_inst_sdtl := l_inst_sdtl_rec.CNT;
    ELSIF l_inst_sdtl_rec.STAT =  '3' THEN
      l_err_inst_sdtl := l_inst_sdtl_rec.CNT;
    ELSIF l_inst_sdtl_rec.STAT =  '4' THEN
      l_warn_inst_sdtl := l_inst_sdtl_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_sdtl := l_comp_inst_sdtl + l_err_inst_sdtl + l_warn_inst_sdtl;

  FOR l_inst_con_rec IN log_inst_con_rcount_cur(p_batch_id) LOOP
    IF l_inst_con_rec.STAT =  '1' THEN
      l_comp_inst_con := l_inst_con_rec.CNT;
    ELSIF l_inst_con_rec.STAT =  '3' THEN
      l_err_inst_con := l_inst_con_rec.CNT;
    ELSIF l_inst_con_rec.STAT =  '4' THEN
      l_warn_inst_con := l_inst_con_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_con := l_comp_inst_con + l_err_inst_con + l_warn_inst_con;

  FOR l_inst_cphn_rec IN log_inst_cphn_rcount_cur(p_batch_id) LOOP
    IF l_inst_cphn_rec.STAT =  '1' THEN
      l_comp_inst_cphn := l_inst_cphn_rec.CNT;
    ELSIF l_inst_cphn_rec.STAT =  '3' THEN
      l_err_inst_cphn := l_inst_cphn_rec.CNT;
    ELSIF l_inst_cphn_rec.STAT =  '4' THEN
      l_warn_inst_cphn := l_inst_cphn_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_cphn := l_comp_inst_cphn + l_err_inst_cphn + l_warn_inst_cphn;

  FOR l_inst_adr_rec IN log_inst_adr_rcount_cur(p_batch_id) LOOP
    IF l_inst_adr_rec.STAT =  '1' THEN
      l_comp_inst_adr := l_inst_adr_rec.CNT;
    ELSIF l_inst_adr_rec.STAT =  '3' THEN
      l_err_inst_adr := l_inst_adr_rec.CNT;
    ELSIF l_inst_adr_rec.STAT =  '4' THEN
      l_warn_inst_adr := l_inst_adr_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_adr := l_comp_inst_adr + l_err_inst_adr + l_warn_inst_adr;

  FOR l_inst_adru_rec IN log_inst_adru_rcount_cur(p_batch_id) LOOP
    IF l_inst_adru_rec.STAT =  '1' THEN
      l_comp_inst_adru := l_inst_adru_rec.CNT;
    ELSIF l_inst_adru_rec.STAT =  '3' THEN
      l_err_inst_adru := l_inst_adru_rec.CNT;
    ELSIF l_inst_adru_rec.STAT =  '4' THEN
      l_warn_inst_adru := l_inst_adru_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst_adru := l_comp_inst_adru + l_err_inst_adru + l_warn_inst_adru;


  -- Table deletion logic for 2 level Childs -- Contact and Contact Phone
  DELETE FROM IGS_OR_INST_CPHN_INT WHERE STATUS = '1';

  DELETE FROM IGS_OR_INST_CON_INT CON
  WHERE STATUS = '1' AND
        NOT EXISTS (SELECT 1
                    FROM IGS_OR_INST_CPHN_INT CPHN
                    WHERE CON.INTERFACE_CONTACTS_ID = CPHN.INTERFACE_CONT_ID AND
                          CPHN.STATUS = '3');

  UPDATE IGS_OR_INST_INT INST
  SET STATUS = '4',ERROR_CODE = 'E055'
  WHERE STATUS = '1' AND
        EXISTS (SELECT 1
                FROM IGS_OR_INST_CON_INT CON
                WHERE CON.INTERFACE_ID = INST.INTERFACE_ID);

  -- Table deletion logic for 2 level Childs -- Statistics and Statistics Details

  DELETE FROM IGS_OR_INST_SDTL_INT WHERE STATUS = '1';

  DELETE FROM IGS_OR_INST_STAT_INT STAT
  WHERE STATUS = '1' AND
        NOT EXISTS (SELECT 1
                    FROM IGS_OR_INST_SDTL_INT SDTL
                    WHERE STAT.INTERFACE_INST_STAT_ID = SDTL.INTERFACE_INST_STAT_ID AND
                          SDTL.STATUS = '3');

  UPDATE IGS_OR_INST_INT INST
  SET STATUS = '4',ERROR_CODE = 'E056'
  WHERE STATUS = '1' AND
        EXISTS (SELECT 1
                FROM IGS_OR_INST_STAT_INT STAT
                WHERE STAT.INTERFACE_ID = INST.INTERFACE_ID);

  -- Table deletion logic for 2 level Childs --  Address and Address Usage

  DELETE FROM IGS_OR_ADRUSGE_INT WHERE STATUS = '1';

  DELETE FROM IGS_OR_ADR_INT ADR
  WHERE STATUS = '1' AND
        NOT EXISTS (SELECT 1
                    FROM IGS_OR_ADRUSGE_INT ADU
                    WHERE ADR.INTERFACE_ADDR_ID = ADU.INTERFACE_ADDR_ID AND
                          ADU.STATUS = '3');

  UPDATE IGS_OR_INST_INT INST
  SET STATUS = '4',ERROR_CODE = 'E057'
  WHERE STATUS = '1' AND
        EXISTS (SELECT 1
                FROM IGS_OR_ADR_INT ADR
                WHERE ADR.INTERFACE_ID = INST.INTERFACE_ID);

  -- Table deletion logic for one level child

  DELETE FROM IGS_OR_INST_NTS_INT WHERE STATUS = '1';

  UPDATE IGS_OR_INST_INT INST
  SET STATUS = '4',ERROR_CODE='E058'
  WHERE STATUS = '1' AND
        EXISTS (SELECT 1
                FROM IGS_OR_INST_NTS_INT NTS
                WHERE NTS.INTERFACE_ID = INST.INTERFACE_ID);

  FOR l_inst_rec IN log_inst_rcount_cur(p_batch_id) LOOP
    IF l_inst_rec.STAT =  '1' THEN
      l_comp_inst := l_inst_rec.CNT;
    ELSIF l_inst_rec.STAT =  '3' THEN
      l_err_inst := l_inst_rec.CNT;
    ELSIF l_inst_rec.STAT =  '4' THEN
      l_warn_inst := l_inst_rec.CNT;
    END IF;
  END LOOP;
  l_tot_inst := l_comp_inst + l_err_inst + l_warn_inst;

  -- Delete in the main master table since it's status is now set appropriatly in the
  -- previous steps.

  DELETE FROM IGS_OR_INST_INT WHERE STATUS = '1';

  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_rec_err_meaning);
  FND_FILE.Put_Line(FND_FILE.Log,'-------------------------------------------');
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_MESSAGE.Set_Name('IGS','IGS_OR_INST_IMP_HEADER');
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'-------------------------------------------');

  FOR l_inst_err_rec IN log_inst_err_cur(p_batch_id,'3','4') LOOP
      FND_FILE.Put_Line(FND_FILE.Log,l_inst_err_rec.EREC);
  END LOOP;
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_note_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_note);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_note);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_note);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_note);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_stat_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_stat);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_stat);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_stat);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_stat);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_stat_dtl_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_sdtl);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_sdtl);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_sdtl);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_sdtl);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_cont_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_con);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_con);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_con);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_con);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_cont_phone_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_cphn);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_cphn);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_cphn);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_cphn);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_addr_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_adr);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_adr);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_adr);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_adr);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

  FND_FILE.Put_Line(FND_FILE.Log,l_inst_addr_usage_meaning);
  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_PRC');
  FND_MESSAGE.Set_Token('RCOUNT',l_tot_inst_adru);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_SUCC');
  FND_MESSAGE.Set_Token('RCOUNT',l_comp_inst_adru);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_AD_TOT_REC_FAIL');
  FND_MESSAGE.Set_Token('RCOUNT',l_err_inst_adru);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

  FND_MESSAGE.Set_Name('IGS','IGS_OR_TOT_REC_WARN');
  FND_MESSAGE.Set_Token('RCOUNT',l_warn_inst_adru);
  FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);
  FND_FILE.Put_Line(FND_FILE.Log,'');

 EXCEPTION
     WHEN OTHERS THEN
       IF gb_write_exception_log1 THEN
          FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                       'igs.plsql.igs_or_inst_imp_001.delete_log_int_rec.others',
                                       SQLERRM, NULL,NULL,NULL,NULL,NULL, IGS_OR_INST_IMP_001.G_REQUEST_ID);
       END IF;
       APP_EXCEPTION.Raise_Exception;
END delete_log_int_rec;

FUNCTION validate_inst_code(
  p_new_inst_code IN igs_or_inst_int.new_institution_cd%TYPE,
  p_exst_inst_code IN igs_or_inst_int.exst_institution_cd%TYPE,
  p_cwlk_inst_code IN igs_or_cwlk_v.inst_code%TYPE,
  p_interface_id IN igs_or_inst_int.interface_id%TYPE)
RETURN BOOLEAN AS
/*
  ||  Created By : ssaleem
  ||  Created On : 22-SEP-2003
  ||  Purpose : Compares crosswalk inst code with interface table and updates the status accordingly.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
 return_value         BOOLEAN;
BEGIN
 return_value := TRUE;

 IF  (p_exst_inst_code IS NOT NULL AND p_exst_inst_code <> p_cwlk_inst_code) OR
     (p_new_inst_code IS NOT NULL AND p_new_inst_code <> p_cwlk_inst_code) THEN

  return_value := FALSE;
  UPDATE igs_or_inst_int
  SET status='3',error_code='E059'
  WHERE interface_id = p_interface_id;

 END IF;

 RETURN return_value;

END validate_inst_code;

END igs_or_inst_imp_001;

/
