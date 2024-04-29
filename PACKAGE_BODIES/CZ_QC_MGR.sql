--------------------------------------------------------
--  DDL for Package Body CZ_QC_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_QC_MGR" as
/*  $Header: czqcmgrb.pls 120.1 2007/02/09 12:17:50 lkattamu ship $	*/

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure ASSESS_DATA is
begin
    null;
end;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_STATISTICS is
begin
    CZ_BASE_MGR.REDO_STATISTICS('QC');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure TRIGGERS_ENABLED
(Switch in varchar2) is
begin
    CZ_BASE_MGR.TRIGGERS_ENABLED('QC',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Switch in varchar2) is
begin
    CZ_BASE_MGR.CONSTRAINTS_ENABLED('QC',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
 incr           in integer default null) is
begin
    CZ_BASE_MGR.REDO_SEQUENCES('QC',RedoStart_Flag,incr);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Propogate_DeletedFlag IS
    TYPE t_arr      IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
    t_cfg_id        t_arr;
    t_cfg_nbr       t_arr;
BEGIN

     SELECT config_hdr_id,config_rev_nbr
     BULK COLLECT INTO t_cfg_id,t_cfg_nbr
     FROM CZ_CONFIG_HDRS WHERE deleted_flag='1';

     IF t_cfg_id.Count>0 THEN

        FORALL i IN t_cfg_id.First..t_cfg_id.Last
                 UPDATE CZ_CONFIG_EXT_ATTRIBUTES
                 SET deleted_flag='1'
                 WHERE config_hdr_id=t_cfg_id(i) AND config_rev_nbr=t_cfg_nbr(i)
                 AND deleted_flag='0';
        COMMIT;

        FORALL i IN t_cfg_id.First..t_cfg_id.Last
                 UPDATE CZ_CONFIG_ATTRIBUTES
                 SET deleted_flag='1'
                 WHERE config_hdr_id=t_cfg_id(i) AND config_rev_nbr=t_cfg_nbr(i)
                 AND deleted_flag='0';
        COMMIT;

        FORALL i IN t_cfg_id.First..t_cfg_id.Last
                 UPDATE CZ_CONFIG_ITEMS
                 SET deleted_flag='1'
                 WHERE config_hdr_id=t_cfg_id(i) AND config_rev_nbr=t_cfg_nbr(i)
                 AND deleted_flag='0';
        COMMIT;

        FORALL i IN t_cfg_id.First..t_cfg_id.Last
                 UPDATE CZ_CONFIG_INPUTS
                 SET deleted_flag='1'
                 WHERE config_hdr_id=t_cfg_id(i) AND config_rev_nbr=t_cfg_nbr(i)
                 AND deleted_flag='0';
        COMMIT;

        FORALL i IN t_cfg_id.First..t_cfg_id.Last
                 UPDATE CZ_CONFIG_MESSAGES
                 SET deleted_flag='1'
                 WHERE config_hdr_id=t_cfg_id(i) AND config_rev_nbr=t_cfg_nbr(i)
                 AND deleted_flag='0';
        COMMIT;

     END IF;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE PURGE IS
  TYPE t_arr      IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
  t_cfg_id        t_arr;
  t_cfg_nbr       t_arr;
  l_usage_exists   NUMBER;
  l_error_message  VARCHAR2(2000);
  l_Return_value   NUMBER;
  l_log_return_value BOOLEAN;
  PurgeDeleteConfigBatchsize NUMBER;
  CURSOR cur_configs IS
    SELECT config_hdr_id, config_rev_nbr
    FROM   cz_config_hdrs
    WHERE  (to_be_deleted_flag = '1'
    OR     deleted_flag = '1') and
	   component_instance_type = 'R';
BEGIN
  BEGIN
    SELECT value
    INTO   PurgeDeleteConfigBatchsize
    FROM   cz_db_settings
    WHERE  setting_id = 'PurgeDeleteConfigBatchsize';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      PurgeDeleteConfigBatchsize := 100;
  END;
  OPEN cur_configs;
  LOOP
    FETCH cur_configs
    BULK COLLECT INTO t_cfg_id, t_cfg_nbr LIMIT PurgeDeleteConfigBatchsize;
    EXIT WHEN ((cur_configs%NOTFOUND) AND (t_cfg_id.COUNT = 0));
    IF (t_cfg_id.COUNT > 0) THEN
      FOR i IN t_cfg_id.FIRST..t_cfg_id.LAST LOOP
        cz_cf_api.delete_configuration (
          t_cfg_id(i),
          t_cfg_nbr(i),
          l_usage_exists,
          l_error_message,
          l_Return_value
        );
        IF (l_Return_value <> 1) THEN
          l_log_return_value := CZ_UTILS.LOG_REPORT(l_error_message,1,'CZ_QC_MGR.PURGE',11276);
        END IF;
      END LOOP;
    END IF;
    COMMIT;
  END LOOP;
  CLOSE cur_configs;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure RESET_CLEAR is
begin
    null;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure MODIFIED
(AS_OF in OUT NOCOPY date) is
begin
    CZ_BASE_MGR.MODIFIED('QC',AS_OF);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

end;

/
