--------------------------------------------------------
--  DDL for Package Body CZ_IB_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IB_TRANSACTIONS" AS
/*  $Header: czibtxb.pls 120.8.12010000.4 2008/11/27 11:40:35 kdande ship $	*/

  G_IB_TXN_STATUS_PROCESSED  CONSTANT  VARCHAR2(10) := 'PROCESSED';

  TYPE cv_cursor_type IS REF CURSOR;

  --
  -- this method add log message to both CZ_DB_LOGS and FND LOG tables
  --
  PROCEDURE LOG_REPORT
  (p_run_id        IN VARCHAR2,
   p_error_message IN VARCHAR2,
   p_count         IN NUMBER) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
      IF (p_count IS NULL OR p_count<2) THEN
         m_COUNTER:=m_COUNTER+1;
         INSERT INTO CZ_DB_LOGS
             (RUN_ID,
              LOGTIME,
              LOGUSER,
              URGENCY,
              CALLER,
              STATUSCODE,
              MESSAGE,
              MESSAGE_ID)
         VALUES (p_run_id,
              SYSDATE,
              USER,
              1,
              'CZ_IB_TRANSACTIONS',
              11276,
              p_error_message,
              m_COUNTER);
         COMMIT;

         cz_utils.log_report('CZ_IB_TRANSACTIONS', null, m_COUNTER,
                              p_error_message, fnd_log.LEVEL_ERROR);

      ELSE
         FOR i IN 1..p_count
         LOOP
            m_COUNTER:=m_COUNTER+1;
            INSERT INTO CZ_DB_LOGS
               (RUN_ID,
                LOGTIME,
                LOGUSER,
                URGENCY,
                CALLER,
                STATUSCODE,
                MESSAGE,
                MESSAGE_ID)
            VALUES
                (p_run_id,
                SYSDATE,
                USER,
                1,
                'CZ_IB_TRANSACTIONS',
                11276,
                fnd_msg_pub.GET(i,fnd_api.g_false),
                m_COUNTER);
            COMMIT;

            cz_utils.log_report('CZ_IB_TRANSACTIONS', null, m_COUNTER,
                fnd_msg_pub.GET(i,fnd_api.g_false), fnd_log.LEVEL_ERROR);
         END LOOP;

      END IF;

  EXCEPTION
      WHEN OTHERS THEN
           NULL;
  END LOG_REPORT;

  PROCEDURE LOG_REPORT
  (p_run_id        IN VARCHAR2,
   p_error_message IN VARCHAR2) IS
  BEGIN
    LOG_REPORT
     (p_run_id        => p_run_id,
      p_error_message => p_error_message,
      p_count         => NULL);
  END LOG_REPORT;

  --
  -- DEBUG methods
  --
  PROCEDURE DEBUG(p_message IN VARCHAR2) IS
  BEGIN
      IF debug_mode = DEBUG_OUTPUT THEN
         --DBMS_OUTPUT.PUT_LINE(p_message);
         NULL;
      ELSE
         LOG_REPORT(m_RUN_ID,p_message);
      END IF;
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2,p_var_value IN VARCHAR2) IS
  BEGIN
      DEBUG(p_var_name||' = '||p_var_value);
  END DEBUG;

  PROCEDURE DEBUG(p_var_name IN VARCHAR2,p_var_value IN NUMBER) IS
  BEGIN
      DEBUG(p_var_name||' = '||TO_CHAR(p_var_value));
  END DEBUG;

  --
  -- method to initialize data
  --
  PROCEDURE Initialize
  (
    p_effective_date  IN DATE, -- DEFAULT SYSDATE
    p_init_fnd        IN VARCHAR2 DEFAULT NULL
  ) IS

  BEGIN
      IF p_init_fnd IS NULL THEN
        fnd_msg_pub.initialize;
      END IF;
      m_COUNTER:=0; m_CZ_IB_AUTO_EXPIRATION:='Y';

      --
      -- SYSDATE wull be used for enddating
      --
      m_EFFECTIVE_DATE := SYSDATE;

      SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO m_RUN_ID FROM dual;

      BEGIN
          SELECT VALUE INTO DEBUG_MODE FROM CZ_DB_SETTINGS
          WHERE UPPER(SETTING_ID)='CZ_IB_DEBUG_MODE' AND ROWNUM<2;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
      END;

      BEGIN
          m_CZ_IB_AUTO_EXPIRATION:=fnd_profile.VALUE('CZ_IB_AUTO_EXPIRATION');

          IF (m_CZ_IB_AUTO_EXPIRATION IS NULL OR UPPER(m_CZ_IB_AUTO_EXPIRATION) NOT IN('Y','N','YES','NO'))
             OR UPPER(m_CZ_IB_AUTO_EXPIRATION) IN ('Y','YES') THEN
             m_CZ_IB_AUTO_EXPIRATION:='Y';
          END IF;
      EXCEPTION
          WHEN OTHERS THEN
               m_CZ_IB_AUTO_EXPIRATION:='Y';
               LOG_REPORT(-m_RUN_ID,'Error in getting value of profile "CZ_IB_AUTO_EXPIRATION"');
      END;

  END Initialize;

  /* *** Probe function to check out CSI *** */
  FUNCTION CSI_Exists RETURN BOOLEAN IS
  BEGIN
      EXECUTE IMMEDIATE 'SELECT config_session_hdr_id FROM CSI_T_TRANSACTION_LINES WHERE rownum<2';
      RETURN TRUE;
  EXCEPTION
      WHEN OTHERS THEN
           RETURN FALSE;
  END CSI_Exists;

  PROCEDURE delete_transaction_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2
    ,p_init_msg_list          IN  VARCHAR2
    ,p_validation_level       IN  NUMBER
    ,p_transaction_line_id    IN  NUMBER
    ,p_api_caller_identity    IN  VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
      EXECUTE IMMEDIATE
      'BEGIN ' ||
      '     csi_t_txn_details_grp.delete_transaction_dtls ' ||
      '     ( ' ||
      '      p_api_version             => :1 ' ||
      '      ,p_commit                 => :2 ' ||
      '      ,p_init_msg_list          => :3 ' ||
      '      ,p_validation_level       => :4 ' ||
      '      ,p_api_caller_identity    => :5 ' ||
      '      ,p_transaction_line_id    => :6 ' ||
      '      ,x_return_status          => CZ_IB_TRANSACTIONS.m_return_status ' ||
      '      ,x_msg_count              => CZ_IB_TRANSACTIONS.m_msg_count ' ||
      '      ,x_msg_data               => CZ_IB_TRANSACTIONS.m_msg_data ' ||
      '     ); ' ||
      ' END;' USING p_api_version,p_commit,p_init_msg_list,p_validation_level,
                   p_api_caller_identity,p_transaction_line_id;

      x_return_status         := CZ_IB_TRANSACTIONS.m_return_status;
      x_msg_count             := CZ_IB_TRANSACTIONS.m_msg_count;
      x_msg_data              := CZ_IB_TRANSACTIONS.m_msg_data;
  EXCEPTION
      WHEN OTHERS THEN
           x_return_status    := FND_API.g_ret_sts_unexp_error;
           x_msg_count        := 1;
           x_msg_data         := 'CZ_IB_TRANSACTIONS.delete_transaction_dtls : '||SQLERRM;
           LOG_REPORT(m_RUN_ID,x_msg_data);
  END delete_transaction_dtls;


  PROCEDURE create_transaction_dtls(
    p_api_version           	IN     NUMBER,
    p_commit                	IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN     NUMBER   := fnd_api.g_valid_level_full,
    px_txn_line_rec          	IN OUT NOCOPY txn_line_rec ,
    px_txn_line_detail_tbl  	IN OUT NOCOPY txn_line_detail_tbl,
    px_txn_party_detail_tbl 	IN OUT NOCOPY txn_party_detail_tbl ,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl     	IN OUT NOCOPY txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl    	IN OUT NOCOPY txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl          IN OUT NOCOPY txn_systems_tbl,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2) IS

  BEGIN
      m_txn_line_rec            := px_txn_line_rec;
      m_txn_line_detail_tbl.DELETE;
      m_txn_line_detail_tbl     := px_txn_line_detail_tbl ;
      m_txn_ext_attrib_vals_tbl.DELETE;
      m_txn_ext_attrib_vals_tbl := px_txn_ext_attrib_vals_tbl;

      EXECUTE IMMEDIATE
'       DECLARE ' ||
'           t_txn_line_rec             csi_t_datastructures_grp.txn_line_rec; ' ||
'           t_txn_line_detail_tbl      csi_t_datastructures_grp.txn_line_detail_tbl; ' ||
'           t_txn_party_detail_tbl     csi_t_datastructures_grp.txn_party_detail_tbl; ' ||
'           t_txn_pty_acct_detail_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl; ' ||
'           t_txn_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl; ' ||
'           t_txn_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl; ' ||
'           t_txn_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl; ' ||
'           t_txn_systems_tbl          csi_t_datastructures_grp.txn_systems_tbl; ' ||
'       BEGIN ' ||
'           t_txn_line_rec.TRANSACTION_LINE_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.TRANSACTION_LINE_ID; ' ||
'           t_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID; ' ||
'           t_txn_line_rec.SOURCE_TRANSACTION_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_ID; ' ||
'           t_txn_line_rec.SOURCE_TXN_HEADER_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TXN_HEADER_ID; ' ||
'           t_txn_line_rec.SOURCE_TRANSACTION_TABLE := CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_TABLE; ' ||
'           t_txn_line_rec.CONFIG_SESSION_HDR_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_HDR_ID; ' ||
'           t_txn_line_rec.CONFIG_SESSION_REV_NUM := CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_REV_NUM; ' ||
'           t_txn_line_rec.CONFIG_SESSION_ITEM_ID := CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_ITEM_ID; ' ||
'           t_txn_line_rec.CONFIG_VALID_STATUS := CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_VALID_STATUS; ' ||
'           t_txn_line_rec.SOURCE_TRANSACTION_STATUS := CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_STATUS; ' ||
'           t_txn_line_rec.API_CALLER_IDENTITY := CZ_IB_TRANSACTIONS.m_txn_line_rec.API_CALLER_IDENTITY; ' ||
'           t_txn_line_rec.ERROR_CODE := CZ_IB_TRANSACTIONS.m_txn_line_rec.ERROR_CODE; ' ||
'           t_txn_line_rec.ERROR_EXPLANATION := CZ_IB_TRANSACTIONS.m_txn_line_rec.ERROR_EXPLANATION; ' ||
'           t_txn_line_rec.PROCESSING_STATUS := CZ_IB_TRANSACTIONS.m_txn_line_rec.PROCESSING_STATUS; ' ||
'           t_txn_line_rec.OBJECT_VERSION_NUMBER := CZ_IB_TRANSACTIONS.m_txn_line_rec.OBJECT_VERSION_NUMBER; ' ||
'           IF CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl.COUNT > 0 THEN ' ||
'              FOR i IN CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl.FIRST..CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl.LAST ' ||
'              LOOP ' ||
'                 t_txn_line_detail_tbl(i).config_inst_hdr_id     := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).config_inst_hdr_id; ' ||
'                 t_txn_line_detail_tbl(i).config_inst_rev_num    := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).config_inst_rev_num; ' ||
'                 t_txn_line_detail_tbl(i).config_inst_item_id    := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).config_inst_item_id; ' ||
'                 t_txn_line_detail_tbl(i).source_transaction_flag:= CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).source_transaction_flag; ' ||
'                 t_txn_line_detail_tbl(i).instance_exists_flag   := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).instance_exists_flag; ' ||
'                 t_txn_line_detail_tbl(i).quantity               := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).quantity; ' ||
'                 t_txn_line_detail_tbl(i).unit_of_measure        := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).unit_of_measure; ' ||
'                 t_txn_line_detail_tbl(i).location_id            := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).location_id; ' ||
'                 t_txn_line_detail_tbl(i).location_type_code     := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).location_type_code; ' ||
'                 t_txn_line_detail_tbl(i).inventory_item_id      := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).inventory_item_id; ' ||
'                 t_txn_line_detail_tbl(i).inv_organization_id    := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).inv_organization_id; ' ||
'                 t_txn_line_detail_tbl(i).mfg_serial_number_flag := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).mfg_serial_number_flag; ' ||
'                 t_txn_line_detail_tbl(i).sub_type_id            := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).sub_type_id; ' ||
'                 t_txn_line_detail_tbl(i).instance_description   := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).instance_description; ' ||
'                 t_txn_line_detail_tbl(i).config_inst_baseline_rev_num := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).config_inst_baseline_rev_num; ' ||
'                 t_txn_line_detail_tbl(i).active_end_date        := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).active_end_date; ' ||
'                 t_txn_line_detail_tbl(i).object_version_number  := CZ_IB_TRANSACTIONS.m_txn_line_detail_tbl(i).object_version_number; ' ||
'              END LOOP; ' ||
'           END IF; ' ||
'           IF CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl.COUNT > 0 THEN ' ||
'              FOR i IN CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl.FIRST..CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl.LAST ' ||
'              LOOP ' ||
'                 t_txn_ext_attrib_vals_tbl(i).TXN_ATTRIB_DETAIL_ID   := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).TXN_ATTRIB_DETAIL_ID; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).TXN_LINE_DETAIL_ID     := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).TXN_LINE_DETAIL_ID; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ATTRIB_SOURCE_TABLE    := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ATTRIB_SOURCE_TABLE; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_SOURCE_ID    := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_SOURCE_ID; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_VALUE        := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_VALUE; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_CODE         := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_CODE; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_LEVEL        := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ATTRIBUTE_LEVEL; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).API_CALLER_IDENTITY    := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).API_CALLER_IDENTITY; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).PROCESS_FLAG           := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).PROCESS_FLAG; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ACTIVE_START_DATE      := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ACTIVE_START_DATE; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).ACTIVE_END_DATE        := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).ACTIVE_END_DATE; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).PRESERVE_DETAIL_FLAG   := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).PRESERVE_DETAIL_FLAG; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).CONTEXT                := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).CONTEXT; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).TXN_LINE_DETAILS_INDEX := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).TXN_LINE_DETAILS_INDEX; ' ||
'                 t_txn_ext_attrib_vals_tbl(i).OBJECT_VERSION_NUMBER  := CZ_IB_TRANSACTIONS.m_txn_ext_attrib_vals_tbl(i).OBJECT_VERSION_NUMBER; ' ||
'              END LOOP; ' ||
'           END IF; ' ||
'           csi_t_txn_details_grp.create_transaction_dtls ' ||
'           ( ' ||
'           p_api_version               => :1, ' ||
'           p_commit                    => :2, ' ||
'           p_init_msg_list             => :3, ' ||
'           p_validation_level          => :4, ' ||
'           px_txn_line_rec             => t_txn_line_rec, ' ||
'           px_txn_line_detail_tbl      => t_txn_line_detail_tbl, ' ||
'           px_txn_party_detail_tbl     => t_txn_party_detail_tbl , ' ||
'           px_txn_pty_acct_detail_tbl  => t_txn_pty_acct_detail_tbl, ' ||
'           px_txn_ii_rltns_tbl         => t_txn_ii_rltns_tbl, ' ||
'           px_txn_org_assgn_tbl        => t_txn_org_assgn_tbl, ' ||
'           px_txn_ext_attrib_vals_tbl  => t_txn_ext_attrib_vals_tbl, ' ||
'           px_txn_systems_tbl          => t_txn_systems_tbl, ' ||
'           x_return_status             => CZ_IB_TRANSACTIONS.m_return_status, ' ||
'           x_msg_count                 => CZ_IB_TRANSACTIONS.m_msg_count, ' ||
'           x_msg_data                  => CZ_IB_TRANSACTIONS.m_msg_data ' ||
'           ); ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.TRANSACTION_LINE_ID := t_txn_line_rec.TRANSACTION_LINE_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID := t_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_ID := t_txn_line_rec.SOURCE_TRANSACTION_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TXN_HEADER_ID := t_txn_line_rec.SOURCE_TXN_HEADER_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_TABLE := t_txn_line_rec.SOURCE_TRANSACTION_TABLE; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_HDR_ID := t_txn_line_rec.CONFIG_SESSION_HDR_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_REV_NUM := t_txn_line_rec.CONFIG_SESSION_REV_NUM; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_SESSION_ITEM_ID := t_txn_line_rec.CONFIG_SESSION_ITEM_ID; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.CONFIG_VALID_STATUS := t_txn_line_rec.CONFIG_VALID_STATUS; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.SOURCE_TRANSACTION_STATUS := t_txn_line_rec.SOURCE_TRANSACTION_STATUS; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.API_CALLER_IDENTITY := t_txn_line_rec.API_CALLER_IDENTITY; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.ERROR_CODE := t_txn_line_rec.ERROR_CODE; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.ERROR_EXPLANATION := t_txn_line_rec.ERROR_EXPLANATION; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.PROCESSING_STATUS := t_txn_line_rec.PROCESSING_STATUS; ' ||
'           CZ_IB_TRANSACTIONS.m_txn_line_rec.OBJECT_VERSION_NUMBER := t_txn_line_rec.OBJECT_VERSION_NUMBER; ' ||
'       END;' USING p_api_version,p_commit,p_init_msg_list,p_validation_level;

      px_txn_line_rec:=m_txn_line_rec;
      px_txn_line_detail_tbl:=m_txn_line_detail_tbl;
      px_txn_ext_attrib_vals_tbl:=m_txn_ext_attrib_vals_tbl;

      m_txn_line_detail_tbl.DELETE;
      m_txn_ext_attrib_vals_tbl.DELETE;

      x_return_status         := CZ_IB_TRANSACTIONS.m_return_status;
      x_msg_count             := CZ_IB_TRANSACTIONS.m_msg_count;
      x_msg_data              := CZ_IB_TRANSACTIONS.m_msg_data;
  EXCEPTION
      WHEN OTHERS THEN
           x_return_status    := FND_API.g_ret_sts_unexp_error;
           x_msg_count        := 1;
           x_msg_data         := 'CZ_IB_TRANSACTIONS.create_transaction_dtls : '||SQLERRM;
           LOG_REPORT(m_RUN_ID,x_msg_data);
  END create_transaction_dtls;


  PROCEDURE create_txn_ii_rltns_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_ii_rltns_tbl     IN  OUT NOCOPY txn_ii_rltns_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2) IS

  BEGIN
      m_txn_ii_rltns_tbl.DELETE;
      m_txn_ii_rltns_tbl:=px_txn_ii_rltns_tbl;

      EXECUTE IMMEDIATE
'       DECLARE ' ||
'             t_txn_ii_rltns_tbl  csi_t_datastructures_grp.txn_ii_rltns_tbl; ' ||
'       BEGIN ' ||
'           IF CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl.COUNT>0 THEN ' ||
'              FOR i IN CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl.FIRST..CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl.LAST ' ||
'              LOOP ' ||
'                t_txn_ii_rltns_tbl(i).TXN_RELATIONSHIP_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TXN_RELATIONSHIP_ID; ' ||
'                t_txn_ii_rltns_tbl(i).TRANSACTION_LINE_ID  := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TRANSACTION_LINE_ID; ' ||
'                t_txn_ii_rltns_tbl(i).CSI_INST_RELATIONSHIP_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).CSI_INST_RELATIONSHIP_ID; ' ||
'                t_txn_ii_rltns_tbl(i).SUBJECT_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_ID; ' ||
'                t_txn_ii_rltns_tbl(i).SUBJECT_INDEX_FLAG := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_INDEX_FLAG; ' ||
'                t_txn_ii_rltns_tbl(i).SUBJECT_TYPE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_TYPE; ' ||
'                t_txn_ii_rltns_tbl(i).OBJECT_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_ID; ' ||
'                t_txn_ii_rltns_tbl(i).OBJECT_INDEX_FLAG := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_INDEX_FLAG; ' ||
'                t_txn_ii_rltns_tbl(i).OBJECT_TYPE  := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_TYPE; ' ||
'                t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_HDR_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_HDR_ID; ' ||
'                t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_REV_NUM := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_REV_NUM; ' ||
'                t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_ITEM_ID  := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_ITEM_ID; ' ||
'                t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_HDR_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_HDR_ID; ' ||
'                t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_REV_NUM := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_REV_NUM; ' ||
'                t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_ITEM_ID := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_ITEM_ID; ' ||
'                t_txn_ii_rltns_tbl(i).TARGET_COMMITMENT_DATE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TARGET_COMMITMENT_DATE; ' ||
'                t_txn_ii_rltns_tbl(i).API_CALLER_IDENTITY := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).API_CALLER_IDENTITY; ' ||
'                t_txn_ii_rltns_tbl(i).RELATIONSHIP_TYPE_CODE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).RELATIONSHIP_TYPE_CODE; ' ||
'                t_txn_ii_rltns_tbl(i).DISPLAY_ORDER := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).DISPLAY_ORDER; ' ||
'                t_txn_ii_rltns_tbl(i).POSITION_REFERENCE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).POSITION_REFERENCE; ' ||
'                t_txn_ii_rltns_tbl(i).MANDATORY_FLAG := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).MANDATORY_FLAG; ' ||
'                t_txn_ii_rltns_tbl(i).ACTIVE_START_DATE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).ACTIVE_START_DATE; ' ||
'                t_txn_ii_rltns_tbl(i).ACTIVE_END_DATE := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).ACTIVE_END_DATE; ' ||
'                t_txn_ii_rltns_tbl(i).CONTEXT := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).CONTEXT; ' ||
'                t_txn_ii_rltns_tbl(i).OBJECT_VERSION_NUMBER := CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_VERSION_NUMBER; ' ||
'              END LOOP; ' ||
'           END IF; ' ||
'           csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls ' ||
'           ( ' ||
'           p_api_version           => :1, ' ||
'           p_commit                => :2, ' ||
'           p_init_msg_list         => :3, ' ||
'           p_validation_level      => :4, ' ||
'           px_txn_ii_rltns_tbl     => t_txn_ii_rltns_tbl, ' ||
'           x_return_status         => CZ_IB_TRANSACTIONS.m_return_status, ' ||
'           x_msg_count             => CZ_IB_TRANSACTIONS.m_msg_count, ' ||
'           x_msg_data              => CZ_IB_TRANSACTIONS.m_msg_data ' ||
'           ); ' ||
'          IF t_txn_ii_rltns_tbl.COUNT>0 THEN ' ||
'             FOR i IN t_txn_ii_rltns_tbl.FIRST..t_txn_ii_rltns_tbl.LAST ' ||
'             LOOP ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TXN_RELATIONSHIP_ID := t_txn_ii_rltns_tbl(i).TXN_RELATIONSHIP_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TRANSACTION_LINE_ID  := t_txn_ii_rltns_tbl(i).TRANSACTION_LINE_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).CSI_INST_RELATIONSHIP_ID := t_txn_ii_rltns_tbl(i).CSI_INST_RELATIONSHIP_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_ID := t_txn_ii_rltns_tbl(i).SUBJECT_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_INDEX_FLAG := t_txn_ii_rltns_tbl(i).SUBJECT_INDEX_FLAG; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUBJECT_TYPE := t_txn_ii_rltns_tbl(i).SUBJECT_TYPE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_ID := t_txn_ii_rltns_tbl(i).OBJECT_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_INDEX_FLAG := t_txn_ii_rltns_tbl(i).OBJECT_INDEX_FLAG; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_TYPE  := t_txn_ii_rltns_tbl(i).OBJECT_TYPE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_HDR_ID := t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_HDR_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_REV_NUM := t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_REV_NUM; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_ITEM_ID  := t_txn_ii_rltns_tbl(i).SUB_CONFIG_INST_ITEM_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_HDR_ID := t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_HDR_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_REV_NUM := t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_REV_NUM; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_ITEM_ID := t_txn_ii_rltns_tbl(i).OBJ_CONFIG_INST_ITEM_ID; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).TARGET_COMMITMENT_DATE := t_txn_ii_rltns_tbl(i).TARGET_COMMITMENT_DATE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).API_CALLER_IDENTITY := t_txn_ii_rltns_tbl(i).API_CALLER_IDENTITY; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).RELATIONSHIP_TYPE_CODE := t_txn_ii_rltns_tbl(i).RELATIONSHIP_TYPE_CODE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).DISPLAY_ORDER := t_txn_ii_rltns_tbl(i).DISPLAY_ORDER; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).POSITION_REFERENCE := t_txn_ii_rltns_tbl(i).POSITION_REFERENCE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).MANDATORY_FLAG := t_txn_ii_rltns_tbl(i).MANDATORY_FLAG; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).ACTIVE_START_DATE := t_txn_ii_rltns_tbl(i).ACTIVE_START_DATE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).ACTIVE_END_DATE := t_txn_ii_rltns_tbl(i).ACTIVE_END_DATE; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).CONTEXT := t_txn_ii_rltns_tbl(i).CONTEXT; ' ||
'                CZ_IB_TRANSACTIONS.m_txn_ii_rltns_tbl(i).OBJECT_VERSION_NUMBER := t_txn_ii_rltns_tbl(i).OBJECT_VERSION_NUMBER; ' ||
'             END LOOP; ' ||
'          END IF; ' ||
'       END;' USING p_api_version,p_commit,p_init_msg_list,p_validation_level;

      px_txn_ii_rltns_tbl:=m_txn_ii_rltns_tbl;
      m_txn_ii_rltns_tbl.DELETE;

      x_return_status         := CZ_IB_TRANSACTIONS.m_return_status;
      x_msg_count             := CZ_IB_TRANSACTIONS.m_msg_count;
      x_msg_data              := CZ_IB_TRANSACTIONS.m_msg_data;

  EXCEPTION
      WHEN OTHERS THEN
           x_return_status    := FND_API.g_ret_sts_unexp_error;
           x_msg_count        := 1;
           x_msg_data         := 'CZ_IB_TRANSACTIONS.create_txn_ii_rltns_dtls : '||SQLERRM;
           LOG_REPORT(m_RUN_ID,x_msg_data);
  END create_txn_ii_rltns_dtls;


  PROCEDURE get_connected_configurations
  (
  p_config_query_table     IN     config_query_table,
  p_instance_level         IN     VARCHAR2,
  x_config_pair_table      OUT NOCOPY    config_pair_table,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_return_message         OUT NOCOPY    VARCHAR2
  ) IS

    l_ndebug  NUMBER := 0;

  BEGIN

      m_config_query_table:=p_config_query_table;
      EXECUTE IMMEDIATE
'       DECLARE ' ||
'           t_config_query_table      CSI_CZ_INT.config_query_table; ' ||
'           t_config_pair_table       CSI_CZ_INT.config_pair_table; ' ||
'           l_ndebug                  NUMBER := 0; ' ||
'       BEGIN ' ||
'           IF CZ_IB_TRANSACTIONS.m_config_query_table.COUNT > 0 THEN ' ||
'              FOR i IN CZ_IB_TRANSACTIONS.m_config_query_table.FIRST..CZ_IB_TRANSACTIONS.m_config_query_table.LAST ' ||
'              LOOP ' ||
'                 t_config_query_table(i).config_header_id := CZ_IB_TRANSACTIONS.m_config_query_table(i).config_header_id; ' ||
'                 t_config_query_table(i).config_revision_number := CZ_IB_TRANSACTIONS.m_config_query_table(i).config_revision_number; ' ||
'                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'                   cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_connected_configurations'', l_ndebug, ' ||
'                    ''csi_cz_int.get_connected_configurations() : parameters p_config_query_table(''||TO_CHAR(i)|| ' ||
'                    '').config_header_id = ''||TO_CHAR(t_config_query_table(i).config_header_id)|| ' ||
'                    '' p_config_query_table(''||TO_CHAR(i)|| ' ||
'                    '').config_revision_number = ''||TO_CHAR(t_config_query_table(i).config_revision_number)|| ' ||
'                    '' : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                     fnd_log.LEVEL_STATEMENT); ' ||
'                  END IF; ' ||
'              END LOOP; ' ||
'           END IF; ' ||
'           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'             cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_connected_configurations'', l_ndebug, ' ||
'                  ''csi_cz_int.get_connected_configurations() will be called : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                   fnd_log.LEVEL_STATEMENT); ' ||
'           END IF; ' ||
'           csi_cz_int.get_connected_configurations ' ||
'           ( ' ||
'            p_config_query_table     => t_config_query_table, ' ||
'            p_instance_level         => :1, ' ||
'            x_config_pair_table      => t_config_pair_table, ' ||
'            x_return_status          => CZ_IB_TRANSACTIONS.m_return_status, ' ||
'            x_return_message         => CZ_IB_TRANSACTIONS.m_return_message ' ||
'           ); ' ||
'           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'             cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_connected_configurations'', l_ndebug, ' ||
'                   ''csi_cz_int.get_connected_configurations() has been called : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                    fnd_log.LEVEL_STATEMENT); ' ||
'           END IF; ' ||
'           IF t_config_pair_table.COUNT > 0 THEN ' ||
'              FOR i IN t_config_pair_table.FIRST..t_config_pair_table.LAST ' ||
'              LOOP ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).subject_header_id      := t_config_pair_table(i).subject_header_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).subject_revision_number:= t_config_pair_table(i).subject_revision_number; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).subject_item_id        := t_config_pair_table(i).subject_item_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).object_header_id       := t_config_pair_table(i).object_header_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).object_revision_number := t_config_pair_table(i).object_revision_number; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).object_item_id         := t_config_pair_table(i).object_item_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).root_header_id         := t_config_pair_table(i).root_header_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).root_revision_number   := t_config_pair_table(i).root_revision_number; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).root_item_id           := t_config_pair_table(i).root_item_id; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).SOURCE_APPLICATION_ID  := t_config_pair_table(i).SOURCE_APPLICATION_ID; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).SOURCE_TXN_HEADER_REF  := t_config_pair_table(i).SOURCE_TXN_HEADER_REF; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).SOURCE_TXN_LINE_REF1   := t_config_pair_table(i).SOURCE_TXN_LINE_REF1; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).SOURCE_TXN_LINE_REF2   := t_config_pair_table(i).SOURCE_TXN_LINE_REF2; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).SOURCE_TXN_LINE_REF3   := t_config_pair_table(i).SOURCE_TXN_LINE_REF3; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).LOCK_ID                := t_config_pair_table(i).LOCK_ID; ' ||
'                 CZ_IB_TRANSACTIONS.m_config_pair_table(i).LOCK_STATUS            := t_config_pair_table(i).LOCK_STATUS; ' ||
'                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'                   cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_connected_configurations'', l_ndebug, ' ||
'                    ''Out array for get_connected_configurations() has been populated : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                     fnd_log.LEVEL_STATEMENT); ' ||
'                 END IF; ' ||
'              END LOOP; ' ||
'           END IF; ' ||
'       END;' USING p_instance_level;

       x_config_pair_table := m_config_pair_table;
       m_config_pair_table.DELETE;

       x_return_status          := CZ_IB_TRANSACTIONS.m_return_status;
       x_return_message         := CZ_IB_TRANSACTIONS.m_return_message;

  EXCEPTION
       WHEN OTHERS THEN
            x_return_status    := FND_API.g_ret_sts_unexp_error;
            x_return_message   := 'CZ_IB_TRANSACTIONS.Get_Connected_Configurations : '||SQLERRM;

            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              cz_utils.log_report('CZ_IB_TRANSACTIONS', 'get_connected_configurations', l_ndebug,
                    'Fatal error : '||SQLERRM||' : current time : '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24-MI-SS'),
                     fnd_log.LEVEL_ERROR);
            END IF;

            LOG_REPORT(m_RUN_ID,x_return_message);
  END get_connected_configurations;

  PROCEDURE get_configuration_revision
  (
  p_config_header_id       IN     NUMBER,
  p_target_commitment_date IN     DATE,
  px_instance_level        IN OUT NOCOPY VARCHAR2,
  x_config_rev_number      OUT NOCOPY    NUMBER,
  x_config_rec             OUT NOCOPY    config_rec,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_return_message         OUT NOCOPY    VARCHAR2
  ) IS

    l_ndebug NUMBER := 1;

  BEGIN

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         cz_utils.log_report('CZ_IB_TRANSACTIONS', 'get_configuration_revision', l_ndebug,
          'csi_cz_int.get_configuration_revision() parameters  : p_config_header_id='||TO_CHAR(p_config_header_id)||
          ' p_target_commitment_date='||TO_CHAR(p_target_commitment_date,'DD-MM-YYYY HH24-MI-SS')||
          ' px_instance_level='||px_instance_level||
          ' :  current time : '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24-MI-SS'),
          fnd_log.LEVEL_STATEMENT);
       END IF;

       EXECUTE IMMEDIATE
'      DECLARE ' ||
'           v_instance_level     VARCHAR2(255):='''||px_instance_level||'''; ' ||
'           l_config_rec         CSI_CZ_INT.config_rec; ' ||
'           l_ndebug             NUMBER := 1; ' ||
'       BEGIN ' ||
'           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'             cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_configuration_revision'', l_ndebug, ' ||
'                    ''csi_cz_int.get_configuration_revision() will be called : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                     fnd_log.LEVEL_STATEMENT); ' ||
'           END IF; ' ||
'           csi_cz_int.get_configuration_revision ' ||
'           ( ' ||
'            p_config_header_id       => :1, ' ||
'            p_target_commitment_date => :2, ' ||
'            px_instance_level        => v_instance_level, ' ||
'            x_install_config_rec     => l_config_rec, ' ||
'            x_return_status          => CZ_IB_TRANSACTIONS.m_return_status, ' ||
'            x_return_message         => CZ_IB_TRANSACTIONS.m_return_message ' ||
'           ); ' ||
'           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'             cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_configuration_revision'', l_ndebug, ' ||
'                    ''csi_cz_int.get_configuration_revision() has been called : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                     fnd_log.LEVEL_STATEMENT); ' ||
'           END IF; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.source_application_id  := l_config_rec.source_application_id; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.source_txn_header_ref  := l_config_rec.source_txn_header_ref; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.source_txn_line_ref1   := l_config_rec.source_txn_line_ref1; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.source_txn_line_ref2   := l_config_rec.source_txn_line_ref2; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.source_txn_line_ref3   := l_config_rec.source_txn_line_ref3; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.instance_id            := l_config_rec.instance_id; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.lock_id                := l_config_rec.lock_id; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.lock_status            := l_config_rec.lock_status; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.config_inst_hdr_id     := l_config_rec.config_inst_hdr_id; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.config_inst_item_id    := l_config_rec.config_inst_item_id; ' ||
'           CZ_IB_TRANSACTIONS.m_config_rec.config_inst_rev_num    := l_config_rec.config_inst_rev_num; ' ||
'           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN ' ||
'             cz_utils.log_report(''CZ_IB_TRANSACTIONS'', ''get_configuration_revision'', l_ndebug, ' ||
'                    ''Out array for get_configuration_revision() has been populated : current time : ''||TO_CHAR(SYSDATE,''DD-MM-YYYY HH24-MI-SS''), ' ||
'                     fnd_log.LEVEL_STATEMENT); ' ||
'           END IF; ' ||
'       END;' USING p_config_header_id,p_target_commitment_date;

       x_config_rev_number      := CZ_IB_TRANSACTIONS.m_config_rev_number;
       x_config_rec             := CZ_IB_TRANSACTIONS.m_config_rec;
       x_return_status          := CZ_IB_TRANSACTIONS.m_return_status;
       x_return_message         := CZ_IB_TRANSACTIONS.m_return_message;

  EXCEPTION
       WHEN OTHERS THEN
            x_return_status    := FND_API.g_ret_sts_unexp_error;
            x_return_message   := 'CZ_IB_TRANSACTIONS.Get_Configuration_Revision : '||SQLERRM;
            LOG_REPORT(m_RUN_ID,x_return_message);

            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              cz_utils.log_report('CZ_IB_TRANSACTIONS', 'get_configuration_revision', l_ndebug,
                  'Fatal error : '||SQLERRM||' : current time : '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24-MI-SS'),
                   fnd_log.LEVEL_ERROR);
            END IF;
  END get_configuration_revision;

  --
  -- propogate is_item_changed property
  --
  PROCEDURE propogate_Changed_Property
  (
   p_config_item_id         IN NUMBER,
   p_is_item_changed        IN VARCHAR2,
   p_config_item_tbl        IN int_array_tbl_type,
   p_parent_config_item_tbl IN int_array_tbl_type,
   p_is_item_changed_tbl    IN char_array_tbl_type,
   p_ib_trackable_tbl       IN char_array_tbl_type,
   px_hash_changed_item_tbl IN OUT NOCOPY int_array_tbl_type_idx_vc2, --  Bug 6892148;
   px_hash_src_txn_flag_tbl IN OUT NOCOPY char_array_tbl_type_idx_vc2 --  Bug 6892148;
   ) IS

      v_is_item_changed VARCHAR2(255);

  BEGIN

      IF p_config_item_tbl.COUNT = 0 THEN
         RETURN;
      END IF;

      --
      -- propogate item_changed property and populate hash map
      -- with the config_item_id of the nearest changed item
      --
      FOR i IN p_config_item_tbl.FIRST..p_config_item_tbl.LAST
      LOOP
         IF p_ib_trackable_tbl(i)='1' THEN

           IF p_parent_config_item_tbl(i) = p_config_item_id THEN
             IF p_is_item_changed_tbl(i) = '0' THEN
                px_hash_changed_item_tbl(p_config_item_tbl(i)):=p_config_item_id;
                px_hash_src_txn_flag_tbl(p_config_item_tbl(i)):='N';
                v_is_item_changed:=p_is_item_changed;
             END IF;

             IF p_is_item_changed_tbl(i) = '1' THEN
                px_hash_changed_item_tbl(p_config_item_tbl(i)):=p_config_item_tbl(i);
                v_is_item_changed:='1';
             END IF;

             propogate_Changed_Property( p_config_item_tbl(i),
                                         v_is_item_changed,
                                         p_config_item_tbl,
                                         p_parent_config_item_tbl,
                                         p_is_item_changed_tbl,
                                         p_ib_trackable_tbl,
                                         px_hash_changed_item_tbl,
                                         px_hash_src_txn_flag_tbl);
          END IF;
        END IF;
      END LOOP;

  END propogate_Changed_Property;

  --
  -- delete IB data
  --
  PROCEDURE remove_IB_Config
  (
  p_session_config_hdr_id  IN  NUMBER DEFAULT NULL,
  p_session_config_rev_nbr IN  NUMBER DEFAULT NULL,
  p_instance_hdr_id        IN  NUMBER DEFAULT NULL,
  p_instance_rev_nbr       IN  NUMBER DEFAULT NULL,
  p_instance_item_id       IN  NUMBER DEFAULT NULL,
  x_run_id                 OUT NOCOPY NUMBER
  ) IS

      cv_csi_txl_line          cv_cursor_type;

      t_subject_tbl            int_array_tbl_type;
      t_transaction_line_tbl   int_array_tbl_type;

      v_transaction_line_id     NUMBER;
      v_return_status           VARCHAR2(255) := fnd_api.g_ret_sts_success;
      v_msg_data                VARCHAR2(2000);
      v_msg_count               NUMBER;

  BEGIN
      x_run_id:=0;

      --
      -- fix for the #2860167 :
      -- if CSI_T_TRANSACTION_LINES does not contain column config_session_hdr_id
      -- then function CSI_Exists return FALSE
      -- and algorithm stops ( no errors - we just assume that old IB schema is used)
      --
      IF NOT(CSI_Exists) THEN
         RETURN;
      END IF;

      Initialize(SYSDATE, '0');

      IF p_session_config_hdr_id IS NOT NULL THEN
         OPEN cv_csi_txl_line FOR
         'SELECT transaction_line_id FROM CSI_T_TRANSACTION_LINES
                   WHERE config_session_hdr_id = :1 AND config_session_rev_num = :2 AND
                         config_session_item_id=NVL(:3,config_session_item_id) AND processing_status <> :4'
         USING p_session_config_hdr_id,p_session_config_rev_nbr,p_instance_item_id,G_IB_TXN_STATUS_PROCESSED;
         LOOP

            FETCH cv_csi_txl_line INTO v_transaction_line_id;
            EXIT WHEN cv_csi_txl_line%NOTFOUND;

            -- csi_t_txn_details_grp.delete_transaction_dtls --
            delete_transaction_dtls
            (
             p_api_version           	=> 1.0
            ,p_commit                	=> fnd_api.g_false
            ,p_init_msg_list         	=> fnd_api.g_false
            ,p_validation_level           => fnd_api.g_valid_level_none
            ,p_api_caller_identity        => 'CONFIG'
            ,p_transaction_line_id   	=> v_transaction_line_id
            ,x_return_status         	=> v_return_status
            ,x_msg_count             	=> v_msg_count
            ,x_msg_data              	=> v_msg_data
            );

            IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
               x_run_id:=m_RUN_ID;
               LOG_REPORT(m_RUN_ID,
                         'Deleting failed for txn line : transaction_line_id='||TO_CHAR(v_transaction_line_id)||' IB API error message : '||v_msg_data,
                         v_msg_count);
            END IF;
         END LOOP;
         CLOSE cv_csi_txl_line;
         RETURN;
      END IF;

      -- bug 5696750: apart from processing_status, csi also checks if csi_transaction_id is not null
      -- when querying table csi_t_txn_line_details (see csi_t_vldn_routines_pvt.check_ib_creation).
      -- We may need to do the same thing here as csi does. We only verified with csi team about the
      -- correctness of the process status check when using sesssion header and csi_t_transaction_lines.
      -- Currently we do not use instance hdr in this aspect. If in the future instance hdr is used,
      -- we will need to revisit here.
      IF p_instance_hdr_id IS NOT NULL THEN
         OPEN cv_csi_txl_line FOR
         'SELECT DISTINCT transaction_line_id
          FROM CSI_T_TXN_LINE_DETAILS
          WHERE config_inst_hdr_id  = :1 AND config_inst_rev_num = :2 AND processing_status <> :3'
          USING p_instance_hdr_id,p_instance_rev_nbr,G_IB_TXN_STATUS_PROCESSED;
         LOOP
            FETCH cv_csi_txl_line INTO v_transaction_line_id;
            EXIT WHEN cv_csi_txl_line%NOTFOUND;

            -- csi_t_txn_details_grp.delete_transaction_dtls --
            delete_transaction_dtls
            (
             p_api_version           	=> 1.0
            ,p_commit                	=> fnd_api.g_false
            ,p_init_msg_list         	=> fnd_api.g_false
            ,p_validation_level           => fnd_api.g_valid_level_none
            ,p_api_caller_identity        => 'CONFIG'
            ,p_transaction_line_id   	=> v_transaction_line_id
            ,x_return_status         	=> v_return_status
            ,x_msg_count             	=> v_msg_count
            ,x_msg_data              	=> v_msg_data
            );

            IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
               x_run_id:=m_RUN_ID;
               LOG_REPORT(m_RUN_ID,'Deleting failed for txn line : transaction_line_id='||
                 TO_CHAR(v_transaction_line_id)||' IB API error message : '||v_msg_data,v_msg_count);
            END IF;
         END LOOP;
      END IF;

  EXCEPTION
      WHEN OTHERS THEN
           IF cv_csi_txl_line%ISOPEN THEN
              CLOSE cv_csi_txl_line;
           END IF;
           x_run_id:=m_RUN_ID;
           LOG_REPORT(m_RUN_ID,'Deleting failed : '||SQLERRM);
  END remove_IB_Config;

  --
  -- collect all Config Items from subtree
  -- with root <=> (p_config_hdr_id, p_new_config_rev_nbr, p_config_item_id)
  -- and insert data into IB
  --

  PROCEDURE populate_IB_Txn
  (
  p_config_hdr_id          IN  NUMBER,                -- config_hdr_id of root node
  p_config_rev_nbr         IN  NUMBER,                -- config_rev_nbr of root node
  p_config_item_id         IN  NUMBER,                -- config_item_id of root node
  p_hash_dtls_tbl          IN  OUT NOCOPY  int_array_tbl_type_idx_vc2,    -- hash array config_item_id <=> txn line id --  Bug 6892148;
  p_passed_targets_rev_tbl IN  int_array_tbl_type_idx_vc2,    -- hash array of connectors for which targets are in the same CIO list --  Bug 6892148;
  p_rltns_tbl              IN  OUT NOCOPY txn_ii_rltns_tbl, -- array of relationships
  p_enddated_rltns_tbl     IN  OUT NOCOPY txn_ii_rltns_tbl, -- array of enddated connect_to relationships
  p_txn_type_id            IN  NUMBER,
  p_item_status            IN  VARCHAR2,
  x_run_id                 OUT NOCOPY NUMBER
  )   IS


      TYPE txn_line_tbl IS TABLE OF txn_line_rec
      INDEX BY BINARY_INTEGER;

      t_txn_line_tbl           txn_line_tbl;
      v_txn_line               txn_line_rec;

      t_txn_line_dtls_tbl      txn_line_detail_tbl;
      t_txn_party_tbl          txn_party_detail_tbl ;
      t_txn_pty_acct_tbl       txn_pty_acct_detail_tbl;
      t_txn_org_assgn_tbl      txn_org_assgn_tbl;
      t_txn_eav_tbl            txn_ext_attrib_vals_tbl;

      t_txn_systems_tbl        txn_systems_tbl;
      t_txn_ii_rltns_tbl       txn_ii_rltns_tbl;

      ts_txn_ii_rltns_tbl       txn_ii_rltns_tbl;

      t_txn_ext_attrib_vals_tbl txn_ext_attrib_vals_tbl;

      tv_txn_line_dtls_tbl      txn_line_detail_tbl;
      tv_txn_party_tbl          txn_party_detail_tbl ;
      tv_txn_pty_acct_tbl       txn_pty_acct_detail_tbl;
      tv_txn_org_assgn_tbl      txn_org_assgn_tbl;
      tv_txn_eav_tbl            txn_ext_attrib_vals_tbl;
      tv_txn_systems_tbl        txn_systems_tbl;
      tv_txn_ii_rltns_tbl       txn_ii_rltns_tbl;
      tv_txn_ext_attrib_vals_tbl txn_ext_attrib_vals_tbl;

      v_return_status           VARCHAR2(255) := fnd_api.g_ret_sts_success;
      v_msg_data                VARCHAR2(2000);
      v_msg_count               NUMBER;
      t_component_instance_type_tbl char_array_tbl_type;
      t_config_hdr_tbl          int_array_tbl_type;
      t_config_item_tbl         int_array_tbl_type;
      t_parent_config_item_tbl  int_array_tbl_type;
      t_config_rev_nbr_tbl      int_array_tbl_type;
      t_instance_hdr_tbl        int_array_tbl_type;
      t_instance_rev_nbr_tbl    int_array_tbl_type;
      t_instance_item_tbl       int_array_tbl_type;
      t_target_hdr_tbl          int_array_tbl_type;
      t_target_rev_nbr_tbl      int_array_tbl_type;
      t_target_item_tbl         int_array_tbl_type;
      t_location_tbl            int_array_tbl_type;
      t_inventory_item_tbl      int_array_tbl_type;
      t_organization_tbl        int_array_tbl_type;
      t_quantity_tbl            int_array_tbl_type; --  sselahi: changed from char_array_tbl_type;
      t_hash_dtls_tbl           int_array_tbl_type_idx_vc2; --  Bug 6892148;
      t_attribute_level_tbl     char_array_tbl_type;
      t_attribute_group_tbl     char_array_tbl_type;
      t_attribute_name_tbl      char_array_tbl_type;
      t_attribute_value_tbl     char_array_tbl_type;
      t_location_type_code_tbl  char_array_tbl_type;
      t_ib_trackable_tbl        char_array_tbl_type;
      t_ext_activated_flag_tbl  char_array_tbl_type;
      t_config_delta_tbl        char_array_tbl_type;
      t_is_item_changed_tbl     char_array_tbl_type;
      t_uom_code_tbl            char_array_tbl_type;
      t_name_tbl                char_array_tbl_type;
      t_discontinued_flag_tbl   char_array_tbl_type;
      t_del_sub_items_tbl       int_array_tbl_type;
      t_attrib_hash             int_array_tbl_type;
      t_cfg_hash                int_array_tbl_type;
      t_hash_changed_item_tbl   int_array_tbl_type_idx_vc2; --  Bug 6892148;
      t_hash_src_txn_flag_tbl   char_array_tbl_type_idx_vc2; -- kdande; 27-Nov-2008; Bug 7599508;
      t_tangible_item_flag_tbl  char_array_tbl_type;
      v_ib_trackable            CZ_CONFIG_ITEMS.ib_trackable%TYPE;

      v_relationship_type_code  VARCHAR2(255);
      v_txn_line_ind            NUMBER;
      v_txn_line_dtls_ind       NUMBER;
      v_rltns_tbl_ind           NUMBER;
      v_eav_ind                 NUMBER;
      v_parent_config_item_id   NUMBER;
      v_baseline_rev_nbr        NUMBER;
      v_root_id                 NUMBER;
      v_item_id                 NUMBER;
      v_attrib_ind              NUMBER;
      v_root_config_item_id     NUMBER;
      v_hash_changed_item_ind   NUMBER;
      v_instance_action_type    NUMBER;
      v_root_instance_hdr_id    NUMBER;
      v_root_instance_rev_nbr   NUMBER;
      v_target_hdr_id           NUMBER;
      v_target_rev_nbr          NUMBER;
      v_target_config_item_id   NUMBER;
      v_enddated_rltns_tbl_ind  NUMBER;
      v_baseline_txn_line_id    NUMBER;
      v_baseline_txn_rltn_id    NUMBER;

  BEGIN
      ERROR_CODE:='0010';
      x_run_id:=0;

      --
      -- collect all items from subtree
      -- starting with p_config_item_id
      -- nontrackable items ( IB_TRACKABLE = '0' )
      -- also will be collected here
      --

      FOR i IN(SELECT DISTINCT config_hdr_id,config_rev_nbr FROM CZ_CONFIG_ITEMS_V
      WHERE instance_hdr_id=p_config_hdr_id   AND
            instance_rev_nbr=p_config_rev_nbr)
      LOOP
          LOG_REPORT(m_RUN_ID,'config_hdr_id='||TO_CHAR(i.config_hdr_id)||' config_rev_nbr='||TO_CHAR(i.config_rev_nbr));
      END LOOP;

      LOG_REPORT(m_RUN_ID,'instance_hdr_id='||TO_CHAR(p_config_hdr_id)||' instance_rev_nbr='||TO_CHAR(p_config_rev_nbr)||
      ' config_item_id='||TO_CHAR(p_config_item_id)||' RUN_ID='||TO_CHAR(m_RUN_ID));

      SELECT config_hdr_id,
             config_rev_nbr,
             config_item_id,
             parent_config_item_id,
             instance_hdr_id,
             instance_rev_nbr,
             target_hdr_id,
             target_rev_nbr,
             target_config_item_id,
             NVL(ib_trackable, NO_FLAG),
             location_id,
             location_type_code,
             inventory_item_id,
             organization_id,
             item_num_val, -- sselahi: changed from item_val
             uom_code,
             ext_activated_flag,
             config_delta,
             discontinued_flag,
             component_instance_type,
             NVL(tangible_item_flag,NO_FLAG),
             NAME
      BULK COLLECT INTO
             t_config_hdr_tbl,
             t_config_rev_nbr_tbl,
             t_config_item_tbl,
             t_parent_config_item_tbl,
             t_instance_hdr_tbl,
             t_instance_rev_nbr_tbl,
             t_target_hdr_tbl,
             t_target_rev_nbr_tbl,
             t_target_item_tbl,
             t_ib_trackable_tbl,
             t_location_tbl,
             t_location_type_code_tbl,
             t_inventory_item_tbl,
             t_organization_tbl,
             t_quantity_tbl,
             t_uom_code_tbl,
             t_ext_activated_flag_tbl,
             t_config_delta_tbl,
             t_discontinued_flag_tbl,
             t_component_instance_type_tbl,
             t_tangible_item_flag_tbl,
             t_name_tbl
      FROM
     (SELECT * FROM CZ_CONFIG_ITEMS ci
       START WITH ci.instance_hdr_id=p_config_hdr_id AND
                  ci.instance_rev_nbr=p_config_rev_nbr AND component_instance_type='I' AND deleted_flag='0'
     CONNECT BY PRIOR ci.config_item_id=ci.parent_config_item_id AND
                  ci.instance_hdr_id=p_config_hdr_id AND
                  ci.instance_rev_nbr=p_config_rev_nbr  AND
                  PRIOR ci.instance_hdr_id=p_config_hdr_id AND
                  PRIOR ci.instance_rev_nbr=p_config_rev_nbr AND
                  deleted_flag='0' AND PRIOR deleted_flag='0' AND
                  (
                    (ci.ext_activated_flag='1' OR ci.config_delta <> 0) OR
                    (PRIOR ci.ext_activated_flag='1' OR PRIOR ci.config_delta <> 0)
                  )
      ) vi
      WHERE vi.instance_hdr_id=p_config_hdr_id AND
            vi.instance_rev_nbr=p_config_rev_nbr AND
           ((vi.item_num_val IS NOT NULL AND vi.item_num_val<>0)OR vi.target_config_item_id IS NOT NULL);    --Bug6655994 Added a new condition
	   --to avoid picking the option class with zero quantity.

      ERROR_CODE:='0011';

      IF t_config_item_tbl.COUNT=0 THEN
         RETURN;
      END IF;

      FOR i IN t_config_item_tbl.FIRST..t_config_item_tbl.LAST
      LOOP
         IF t_target_item_tbl(i) IS NOT NULL THEN
            v_ib_trackable:=NO_FLAG;
            BEGIN
                SELECT NVL(ib_trackable,NO_FLAG) INTO v_ib_trackable FROM CZ_CONFIG_ITEMS_V
                WHERE  instance_hdr_id  = t_target_hdr_tbl(i) AND
                       instance_rev_nbr = t_target_rev_nbr_tbl(i) AND
                       config_item_id = t_target_item_tbl(i);
            EXCEPTION
                WHEN OTHERS THEN
                     NULL;
            END;
            t_ib_trackable_tbl(i):=v_ib_trackable;
         END IF;
      END LOOP;

      ERROR_CODE:='00111';

      --
      -- exit when subtree is empty
      --
      IF t_config_item_tbl.COUNT = 0 THEN
         RETURN;
      END IF;

      BEGIN
          v_baseline_rev_nbr:=NULL;
          SELECT baseline_rev_nbr INTO v_baseline_rev_nbr
          FROM cz_config_hdrs
          WHERE config_hdr_id=p_config_hdr_id AND
                config_rev_nbr=p_config_rev_nbr AND
                deleted_flag=NO_FLAG;
      EXCEPTION
          WHEN OTHERS THEN
               ERROR_CODE:='00112';
      END;

      BEGIN
          v_root_config_item_id:=NULL;
          SELECT instance_hdr_id,instance_rev_nbr,parent_config_item_id
          INTO v_root_instance_hdr_id,v_root_instance_rev_nbr,v_root_config_item_id
          FROM CZ_CONFIG_ITEMS_V
          WHERE instance_hdr_id=p_config_hdr_id AND
                instance_rev_nbr=p_config_rev_nbr AND
                config_item_id=p_config_item_id;
      EXCEPTION
          WHEN OTHERS THEN
               ERROR_CODE:='00113';
      END;

      --
      -- set parent_config_item_id to nearest trackable parent's config_item_id
      --
      FOR i IN t_config_item_tbl.FIRST..t_config_item_tbl.LAST
      LOOP
         --
         -- check : is the current item changed or not
         -- and populate an array with these flags
         --
         IF (t_ext_activated_flag_tbl(i)='1' OR t_config_delta_tbl(i) NOT IN('0','00','000')) THEN
            t_is_item_changed_tbl(i):='1';
         ELSE
            t_is_item_changed_tbl(i):='0';
         END IF;

--         IF t_ib_trackable_tbl(i)=NO_FLAG OR NOT(CZ_UTILS.conv_num(t_quantity_tbl(i)) > 0) THEN
         IF t_ib_trackable_tbl(i)=NO_FLAG OR NOT(t_quantity_tbl(i) > 0) THEN -- sselahi: removed conv_num function
            FOR k IN t_config_item_tbl.FIRST..t_config_item_tbl.LAST
            LOOP
               IF t_parent_config_item_tbl(k) = t_config_item_tbl(i) THEN
                  t_parent_config_item_tbl(k):=t_parent_config_item_tbl(i);
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      t_hash_changed_item_tbl.DELETE;
      t_hash_src_txn_flag_tbl.DELETE;
      t_hash_changed_item_tbl(p_config_item_id):=p_config_item_id;

      propogate_Changed_Property
      (
       p_config_item_id         => p_config_item_id,
       p_is_item_changed        => '1',
       p_config_item_tbl        => t_config_item_tbl,
       p_parent_config_item_tbl => t_parent_config_item_tbl,
       p_is_item_changed_tbl    => t_is_item_changed_tbl,
       p_ib_trackable_tbl       => t_ib_trackable_tbl,
       px_hash_changed_item_tbl => t_hash_changed_item_tbl,
       px_hash_src_txn_flag_tbl => t_hash_src_txn_flag_tbl);

      FOR i IN t_config_item_tbl.FIRST..t_config_item_tbl.LAST
      LOOP

         --
         --  create tree from trackable nodes
         --
         IF t_ib_trackable_tbl(i)=YES_FLAG THEN
            v_item_id:=t_config_item_tbl(i);

            IF t_target_item_tbl(i) IS NOT NULL THEN
               v_relationship_type_code:=CONNECTED_TO_RELATIONSHIP;
            ELSE
               v_relationship_type_code:=COMPONENT_OF_RELATIONSHIP;
            END IF;


            IF v_relationship_type_code = COMPONENT_OF_RELATIONSHIP THEN

               --
               -- populate TXN Lines
               --

               IF t_is_item_changed_tbl(i) = '1' THEN

               v_txn_line_ind:=t_txn_line_tbl.COUNT+1;
               t_txn_line_tbl(v_txn_line_ind).source_transaction_type_id := p_txn_type_id;
               t_txn_line_tbl(v_txn_line_ind).source_transaction_table   := CZ_IB_TRANSACTION_TABLE;
               t_txn_line_tbl(v_txn_line_ind).source_transaction_status  := 'PROPOSED';
               t_txn_line_tbl(v_txn_line_ind).config_session_hdr_id      := t_config_hdr_tbl(i);
               t_txn_line_tbl(v_txn_line_ind).config_session_rev_num     := t_config_rev_nbr_tbl(i);
               t_txn_line_tbl(v_txn_line_ind).config_session_item_id     := t_config_item_tbl(i);
               t_txn_line_tbl(v_txn_line_ind).config_valid_status        := YES_FLAG;

               --
               -- IB API is called by CONFIGurator
               --
               t_txn_line_tbl(v_txn_line_ind).api_caller_identity        := 'CONFIG';
               t_txn_line_tbl(v_txn_line_ind).object_version_number      := 1;

               END IF;

               --
               -- populate TXN Line Details
               --
               v_txn_line_dtls_ind:=t_txn_line_dtls_tbl.COUNT+1;

               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).config_inst_hdr_id      := t_instance_hdr_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).config_inst_rev_num     := t_instance_rev_nbr_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).config_inst_item_id     := t_config_item_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).source_transaction_flag := 'Y';
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).instance_exists_flag    := 'N';
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).quantity                := t_quantity_tbl(i); -- sselahi: TBD
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).unit_of_measure         := t_uom_code_tbl(i);

               IF t_component_instance_type_tbl(i)='I' THEN
                 t_txn_line_dtls_tbl(v_txn_line_dtls_ind).location_id             := t_location_tbl(i);
                 t_txn_line_dtls_tbl(v_txn_line_dtls_ind).location_type_code      := t_location_type_code_tbl(i);
               ELSE
                 t_txn_line_dtls_tbl(v_txn_line_dtls_ind).location_id             := FND_API.G_MISS_NUM;
                 t_txn_line_dtls_tbl(v_txn_line_dtls_ind).location_type_code      := FND_API.G_MISS_CHAR;
               END IF;

               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).inventory_item_id       := t_inventory_item_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).inv_organization_id     := t_organization_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).mfg_serial_number_flag  := 'N';
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).sub_type_id             := 101;
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).instance_description    := t_name_tbl(i);
               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).config_inst_baseline_rev_num := v_baseline_rev_nbr;

               IF ( (t_discontinued_flag_tbl(i)=YES_FLAG AND m_CZ_IB_AUTO_EXPIRATION='Y') AND
                     t_tangible_item_flag_tbl(i)<>YES_FLAG )   THEN
                  t_txn_line_dtls_tbl(v_txn_line_dtls_ind).active_end_date := m_EFFECTIVE_DATE;
               END IF;

               t_txn_line_dtls_tbl(v_txn_line_dtls_ind).object_version_number   := 1;

               t_hash_dtls_tbl(t_config_item_tbl(i))    := v_txn_line_dtls_ind;

            END IF; -- end of v_relationship_type_code = COMPONENT_OF_RELATIONSHIP --

            IF v_relationship_type_code = CONNECTED_TO_RELATIONSHIP THEN

               v_target_hdr_id:=NULL;
               v_target_rev_nbr:=NULL;
               v_target_config_item_id:=NULL;

               BEGIN
                   SELECT target_hdr_id,target_rev_nbr,target_config_item_id
                   INTO v_target_hdr_id,v_target_rev_nbr,v_target_config_item_id
                   FROM CZ_CONFIG_ITEMS_V
                   WHERE instance_hdr_id=t_instance_hdr_tbl(i) AND instance_rev_nbr=v_baseline_rev_nbr AND
                         config_item_id=t_config_item_tbl(i);

                   IF NOT(v_target_hdr_id=t_target_hdr_tbl(i) AND v_target_config_item_id=t_target_item_tbl(i)) THEN

                      v_enddated_rltns_tbl_ind:=p_enddated_rltns_tbl.COUNT+1;

                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).sub_config_inst_item_id  := t_parent_config_item_tbl(i);
                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).sub_config_inst_hdr_id   := t_instance_hdr_tbl(i);

                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).sub_config_inst_rev_num  := t_instance_rev_nbr_tbl(i);

                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).relationship_type_code   := CONNECTED_TO_RELATIONSHIP;

                      IF p_passed_targets_rev_tbl.EXISTS(v_target_config_item_id) THEN

                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_item_id  := v_target_config_item_id;
                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_hdr_id   := v_target_hdr_id;
                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_rev_num  := p_passed_targets_rev_tbl(v_target_config_item_id);

                      ELSE -- use data from baseline

                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_item_id  := v_target_config_item_id;
                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_hdr_id   := v_target_hdr_id;
                         p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).obj_config_inst_rev_num  := v_target_rev_nbr;

                      END IF;

                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).api_caller_identity      := 'CONFIG';
                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).object_version_number    := 1;

                      p_enddated_rltns_tbl(v_enddated_rltns_tbl_ind).active_end_date          := m_EFFECTIVE_DATE;

                   END IF;
              EXCEPTION
                   WHEN OTHERS THEN
                        NULL;
              END;

               IF t_target_hdr_tbl(i) <> t_instance_hdr_tbl(i)
                   AND NOT(t_discontinued_flag_tbl(i)=YES_FLAG AND NOT(v_target_hdr_id=t_target_hdr_tbl(i) AND v_target_config_item_id=t_target_item_tbl(i)) ) THEN

                  --
                  -- CONNECTED-TO relationship
                  --

                  v_rltns_tbl_ind:=t_txn_ii_rltns_tbl.COUNT+1;
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_item_id  := t_parent_config_item_tbl(i);
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_hdr_id   := t_instance_hdr_tbl(i);
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_rev_num  := t_instance_rev_nbr_tbl(i);

                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).relationship_type_code   := CONNECTED_TO_RELATIONSHIP;
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_item_id  := t_target_item_tbl(i);
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_hdr_id   := t_target_hdr_tbl(i);
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_rev_num  := t_target_rev_nbr_tbl(i);

                  IF (t_discontinued_flag_tbl(i)=YES_FLAG AND m_CZ_IB_AUTO_EXPIRATION='Y') THEN
                     t_txn_ii_rltns_tbl(v_rltns_tbl_ind).active_end_date := m_EFFECTIVE_DATE;
                  END IF;

                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).api_caller_identity         := 'CONFIG';
                  t_txn_ii_rltns_tbl(v_rltns_tbl_ind).object_version_number       := 1;

               END IF;



            ELSIF v_relationship_type_code = COMPONENT_OF_RELATIONSHIP THEN
               --
               -- COMPONENT-OF relationship
               --
               v_rltns_tbl_ind:=t_txn_ii_rltns_tbl.COUNT+1;

               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_item_id  := t_config_item_tbl(i);
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_hdr_id   := t_instance_hdr_tbl(i);
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).sub_config_inst_rev_num  := t_instance_rev_nbr_tbl(i);

               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).relationship_type_code   := COMPONENT_OF_RELATIONSHIP;
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_item_id  := t_parent_config_item_tbl(i);
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_hdr_id   := t_instance_hdr_tbl(i);
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).obj_config_inst_rev_num  := t_instance_rev_nbr_tbl(i);


               IF (t_discontinued_flag_tbl(i)=YES_FLAG AND m_CZ_IB_AUTO_EXPIRATION='Y') THEN
                   t_txn_ii_rltns_tbl(v_rltns_tbl_ind).active_end_date := m_EFFECTIVE_DATE;
               END IF;

               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).api_caller_identity         := 'CONFIG';
               t_txn_ii_rltns_tbl(v_rltns_tbl_ind).object_version_number       := 1;

            ELSE
               --
               -- there are no other relationship types yet
               --
               NULL;
            END IF;

          END IF;
       END LOOP;

       --
       -- reinitialize array to store config items
       --
       t_config_item_tbl.DELETE;
       --
       -- retreive Extended Attributes
       --
       SELECT
            config_item_id,attribute_group,attribute_name,attribute_value
       BULK COLLECT INTO
            t_config_item_tbl,t_attribute_group_tbl,t_attribute_name_tbl,t_attribute_value_tbl
       FROM CZ_CONFIG_EXT_ATTRIBUTES
       WHERE config_hdr_id  = p_config_hdr_id  AND
             config_rev_nbr = p_config_rev_nbr AND deleted_flag=NO_FLAG;

       ERROR_CODE:='0031';

       IF t_attribute_name_tbl.COUNT > 0 THEN
          FOR i IN t_attribute_name_tbl.FIRST..t_attribute_name_tbl.LAST
          LOOP
              --
              -- bug #2692678 ( writting attributes for discontinued or unselected items )
              -- has been fixed in OracleInstalledBase class ( writeAttributes() method )
              -- this IF statement has been added for safety to avoid exception
              -- element does not exist if because of some possible problems/bugs
              -- we have a different items in Config Items collection and CZ_EXT_ATTRIBUTES table
              --
              IF t_hash_dtls_tbl.EXISTS(t_config_item_tbl(i)) THEN
                 v_eav_ind := t_txn_eav_tbl.COUNT+1;
                 v_txn_line_dtls_ind:=t_hash_dtls_tbl(t_config_item_tbl(i));
                 t_txn_eav_tbl(v_eav_ind).attrib_source_table   := 'CSI_I_EXTENDED_ATTRIBS';
                 t_txn_eav_tbl(v_eav_ind).attribute_code        := t_attribute_name_tbl(i);
                 t_txn_eav_tbl(v_eav_ind).attribute_value       := t_attribute_value_tbl(i);
                 t_txn_eav_tbl(v_eav_ind).active_start_date     := t_txn_line_dtls_tbl(v_txn_line_dtls_ind).active_start_date;
                 t_txn_eav_tbl(v_eav_ind).active_end_date       := t_txn_line_dtls_tbl(v_txn_line_dtls_ind).active_end_date;

                 --
                 -- txn_line_details_index points to the related  line detail record
                 --
                 t_txn_eav_tbl(v_eav_ind).txn_line_details_index:= v_txn_line_dtls_ind;
                 t_txn_eav_tbl(v_eav_ind).object_version_number := 1;
                 t_attrib_hash(v_eav_ind):=t_config_item_tbl(i);
              END IF;
         END LOOP;
       END IF;

       ERROR_CODE:='0032';

       tv_txn_line_dtls_tbl.DELETE;
       tv_txn_ii_rltns_tbl.DELETE;
       tv_txn_eav_tbl.DELETE;
       tv_txn_party_tbl.DELETE;

       FOR i IN t_txn_line_tbl.FIRST..t_txn_line_tbl.LAST
       LOOP
            v_txn_line:=t_txn_line_tbl(i);

            tv_txn_line_dtls_tbl.DELETE;
            tv_txn_ii_rltns_tbl.DELETE;

            IF t_txn_line_dtls_tbl.COUNT > 0 THEN

               FOR l IN  t_txn_line_dtls_tbl.FIRST..t_txn_line_dtls_tbl.LAST
               LOOP

               --
               -- populate txn details
               --

               --
               -- old code
               -- IF t_txn_line_dtls_tbl(l).config_inst_item_id=t_txn_line_tbl(i).config_session_item_id THEN
               --

               -- new code
               IF t_hash_changed_item_tbl(t_txn_line_dtls_tbl(l).config_inst_item_id)=t_txn_line_tbl(i).config_session_item_id THEN

                  IF t_hash_src_txn_flag_tbl.EXISTS(t_txn_line_dtls_tbl(l).config_inst_item_id) THEN
                     t_txn_line_dtls_tbl(l).source_transaction_flag:=t_hash_src_txn_flag_tbl(t_txn_line_dtls_tbl(l).config_inst_item_id);
                  END IF;
                  tv_txn_line_dtls_tbl(tv_txn_line_dtls_tbl.COUNT+1):=t_txn_line_dtls_tbl(l);


                  t_cfg_hash(t_txn_line_dtls_tbl(l).config_inst_item_id):=tv_txn_line_dtls_tbl.COUNT;

                     --
                     -- populate txn relations
                     --
                     IF t_txn_ii_rltns_tbl.COUNT > 0 THEN
                        FOR k IN t_txn_ii_rltns_tbl.FIRST..t_txn_ii_rltns_tbl.LAST
                        LOOP

                           IF t_txn_ii_rltns_tbl(k).sub_config_inst_hdr_id = t_txn_line_dtls_tbl(l).config_inst_hdr_id AND
                              t_txn_ii_rltns_tbl(k).sub_config_inst_rev_num = t_txn_line_dtls_tbl(l).config_inst_rev_num AND
                              t_txn_ii_rltns_tbl(k).sub_config_inst_item_id = t_txn_line_dtls_tbl(l).config_inst_item_id THEN

                              tv_txn_ii_rltns_tbl(tv_txn_ii_rltns_tbl.COUNT+1):=t_txn_ii_rltns_tbl(k);

                           END IF;
                        END LOOP;
                     END IF;

                     IF t_txn_eav_tbl.COUNT > 0 THEN
                        FOR k IN t_txn_eav_tbl.FIRST..t_txn_eav_tbl.LAST
                        LOOP
                           IF t_txn_eav_tbl(k).txn_line_details_index = l AND
                              t_attrib_hash(k) = t_txn_line_dtls_tbl(l).config_inst_item_id THEN
                              tv_txn_eav_tbl(tv_txn_eav_tbl.COUNT+1) := t_txn_eav_tbl(k);
                              tv_txn_eav_tbl(tv_txn_eav_tbl.COUNT).txn_line_details_index :=t_cfg_hash(t_txn_line_dtls_tbl(l).config_inst_item_id);
                              tv_txn_eav_tbl(tv_txn_eav_tbl.COUNT).api_caller_identity :='CONFIG';
                           END IF;
                        END LOOP;
                      END IF;

                  END IF;

               END LOOP; -- end of loop through all txn line details
            END IF;


            ERROR_CODE:='00334';

            -- csi_t_txn_details_grp.create_transaction_dtls --
            create_transaction_dtls
              (p_api_version              => 1.0,
               p_commit                   => fnd_api.g_false,
               p_init_msg_list            => fnd_api.g_true,
               p_validation_level         => fnd_api.g_valid_level_full,
               px_txn_line_rec            => v_txn_line,
               px_txn_line_detail_tbl     => tv_txn_line_dtls_tbl,
               px_txn_party_detail_tbl    => tv_txn_party_tbl,
               px_txn_pty_acct_detail_tbl => t_txn_pty_acct_tbl,
               px_txn_ii_rltns_tbl        => ts_txn_ii_rltns_tbl,
               px_txn_org_assgn_tbl       => t_txn_org_assgn_tbl,
               px_txn_ext_attrib_vals_tbl => tv_txn_eav_tbl,
               px_txn_systems_tbl         => t_txn_systems_tbl,
               x_return_status            => v_return_status,
               x_msg_count                => v_msg_count,
               x_msg_data                 => v_msg_data);

               -- bug #3646589
               tv_txn_eav_tbl.DELETE;

               IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
                  x_run_id:=m_RUN_ID;
                  LOG_REPORT(x_run_id,v_msg_data,v_msg_count);
               END IF;

               --
               -- populate hash array config_item_id <=> txn line id
               --
               IF tv_txn_line_dtls_tbl.COUNT > 0 THEN
                  FOR h IN tv_txn_line_dtls_tbl.FIRST..tv_txn_line_dtls_tbl.LAST
                  LOOP
                     p_hash_dtls_tbl(tv_txn_line_dtls_tbl(h).config_inst_item_id) := v_txn_line.transaction_line_id;
                  END LOOP;
               END IF;

               IF tv_txn_ii_rltns_tbl.COUNT > 0 THEN
                  FOR h IN tv_txn_ii_rltns_tbl.FIRST..tv_txn_ii_rltns_tbl.LAST
                  LOOP
                     IF tv_txn_ii_rltns_tbl(h).obj_config_inst_item_id<>v_root_config_item_id THEN
                        tv_txn_ii_rltns_tbl(h).transaction_line_id := v_txn_line.transaction_line_id;
                        p_rltns_tbl(p_rltns_tbl.COUNT+1):=tv_txn_ii_rltns_tbl(h);
                     END IF;

                  END LOOP;
               END IF;

       END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
           x_run_id:=m_RUN_ID;
           DEBUG('ERROR_CODE='||ERROR_CODE||' '||SQLERRM);
           LOG_REPORT(x_run_id,v_msg_data);
  END populate_IB_Txn;


  FUNCTION get_Instance_Status
  (
  p_instance_hdr_id  IN NUMBER,
  p_instance_rev_nbr IN NUMBER
  ) RETURN VARCHAR2 IS
      v_status  VARCHAR2(255):='';
  BEGIN
      SELECT ext_activated_flag||config_delta
      INTO v_status
      FROM CZ_CONFIG_ITEMS
      WHERE instance_hdr_id  = p_instance_hdr_id AND
            instance_rev_nbr = p_instance_rev_nbr AND
            component_instance_type='I' AND
            deleted_flag='0';
       LOG_REPORT(m_RUN_ID,'p_instance_hdr_id='||TO_CHAR(p_instance_hdr_id)||' changed_status='||v_status);
      RETURN v_status;
  EXCEPTION
      WHEN OTHERS THEN
           RETURN '';
  END get_Instance_Status;

/**
  * INSERT/UPDATE CZ data IN IB Transactions SCHEMA
  */

PROCEDURE Update_Instances
(
p_config_instance_tbl    IN   SYSTEM.cz_config_instance_tbl_type,
p_effective_date         IN   DATE,
p_txn_type_id            IN   NUMBER,
x_run_id                 OUT NOCOPY  NUMBER
) IS
    t_rltns_tbl           txn_ii_rltns_tbl;
    t_enddated_rltns_tbl  txn_ii_rltns_tbl;
    v_return_status       VARCHAR2(255) := fnd_api.g_ret_sts_success;
    v_transaction_line_id NUMBER;
    v_msg_data            VARCHAR2(2000);
    v_msg_count           NUMBER;
    v_run_id              NUMBER;
    v_txn_type_id         NUMBER:=CZ_TRANSACTION_TYPE_ID;
    v_baseline_rev_nbr    NUMBER;
    v_target_hdr_id       NUMBER;
    v_target_rev_nbr      NUMBER;
    v_target_config_item_id NUMBER;
    v_txn_exp_line_id     NUMBER;
    v_cfg_item_id         NUMBER;
    v_ind                 NUMBER;
    v_target_item_flag    VARCHAR2(255);
    v_status              VARCHAR2(255);

    t_config_item_tbl         int_array_tbl_type;
    t_cfg_item_hash_tbl1      int_array_tbl_type_idx_vc2; --  Bug 6892148;
    t_cfg_item_hash_tbl2      int_array_tbl_type_idx_vc2; --  Bug 6892148;
    t_passed_targets_rev_tbl  int_array_tbl_type_idx_vc2; --  Bug 6892148;
    t_hash_expired_roots      int_array_tbl_type;
    t_hash_expired_revs       int_array_tbl_type;
    t_hash_expired_hdrs       int_array_tbl_type;
    t_hash_dtls_tbl           int_array_tbl_type_idx_vc2;--  Bug 6892148;
    t_expired_rltns_tbl       txn_ii_rltns_tbl;
    t_notexpired_rltns_tbl    txn_ii_rltns_tbl;

BEGIN
    x_run_id:=0;
    Initialize(p_effective_date);

    IF p_config_instance_tbl.COUNT = 0 THEN
       RETURN;
    END IF;

    IF (p_txn_type_id IS NULL OR p_txn_type_id=-1) THEN
       v_txn_type_id := CZ_TRANSACTION_TYPE_ID;
    END IF;

    FOR i IN p_config_instance_tbl.FIRST..p_config_instance_tbl.LAST
    LOOP
       t_config_item_tbl.DELETE;

       v_status:=get_Instance_Status(p_config_instance_tbl(i).config_hdr_id,
                                     p_config_instance_tbl(i).new_config_rev_nbr);

       --
       -- '00' means bitmap mask EXT_ACTIVATED||CONFIG_DELTA
       --
       IF v_status NOT IN ('00','000','0000')THEN

          SELECT config_item_id
          BULK COLLECT INTO t_config_item_tbl
          FROM  CZ_CONFIG_ITEMS_V
          WHERE instance_hdr_id=p_config_instance_tbl(i).config_hdr_id AND
                instance_rev_nbr=p_config_instance_tbl(i).new_config_rev_nbr AND
                ib_trackable='1';

          IF t_config_item_tbl.COUNT > 0 THEN
             FOR k IN t_config_item_tbl.FIRST..t_config_item_tbl.LAST
             LOOP
                --
                -- populate hash arrays
                --
                t_cfg_item_hash_tbl1(t_config_item_tbl(k)):=p_config_instance_tbl(i).config_hdr_id;
                t_cfg_item_hash_tbl2(t_config_item_tbl(k)):=p_config_instance_tbl(i).new_config_rev_nbr;
             END LOOP;
          END IF;

       END IF;
    END LOOP;

    FOR i IN p_config_instance_tbl.FIRST..p_config_instance_tbl.LAST
    LOOP

       SELECT baseline_rev_nbr INTO v_baseline_rev_nbr
       FROM CZ_CONFIG_HDRS
       WHERE config_hdr_id=p_config_instance_tbl(i).config_hdr_id AND
             config_rev_nbr=p_config_instance_tbl(i).new_config_rev_nbr AND deleted_flag=NO_FLAG;

       --
       -- collect all Connectors that we are passing
       --
       FOR k IN (SELECT  target_hdr_id,target_rev_nbr,target_config_item_id,config_item_id
                 FROM CZ_CONFIG_ITEMS_V
                 WHERE instance_hdr_id=p_config_instance_tbl(i).config_hdr_id AND
                       instance_rev_nbr=p_config_instance_tbl(i).new_config_rev_nbr AND
                       target_config_item_id IS NOT NULL)
       LOOP
          BEGIN
          IF v_baseline_rev_nbr IS NOT NULL THEN
             SELECT target_hdr_id,target_rev_nbr,target_config_item_id
             INTO v_target_hdr_id,v_target_rev_nbr,v_target_config_item_id
             FROM CZ_CONFIG_ITEMS_V
             WHERE instance_hdr_id=p_config_instance_tbl(i).config_hdr_id AND
                   instance_rev_nbr=v_baseline_rev_nbr AND config_item_id=k.config_item_id;


             IF t_cfg_item_hash_tbl1.EXISTS(v_target_config_item_id) THEN


                   t_passed_targets_rev_tbl(v_target_config_item_id) := t_cfg_item_hash_tbl2(v_target_config_item_id);


             END IF;

          END IF;

          EXCEPTION
             WHEN OTHERS THEN
                  NULL;
          END;
       END LOOP;

    END LOOP;

    FOR i IN p_config_instance_tbl.FIRST..p_config_instance_tbl.LAST
    LOOP
       v_status:=get_Instance_Status(p_config_instance_tbl(i).config_hdr_id,
                                     p_config_instance_tbl(i).new_config_rev_nbr);

       --
       -- '00' means bitmap mask EXT_ACTIVATED||CONFIG_DELTA
       --
       IF v_status NOT IN ('00','000','0000')THEN
          IF  p_config_instance_tbl(i).old_config_rev_nbr = p_config_instance_tbl(i).new_config_rev_nbr THEN
              remove_IB_Config
              (p_session_config_hdr_id  => NULL,
               p_session_config_rev_nbr => NULL,
               p_instance_hdr_id        => p_config_instance_tbl(i).config_hdr_id,
               p_instance_rev_nbr       => p_config_instance_tbl(i).old_config_rev_nbr,
               p_instance_item_id       => p_config_instance_tbl(i).config_item_id,
               x_run_id                 => x_run_id);
          END IF;
          populate_IB_Txn(p_config_hdr_id          => p_config_instance_tbl(i).config_hdr_id,
                          p_config_rev_nbr         => p_config_instance_tbl(i).new_config_rev_nbr,
                          p_config_item_id         => p_config_instance_tbl(i).config_item_id,
                          p_hash_dtls_tbl          => t_hash_dtls_tbl,
                          p_passed_targets_rev_tbl => t_passed_targets_rev_tbl,
                          p_rltns_tbl              => t_rltns_tbl,
                          p_enddated_rltns_tbl     => t_enddated_rltns_tbl,
                          p_txn_type_id            => v_txn_type_id,
                          p_item_status            => v_status,
                          x_run_id                => x_run_id);
       END IF;
    END LOOP;

    --
    -- create relatioships only when txn lines/details already created
    --
    IF t_rltns_tbl.COUNT>0 THEN
       FOR t IN  t_rltns_tbl.FIRST..t_rltns_tbl.LAST
       LOOP
          --
          -- check the target item
          --

          IF t_rltns_tbl(t).relationship_type_code = CONNECTED_TO_RELATIONSHIP AND
             get_Instance_Status(t_rltns_tbl(t).obj_config_inst_hdr_id,
                                 t_rltns_tbl(t).obj_config_inst_rev_num) IN ('00','000','0000') THEN

             v_baseline_rev_nbr:=t_rltns_tbl(t).obj_config_inst_rev_num;

             BEGIN
                 SELECT baseline_rev_nbr INTO v_baseline_rev_nbr FROM CZ_CONFIG_HDRS
                 WHERE config_hdr_id=t_rltns_tbl(t).obj_config_inst_hdr_id AND
                       config_rev_nbr=t_rltns_tbl(t).obj_config_inst_rev_num AND
                       deleted_flag=NO_FLAG;
                 LOG_REPORT(m_RUN_ID,'baseline_rev_nbr = '||TO_CHAR(v_baseline_rev_nbr)||
                   ' instance_hdr_id='||TO_CHAR(t_rltns_tbl(t).obj_config_inst_hdr_id)||' and instance_rev_nbr='||
                      TO_CHAR(t_rltns_tbl(t).obj_config_inst_rev_num));

             EXCEPTION
                 WHEN OTHERS THEN
                      LOG_REPORT(m_RUN_ID,'Error : there is no baseline revision for the instance with '||
                      'instance_hdr_id='||TO_CHAR(t_rltns_tbl(t).obj_config_inst_hdr_id)||' and instance_rev_nbr='||
                      TO_CHAR(t_rltns_tbl(t).obj_config_inst_rev_num));
                      x_run_id:=m_RUN_ID;
             END;

             IF v_baseline_rev_nbr IS NOT NULL THEN
                t_rltns_tbl(t).obj_config_inst_rev_num := v_baseline_rev_nbr;
             END IF;
          END IF;

       END LOOP;
    END IF;

    --
    -- create expired CONNECTED_TO relationships first
    --
    IF t_enddated_rltns_tbl.COUNT > 0 THEN

       FOR n IN t_rltns_tbl.FIRST..t_rltns_tbl.LAST
       LOOP
          FOR m IN t_enddated_rltns_tbl.FIRST..t_enddated_rltns_tbl.LAST
          LOOP
             IF t_enddated_rltns_tbl(m).relationship_type_code = CONNECTED_TO_RELATIONSHIP AND
                t_rltns_tbl(n).relationship_type_code = CONNECTED_TO_RELATIONSHIP THEN
                IF t_enddated_rltns_tbl(m).sub_config_inst_hdr_id  = t_rltns_tbl(n).sub_config_inst_hdr_id AND
                   t_enddated_rltns_tbl(m).sub_config_inst_rev_num = t_rltns_tbl(n).sub_config_inst_rev_num AND
                   t_enddated_rltns_tbl(m).sub_config_inst_item_id = t_rltns_tbl(n).sub_config_inst_item_id THEN

                   t_enddated_rltns_tbl(m).transaction_line_id := t_rltns_tbl(n).transaction_line_id;

                END IF;
             END IF;
          END LOOP;
       END LOOP;

       -- csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls --
       create_txn_ii_rltns_dtls
         (
          p_api_version              => 1.0,
          p_commit                   => fnd_api.g_false,
          p_init_msg_list            => fnd_api.g_true,
          p_validation_level         => fnd_api.g_valid_level_full,
          px_txn_ii_rltns_tbl        => t_enddated_rltns_tbl,
          x_return_status            => v_return_status,
          x_msg_count                => v_msg_count,
          x_msg_data                 => v_msg_data
         );

       IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
          x_run_id:=m_RUN_ID;
          LOG_REPORT(x_run_id,'DISCONTINUED CONNECTORS FAILED.');
          LOG_REPORT(x_run_id,v_msg_data,v_msg_count);
       END IF;
    END IF;

    --
    -- create other expired relationships
    --
    IF t_rltns_tbl.COUNT > 0 THEN

       --
       -- collect all expired COMPONENT-OF relationships
       -- into a separate array
       -- ( this is because of requirement from IB API  - call
       -- create_relationships API for expired relationships FIRST
       --
       FOR n IN t_rltns_tbl.FIRST..t_rltns_tbl.LAST
       LOOP
          IF NOT(t_rltns_tbl(n).active_end_date IS NULL OR
                 t_rltns_tbl(n).active_end_date=FND_API.G_MISS_DATE) THEN
             t_expired_rltns_tbl(t_expired_rltns_tbl.COUNT+1):=t_rltns_tbl(n);
          END IF;
       END LOOP;

       IF  t_expired_rltns_tbl.COUNT>0 THEN

           FOR nn IN t_expired_rltns_tbl.FIRST..t_expired_rltns_tbl.LAST
           LOOP
              BEGIN
                  v_txn_exp_line_id := NULL;

                  v_cfg_item_id := t_expired_rltns_tbl(nn).sub_config_inst_item_id;

                  -- find the nearest item which has a corresponding txn line
                  FOR t IN (SELECT config_item_id FROM cz_config_items
                             WHERE config_item_id<>v_cfg_item_id
                                   START WITH config_item_id=v_cfg_item_id AND
                                   instance_hdr_id=t_expired_rltns_tbl(nn).sub_config_inst_hdr_id AND
                                   instance_rev_nbr=t_expired_rltns_tbl(nn).sub_config_inst_rev_num
                           CONNECT BY PRIOR parent_config_item_id=config_item_id AND
                                   instance_hdr_id=t_expired_rltns_tbl(nn).sub_config_inst_hdr_id AND
                                   instance_rev_nbr=t_expired_rltns_tbl(nn).sub_config_inst_rev_num)
                  LOOP
                    IF t_hash_dtls_tbl.EXISTS(t.config_item_id) THEN
                      v_txn_exp_line_id := t_hash_dtls_tbl(t.config_item_id);
                      EXIT;
                    END IF;
                  END LOOP;

                  IF v_txn_exp_line_id IS NULL AND t_hash_dtls_tbl.EXISTS(v_cfg_item_id) THEN
                    v_txn_exp_line_id := t_hash_dtls_tbl(v_cfg_item_id);
                  END IF;

                  t_expired_rltns_tbl(nn).transaction_line_id := v_txn_exp_line_id;

LOG_REPORT(m_RUN_ID,'Relationship for instance_hdr_id/instance_rev_nbr/config_item_id='||to_char(t_expired_rltns_tbl(nn).sub_config_inst_hdr_id)||
'/'||to_char(t_expired_rltns_tbl(nn).sub_config_inst_rev_num)||'/'||to_char(v_cfg_item_id)||' has txn_line_id='||to_char(v_txn_exp_line_id));

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      NULL;
                 WHEN OTHERS THEN
                      LOG_REPORT(m_RUN_ID,'Internal Error : '||SQLERRM);
              END;
           END LOOP; -- end of nn loop --


          -- csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls --
          create_txn_ii_rltns_dtls
           (
            p_api_version              => 1.0,
            p_commit                   => fnd_api.g_false,
            p_init_msg_list            => fnd_api.g_true,
            p_validation_level         => fnd_api.g_valid_level_full,
            px_txn_ii_rltns_tbl        => t_expired_rltns_tbl,
            x_return_status            => v_return_status,
            x_msg_count                => v_msg_count,
            x_msg_data                 => v_msg_data
           );

          IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
             x_run_id:=m_RUN_ID;
             LOG_REPORT(x_run_id,'CREATING EXPIRED RELATIONSHIPS FAILED...');
             LOG_REPORT(x_run_id,v_msg_data,v_msg_count);
          ELSE
             LOG_REPORT(m_RUN_ID,'CREATING EXPIRED RELATIONSHIPS PASSED...');
          END IF;

       END IF; -- end of if t_expired_rltns_tbl.COUNT>0 statement --

    END IF;

    --
    -- create nonexpired relationships
    --

    IF t_rltns_tbl.COUNT > 0 THEN

       FOR n IN t_rltns_tbl.FIRST..t_rltns_tbl.LAST
       LOOP
          IF (t_rltns_tbl(n).active_end_date IS NULL OR
                 t_rltns_tbl(n).active_end_date=FND_API.G_MISS_DATE) THEN
             t_notexpired_rltns_tbl(t_notexpired_rltns_tbl.COUNT+1):=t_rltns_tbl(n);
          END IF;
       END LOOP;

       IF t_notexpired_rltns_tbl.COUNT > 0 THEN

         -- csi_t_txn_rltnshps_grp.create_txn_ii_rltns_dtls --
         create_txn_ii_rltns_dtls
         (
          p_api_version              => 1.0,
          p_commit                   => fnd_api.g_false,
          p_init_msg_list            => fnd_api.g_true,
          p_validation_level         => fnd_api.g_valid_level_full,
          px_txn_ii_rltns_tbl        => t_notexpired_rltns_tbl,
          x_return_status            => v_return_status,
          x_msg_count                => v_msg_count,
          x_msg_data                 => v_msg_data
         );

       IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
          x_run_id:=m_RUN_ID;
          LOG_REPORT(x_run_id,'CREATING NEW RELATIONSHIPS FAILED...');
          LOG_REPORT(x_run_id,v_msg_data,v_msg_count);
       ELSE
          LOG_REPORT(m_RUN_ID,'CREATING NEW RELATIONSHIPS PASSED...');
       END IF;

       END IF;

    END IF;

    LOG_REPORT(m_RUN_ID,'FINAL STATUS : RUN_ID='||TO_CHAR(x_run_id));

EXCEPTION
    WHEN OTHERS THEN
         DEBUG(SQLERRM);
         x_run_id:=m_RUN_ID;
         LOG_REPORT(x_run_id,'Internal Error (ERROR_CODE='||ERROR_CODE||') : '||SQLERRM);
END Update_Instances;

PROCEDURE update_CSI_Item_Inst_Status
(p_config_hdr_id  IN NUMBER,
 p_config_rev_nbr IN NUMBER,
 p_config_status  IN VARCHAR2,
 x_run_id         OUT NOCOPY NUMBER) IS

BEGIN

EXECUTE IMMEDIATE
'DECLARE ' ||
'  v_instance_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_REC; ' ||
'  v_ext_attrib_values_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL; ' ||
'  v_party_tbl             CSI_DATASTRUCTURES_PUB.PARTY_TBL; ' ||
'  v_party_account_tbl     CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL; ' ||
'  v_pricing_attrib_tbl    CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL; ' ||
'  v_org_assignments_tbl   CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL; ' ||
'  v_asset_assignment_tbl  CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL; ' ||
'  v_txn_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_REC; ' ||
'  x_instance_id_lst       CSI_DATASTRUCTURES_PUB.ID_TBL; ' ||
'  v_instance_query_rec    CSI_DATASTRUCTURES_PUB.instance_query_rec; ' ||
'  v_party_query_rec       CSI_DATASTRUCTURES_PUB.party_query_rec; ' ||
'  v_account_query_rec     CSI_DATASTRUCTURES_PUB.party_account_query_rec; ' ||
'  x_instance_header_tbl   CSI_DATASTRUCTURES_PUB.instance_header_tbl; ' ||
'  x_return_status         VARCHAR2(2000); ' ||
'  x_msg_count             NUMBER; ' ||
'  x_msg_data              VARCHAR2(2000); ' ||
'BEGIN ' ||
'  v_instance_query_rec.config_inst_hdr_id  := :1; ' ||
'  v_instance_query_rec.config_inst_rev_num := :2; ' ||
'  csi_item_instance_pub.get_item_instances ' ||
'      ( ' ||
'      p_api_version          => 1.0, ' ||
'      p_commit               => ''F'', ' ||
'      p_init_msg_list        => ''F'', ' ||
'      p_validation_level     => 100, ' ||
'      p_instance_query_rec   => v_instance_query_rec, ' ||
'      p_party_query_rec      => v_party_query_rec, ' ||
'      p_account_query_rec    => v_account_query_rec, ' ||
'      p_transaction_id       => NULL, ' ||
'      p_resolve_id_columns   => ''F'', ' ||
'      p_active_instance_only => ''F'', ' ||
'      x_instance_header_tbl  => x_instance_header_tbl, ' ||
'      x_return_status        => x_return_status, ' ||
'      x_msg_count            => x_msg_count, ' ||
'      x_msg_data             => x_msg_data ' ||
'      ); ' ||
'  FOR i IN x_instance_header_tbl.First..x_instance_header_tbl.Last ' ||
'  LOOP ' ||
'    v_instance_rec.instance_id := x_instance_header_tbl(i).instance_id;  ' ||
'    v_instance_rec.object_version_number := x_instance_header_tbl(i).object_version_number; ' ||
'    v_instance_rec.CONFIG_VALID_STATUS := :3; ' ||
'    v_txn_rec.transaction_id := NULL; ' ||
'    v_txn_rec.transaction_date := sysdate;  ' ||
'    v_txn_rec.source_transaction_date := sysdate;  ' ||
'    v_txn_rec.transaction_type_id := 401;  ' ||
'    csi_item_instance_pub.update_item_instance( ' ||
'                          p_api_version           => 1.0, ' ||
'                          p_commit                => ''F'', ' ||
'                          p_init_msg_list         => ''F'', ' ||
'                          p_validation_level      => 100, ' ||
'                          p_instance_rec          => v_instance_rec, ' ||
'                          p_ext_attrib_values_tbl => v_ext_attrib_values_tbl, ' ||
'                          p_party_tbl             => v_party_tbl, ' ||
'                          p_account_tbl           => v_party_account_tbl, ' ||
'                          p_pricing_attrib_tbl    => v_pricing_attrib_tbl, ' ||
'                          p_org_assignments_tbl   => v_org_assignments_tbl, ' ||
'                          p_asset_assignment_tbl  => v_asset_assignment_tbl, ' ||
'                          p_txn_rec               => v_txn_rec, ' ||
'                          x_instance_id_lst       => x_instance_id_lst, ' ||
'                          x_return_status         => CZ_IB_TRANSACTIONS.m_return_status, ' ||
'                          x_msg_count             => CZ_IB_TRANSACTIONS.m_msg_count, ' ||
'                          x_msg_data              => CZ_IB_TRANSACTIONS.m_msg_data); ' ||
'  END LOOP; ' ||
'END;' USING p_config_hdr_id, p_config_rev_nbr, p_config_status;

  IF (CZ_IB_TRANSACTIONS.m_return_status <> fnd_api.g_ret_sts_success) THEN
    x_run_id:=m_RUN_ID;
    LOG_REPORT(m_RUN_ID,'csi_item_instance_pub.update_item_instance() failed : '||CZ_IB_TRANSACTIONS.m_msg_data,CZ_IB_TRANSACTIONS.m_msg_count);
  END IF;

END update_CSI_Item_Inst_Status;

/**
  * The method will UPDATE the status OF the IB instance
  * <=> CSI_T_TRANSACTION_LINES.CONFIG_VALID_STATUS / CSI_ITEM_INSTANCES.CONFIG_VALID_STATUS TO be INVALID
  * IF either the CZ_CONFIG_HDRS.config_status field IS SET TO INCOMPLETE OR
  * the CZ_CONFIG_HDRS.has_failures field IS SET TO TRUE, otherwise, it will be SET TO VALID
  */
PROCEDURE Update_Instances_Status
(
p_config_instance_tbl    IN   SYSTEM.cz_config_instance_tbl_type,
x_run_id                 OUT NOCOPY  NUMBER
) IS
    v_config_status  VARCHAR2(255);
    v_return_status  VARCHAR2(255);
    v_msg_count      NUMBER;
    v_msg_data       VARCHAR2(32000);

BEGIN
    x_run_id:=0;
    Initialize(SYSDATE);
    IF p_config_instance_tbl.COUNT = 0 THEN
       RETURN;
    END IF;

    FOR i IN p_config_instance_tbl.FIRST..p_config_instance_tbl.LAST
    LOOP
       FOR k IN (SELECT config_status,has_failures FROM cz_config_hdrs
                 WHERE config_hdr_id=p_config_instance_tbl(i).config_hdr_id AND
                       config_rev_nbr=p_config_instance_tbl(i).new_config_rev_nbr AND deleted_flag=NO_FLAG)
       LOOP
          IF (k.config_status=INCOMPLETE_CONFIG_STATUS OR k.has_failures=YES_FLAG) THEN
              v_config_status:=NO_FLAG;
          ELSE
              v_config_status:=YES_FLAG;
          END IF;

          EXECUTE IMMEDIATE
         'BEGIN ' ||
         ' UPDATE CSI_T_TRANSACTION_LINES  ' ||
         ' SET config_valid_status = '||v_config_status ||
         ' WHERE   (config_session_hdr_id,config_session_rev_num) IN ' ||
         '         (SELECT DISTINCT config_hdr_id,config_rev_nbr FROM CZ_CONFIG_ITEMS ' ||
         '             WHERE instance_hdr_id=:1 AND ' ||
         '                   instance_rev_nbr IN(:2,:3) AND deleted_flag=''0''); ' ||
         ' END;' USING p_config_instance_tbl(i).config_hdr_id,p_config_instance_tbl(i).old_config_rev_nbr,p_config_instance_tbl(i).new_config_rev_nbr;

          update_CSI_Item_Inst_Status(p_config_instance_tbl(i).config_hdr_id,
                                      p_config_instance_tbl(i).old_config_rev_nbr,
                                      v_config_status,
                                      x_run_id);
       END LOOP;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
         DEBUG(SQLERRM);
         x_run_id:=m_RUN_ID;
         LOG_REPORT(x_run_id, 'Internal Error (ERROR_CODE='||ERROR_CODE||') : '||SQLERRM);
END Update_Instances_Status;

PROCEDURE get_Last_CSI_Revisions
(p_config_inst_hdr_id IN NUMBER,
 x_csi_nbr_tbl        OUT NOCOPY int_array_tbl_type_idx_vc2) IS--  Bug 6892148;

BEGIN

  EXECUTE IMMEDIATE
  'BEGIN ' ||
  '  FOR i IN(SELECT config_inst_item_id,config_inst_rev_num FROM CSI_ITEM_INSTANCES ' ||
  '           WHERE config_inst_hdr_id=:1   ' ||
  '                 ORDER BY config_inst_item_id,config_inst_rev_num) ' ||
  '  LOOP ' ||
  '    CZ_IB_TRANSACTIONS.m_csi_rev_nbr_tbl(i.config_inst_item_id) := i.config_inst_rev_num;   ' ||
  '  END LOOP;                 ' ||
  ' END;'
  USING p_config_inst_hdr_id;

  x_csi_nbr_tbl := m_csi_rev_nbr_tbl;

  m_csi_rev_nbr_tbl.DELETE;

END get_Last_CSI_Revisions;

/**
  * return instance_description and location_id for a given item and revision
  */
PROCEDURE get_InstDesc_LocId
(
p_config_hdr_id        IN  NUMBER,
p_config_rev_nbr       IN  NUMBER,
p_config_item_id       IN  NUMBER,
x_instance_description OUT NOCOPY VARCHAR2,
x_location_id          OUT NOCOPY NUMBER,
x_location_type_code   OUT NOCOPY VARCHAR2
) IS
BEGIN

  EXECUTE IMMEDIATE
    'SELECT instance_description, location_id, location_type_code ' ||
    '     FROM CSI_ITEM_INSTANCES   ' ||
    '    WHERE config_inst_hdr_id = :1 AND ' ||
    '          config_inst_rev_num = :2 AND config_inst_item_id=:3'
  INTO x_instance_description, x_location_id, x_location_type_code
  USING p_config_hdr_id, p_config_rev_nbr, p_config_item_id;

END get_InstDesc_LocId;

/**
  * retreive attributes data for installed item
  */
PROCEDURE get_Installed_Attributes_Data
(
p_config_hdr_id          IN  NUMBER,
p_config_rev_nbr         IN  NUMBER,
p_config_item_id         IN  NUMBER,
x_attribute_category_tbl OUT NOCOPY long_char_array_tbl_type,
x_attribute_name_tbl     OUT NOCOPY long_char_array_tbl_type,
x_attribute_value_tbl    OUT NOCOPY long_char_array_tbl_type
) IS

BEGIN

  m_attribute_category_tbl.DELETE;
  m_attribute_name_tbl.DELETE;
  m_attribute_value_tbl.DELETE;

  EXECUTE IMMEDIATE
    'BEGIN ' ||
    '   SELECT  ' ||
    '     a.attribute_category,a.attribute_code,b.attribute_value ' ||
    '   BULK COLLECT INTO  ' ||
    '     CZ_IB_TRANSACTIONS.m_attribute_category_tbl,CZ_IB_TRANSACTIONS.m_attribute_name_tbl, ' ||
    '     CZ_IB_TRANSACTIONS.m_attribute_value_tbl  ' ||
    '   FROM  CSI_I_EXTENDED_ATTRIBS a, CSI_IEA_VALUES b, CSI_ITEM_INSTANCES c  ' ||
    '   WHERE a.attribute_id = b.attribute_id AND  ' ||
    '         b.instance_id = c.instance_id AND ' ||
    '         c.config_inst_hdr_id = :1 AND ' ||
    '         c.config_inst_rev_num = :2 AND  ' ||
    '         c.config_inst_item_id = :3; ' ||
    ' END;'
  USING p_config_hdr_id, p_config_rev_nbr, p_config_item_id;

  x_attribute_category_tbl := m_attribute_category_tbl;
  x_attribute_name_tbl     := m_attribute_name_tbl;
  x_attribute_value_tbl    := m_attribute_value_tbl;

  m_attribute_category_tbl.DELETE;
  m_attribute_name_tbl.DELETE;
  m_attribute_value_tbl.DELETE;

END get_Installed_Attributes_Data;

/**
  * retreive installed attribute value
  */
PROCEDURE get_Installed_Attribute_Value
(
p_config_hdr_id          IN  NUMBER,
p_config_rev_nbr         IN  NUMBER,
p_config_item_id         IN  NUMBER,
p_attribute_name         IN  VARCHAR2,
x_attribute_value        OUT NOCOPY VARCHAR2
) IS

BEGIN

  EXECUTE IMMEDIATE
    'SELECT  ' ||
    '   b.attribute_value ' ||
    ' FROM  CSI_I_EXTENDED_ATTRIBS a, CSI_IEA_VALUES b, CSI_ITEM_INSTANCES c  ' ||
    ' WHERE a.attribute_id = b.attribute_id AND  ' ||
    '       b.instance_id = c.instance_id AND ' ||
    '       c.config_inst_hdr_id = :1 AND ' ||
    '       c.config_inst_rev_num = :2 AND  ' ||
    '       c.config_inst_item_id = :3 AND  ' ||
    '       a.attribute_code = :4'
  INTO x_attribute_value
  USING p_config_hdr_id, p_config_rev_nbr, p_config_item_id, p_attribute_name;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END get_Installed_Attribute_Value;

/**
  * retreive attributes data for installed item
  */
PROCEDURE get_Txn_Attributes_Data
(
p_config_hdr_id          IN  NUMBER,
p_config_rev_nbr         IN  NUMBER,
p_config_item_id         IN  NUMBER,
x_attribute_category_tbl OUT NOCOPY long_char_array_tbl_type,
x_attribute_name_tbl     OUT NOCOPY long_char_array_tbl_type,
x_attribute_value_tbl    OUT NOCOPY long_char_array_tbl_type
) IS

BEGIN

  m_attribute_category_tbl.DELETE;
  m_attribute_name_tbl.DELETE;
  m_attribute_value_tbl.DELETE;

  EXECUTE IMMEDIATE
   'BEGIN ' ||
   '   SELECT  ' ||
   '     attribute_category, attribute_code, attribute_value ' ||
   '   BULK COLLECT INTO  ' ||
   '     CZ_IB_TRANSACTIONS.m_attribute_category_tbl,CZ_IB_TRANSACTIONS.m_attribute_name_tbl, ' ||
   '     CZ_IB_TRANSACTIONS.m_attribute_value_tbl  ' ||
   '   FROM CSI_T_EXTEND_ATTRIBS_V a ' ||
   '   WHERE txn_line_detail_id IN  ' ||
   '        (SELECT txn_line_detail_id ' ||
   '          FROM CSI_T_TXN_LINE_DETAILS  ' ||
   '          WHERE config_inst_hdr_id = :1 AND ' ||
   '                config_inst_rev_num=:2 AND config_inst_item_id=:3); ' ||
   ' END;'
  USING p_config_hdr_id, p_config_rev_nbr, p_config_item_id;

  x_attribute_category_tbl := m_attribute_category_tbl;
  x_attribute_name_tbl     := m_attribute_name_tbl;
  x_attribute_value_tbl    := m_attribute_value_tbl;

  m_attribute_category_tbl.DELETE;
  m_attribute_name_tbl.DELETE;
  m_attribute_value_tbl.DELETE;

END get_Txn_Attributes_Data;


/**
  * retreive attributes data from CZ ext attributes
  */
PROCEDURE get_CZ_Attributes_Data
(
p_config_hdr_id          IN  NUMBER,
p_config_rev_nbr         IN  NUMBER,
p_config_item_id         IN  NUMBER,
x_attribute_category_tbl OUT NOCOPY long_char_array_tbl_type,
x_attribute_name_tbl     OUT NOCOPY long_char_array_tbl_type,
x_attribute_value_tbl    OUT NOCOPY long_char_array_tbl_type
) IS

BEGIN

  SELECT
    attribute_group, attribute_name, attribute_value
  BULK COLLECT INTO
    x_attribute_category_tbl, x_attribute_name_tbl, x_attribute_value_tbl
  FROM CZ_CONFIG_EXT_ATTRIBUTES
  WHERE config_hdr_id  = p_config_hdr_id AND
        config_rev_nbr = p_config_rev_nbr AND
        config_item_id = p_config_item_id AND deleted_flag='0';

END get_CZ_Attributes_Data;

/**
  * Return array OF attributes OF config items FROM subtree that starts WITH
  * config item  (p_config_hdr_id,p_config_rev_nbr,p_config_item_id)
  */
PROCEDURE  Synchronize_Attributes
  (
  p_config_hdr_id            IN  NUMBER,
  p_config_rev_nbr           IN  NUMBER,
  p_install_rev_nbr          IN  NUMBER,
  p_config_item_id           IN  NUMBER,
  x_config_attribute_tbl     OUT NOCOPY SYSTEM.cz_config_attribute_tbl_type,
  x_txn_params_tbl           OUT NOCOPY SYSTEM.cz_txn_params_tbl_type,
  x_run_id   	           OUT NOCOPY INTEGER
  )  IS

      t_config_hdr_tbl           int_array_tbl_type;
      t_config_rev_nbr_tbl       int_array_tbl_type;
      t_config_item_tbl          int_array_tbl_type;
      t_location_id_tbl          int_array_tbl_type;
      t_attribute_category_tbl   long_char_array_tbl_type;
      t_attribute_name_tbl       long_char_array_tbl_type;
      t_attribute_value_tbl      long_char_array_tbl_type;
      t_instance_description_tbl long_char_array_tbl_type;
      t_csi_nbr_tbl              int_array_tbl_type_idx_vc2; --  Bug 6892148;
      l_install_attribute_value  VARCHAR2(4000);
      l_instance_description     VARCHAR2(4000);
      l_location_id              NUMBER;
      l_location_type_code       VARCHAR2(4000);
      l_Item_Is_Installed        BOOLEAN;
      l_Item_Exists_In_Txn       BOOLEAN;
      l_last_item_rev            NUMBER;
      l_attr_counter             NUMBER;
      l_index                    NUMBER;

  BEGIN

    x_run_id:=0;
    Initialize(SYSDATE);

    ERROR_CODE := '0001';

    -- initialize global arrays which are used in dynamic sql blocks
    m_config_hdr_tbl.DELETE;m_config_rev_nbr_tbl.DELETE;m_config_item_tbl.DELETE;
    m_instance_description_tbl.DELETE;m_location_id_tbl.DELETE;

    -- collect config_item_ids for last saved revision ( = p_config_rev_nbr )
    EXECUTE IMMEDIATE
       'BEGIN ' ||
       'SELECT  ' ||
       '     config_item_id  ' ||
       'BULK COLLECT INTO  ' ||
       '     CZ_IB_TRANSACTIONS.m_config_item_tbl ' ||
       'FROM CZ_CONFIG_ITEMS_V ' ||
       'WHERE instance_hdr_id=:1 AND instance_rev_nbr=:2 ' ||
       '     AND CZ_UTILS.conv_num(item_val) IS NOT NULL AND ib_trackable=''1''; ' ||
       'END;'
    USING p_config_hdr_id,p_config_rev_nbr;

    ERROR_CODE := '0002';

    -- set local config items array and reinitialize global config items array
    t_config_item_tbl:=m_config_item_tbl; m_config_item_tbl.DELETE;

    -- if there are no items in config then exit from procedure
    IF t_config_item_tbl.COUNT=0 THEN
      RETURN;
    END IF;

    ERROR_CODE := '0003';

    --
    -- get last installed CSI revisions for each item
    -- t_csi_nbr_tbl is a hash map : config_item_id -> last CSI revision
    --
    get_Last_CSI_Revisions(p_config_inst_hdr_id => p_config_hdr_id,
                           x_csi_nbr_tbl        => t_csi_nbr_tbl);

    -- initialize both OUT arrays
    x_txn_params_tbl := SYSTEM.cz_txn_params_tbl_type(SYSTEM.cz_txn_params_type(NULL,NULL,NULL,NULL,NULL,NULL));
    x_config_attribute_tbl := SYSTEM.cz_config_attribute_tbl_type(SYSTEM.cz_config_attribute_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL));

    ERROR_CODE := '0004';

    --
    -- go through items ( MAIN LOOP )
    --
    FOR i IN t_config_item_tbl.First..t_config_item_tbl.Last
    LOOP

      -- dbms_output.put_line('config_item_id ***> '||TO_CHAR(t_config_item_tbl(i)));

      -- initialize global arrays which are used in dynamic sql
      m_attribute_category_tbl.DELETE;
      m_attribute_name_tbl.DELETE;
      m_attribute_value_tbl.DELETE;

      ERROR_CODE := '0005';

      -- get installed revision of the current item from CSI_ITEM_INSTANCES table
      IF t_csi_nbr_tbl.EXISTS(t_config_item_tbl(i)) THEN
        l_last_item_rev := t_csi_nbr_tbl( t_config_item_tbl(i) );
      ELSE
        l_last_item_rev := 0;
      END IF;

       --dbms_output.put_line('last installed revision ***> '||TO_CHAR(l_last_item_rev));

      IF l_last_item_rev=0 THEN
        l_Item_Is_Installed := FALSE;
      ELSE
        l_Item_Is_Installed := TRUE;
      END IF;

      -----------------------------------------------------------

      ERROR_CODE := '0006';

      IF l_Item_Is_Installed THEN

        ERROR_CODE := '0007';

        get_InstDesc_LocId(p_config_hdr_id        => p_config_hdr_id,
                           p_config_rev_nbr       => l_last_item_rev,
                           p_config_item_id       => t_config_item_tbl(i),
                           x_instance_description => l_instance_description,
                           x_location_id          => l_location_id,
                           x_location_type_code   => l_location_type_code);

        ERROR_CODE := '0008';

        l_index := x_txn_params_tbl.COUNT;

        x_txn_params_tbl(l_index).config_hdr_id        := p_config_hdr_id;
        x_txn_params_tbl(l_index).config_rev_nbr       := l_last_item_rev;
        x_txn_params_tbl(l_index).config_item_id       := t_config_item_tbl(i);
        x_txn_params_tbl(l_index).instance_description := l_instance_description;
        x_txn_params_tbl(l_index).location_id          := l_location_id;
        x_txn_params_tbl(l_index).location_type_code   := l_location_type_code;

        ERROR_CODE := '0009';

        x_txn_params_tbl.EXTEND(1,1);

        ERROR_CODE := '0010';

      END IF; -- end of IF l_Item_Is_Installed


      ERROR_CODE := '0011';

      t_attribute_category_tbl.DELETE;
      t_attribute_name_tbl.DELETE;
      t_attribute_value_tbl.DELETE;

      -- retrieve txn attributes data for last saved revision ( = p_config_rev_nbr )
      get_Txn_Attributes_Data(p_config_hdr_id          => p_config_hdr_id,
                              p_config_rev_nbr         => p_config_rev_nbr,
                              p_config_item_id         => t_config_item_tbl(i),
                              x_attribute_category_tbl => t_attribute_category_tbl,
                              x_attribute_name_tbl     => t_attribute_name_tbl,
                              x_attribute_value_tbl    => t_attribute_value_tbl);

      ERROR_CODE := '0012';

      l_Item_Exists_In_Txn := TRUE;
      IF t_attribute_name_tbl.COUNT=0 THEN -- config item does not exist in txn CSI with revision = p_config_rev_nbr

        ERROR_CODE := '0013';
        l_Item_Exists_In_Txn := FALSE;

        -- retrieve CZ attributes data for  revision = p_config_rev_nbr
        get_CZ_Attributes_Data(p_config_hdr_id          => p_config_hdr_id,
                               p_config_rev_nbr         => p_config_rev_nbr,
                               p_config_item_id         => t_config_item_tbl(i),
                               x_attribute_category_tbl => t_attribute_category_tbl,
                               x_attribute_name_tbl     => t_attribute_name_tbl,
                               x_attribute_value_tbl    => t_attribute_value_tbl);

        ERROR_CODE := '0014';

      END IF;

      IF t_attribute_name_tbl.COUNT>0 THEN

        ERROR_CODE := '0015';

        FOR n IN t_attribute_name_tbl.FIRST..t_attribute_name_tbl.LAST
        LOOP

           ERROR_CODE := '0016';

          l_attr_counter := x_config_attribute_tbl.COUNT;

           ERROR_CODE := '0017';

          x_config_attribute_tbl(l_attr_counter).config_hdr_id   := p_config_hdr_id;
          IF l_Item_Exists_In_Txn THEN
            x_config_attribute_tbl(l_attr_counter).config_rev_nbr  := p_config_rev_nbr;
          ELSE
            x_config_attribute_tbl(l_attr_counter).config_rev_nbr  := l_last_item_rev;
          END IF;

          ERROR_CODE := '0018';

          x_config_attribute_tbl(l_attr_counter).config_item_id  := t_config_item_tbl(i);

          ERROR_CODE := '0019';

          x_config_attribute_tbl(l_attr_counter).attribute_group := t_attribute_category_tbl(n);

          ERROR_CODE := '0020';

          x_config_attribute_tbl(l_attr_counter).attribute_name  := t_attribute_name_tbl(n);

          ERROR_CODE := '0021';

          x_config_attribute_tbl(l_attr_counter).attribute_value := t_attribute_value_tbl(n);

          ERROR_CODE := '0022';

          IF l_Item_Is_Installed THEN

            ERROR_CODE := '0023';

            x_config_attribute_tbl(l_attr_counter).install_rev_nbr:= l_last_item_rev;

            ERROR_CODE := '0024';

            -- get installed attribute value ( revision = l_last_item_rev )
            get_Installed_Attribute_Value(p_config_hdr_id          => p_config_hdr_id,
                                          p_config_rev_nbr         => l_last_item_rev,
                                          p_config_item_id         => t_config_item_tbl(i),
                                          p_attribute_name         => t_attribute_name_tbl(n),
                                          x_attribute_value        => l_install_attribute_value);

            ERROR_CODE := '0025';

            x_config_attribute_tbl(l_attr_counter).install_attribute_value := l_install_attribute_value;

            ERROR_CODE := '0026';

            IF l_Item_Exists_In_Txn=FALSE OR l_last_item_rev=p_config_rev_nbr THEN
               x_config_attribute_tbl(l_attr_counter).attribute_value := l_install_attribute_value;
            END IF;

            ERROR_CODE := '0027';

          ELSE
            ERROR_CODE := '0028';

            x_config_attribute_tbl(l_attr_counter).install_rev_nbr:= 0;
            x_config_attribute_tbl(l_attr_counter).install_attribute_value := NULL;
            ERROR_CODE := '0029';
          END IF;

          x_config_attribute_tbl.EXTEND(1,1);

        END LOOP;

      END IF;

  END LOOP;

  ERROR_CODE := '0030';

   -- remove last element ( which is just NULL based )
  x_txn_params_tbl.DELETE(x_txn_params_tbl.COUNT);
  x_config_attribute_tbl.DELETE(x_config_attribute_tbl.COUNT);

  ERROR_CODE := '0031';

/*
 if x_txn_params_tbl.count>0 then
  LOG_REPORT(m_RUN_ID,'RUN_ID='||TO_CHAR(m_RUN_ID));
  for i in x_txn_params_tbl.first..x_txn_params_tbl.last
  loop
    LOG_REPORT(m_RUN_ID,'x_txn_params_tbl('||TO_CHAR(x_txn_params_tbl(i).config_item_id)||').config_rev_nbr = '||
               TO_CHAR(x_txn_params_tbl(i).config_rev_nbr));

    LOG_REPORT(m_RUN_ID,'x_txn_params_tbl('||TO_CHAR(x_txn_params_tbl(i).config_item_id)||').location_id = '||
               TO_CHAR(x_txn_params_tbl(i).location_id));

    LOG_REPORT(m_RUN_ID,'x_txn_params_tbl('||TO_CHAR(x_txn_params_tbl(i).config_item_id)||').location_type_code = '||
               x_txn_params_tbl(i).location_type_code);

    LOG_REPORT(m_RUN_ID,'x_txn_params_tbl('||TO_CHAR(x_txn_params_tbl(i).config_item_id)||').instance_description = '||
               x_txn_params_tbl(i).instance_description);

  end loop;
 end if;
 */

EXCEPTION
  WHEN OTHERS THEN
    DEBUG(SQLERRM);
    x_run_id:=m_RUN_ID;
    LOG_REPORT(x_run_id,'Internal Error (ERROR_CODE='||ERROR_CODE||') : '||SQLERRM);
END Synchronize_Attributes;

/**
  * check_CZIB_Item PROCEDURE sets x_in_txn TO '1' IF config item
  * (p_config_hdr_id, p_config_rev_nbr, p_config_item_id)
  * EXISTS IN IB Transactions subschema
  * AND sets x_in_inst TO '1' IF config item
  * (p_config_hdr_id, p_config_rev_nbr, p_config_item_id)
  * EXISTS IN IB Instances subschema,
  * otherwise x_in_txn='0' AND   x_in_inst='0'
  */
  PROCEDURE check_CZIB_Item
  (
  p_config_hdr_id   IN  NUMBER,
  p_config_rev_nbr  IN  NUMBER,
  p_config_item_id  IN  NUMBER,
  x_in_txn          OUT NOCOPY VARCHAR2,
  x_in_inst         OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

      x_in_txn:=NO_FLAG; x_in_inst:=NO_FLAG;
    /*
      FOR i IN (SELECT config_inst_item_id FROM CSI_T_TXN_LINE_DETAILS
                WHERE config_inst_hdr_id  = p_config_hdr_id  AND
                config_inst_rev_num  = p_config_rev_nbr AND
                config_inst_item_id = p_config_item_id)
      LOOP
         x_in_txn:=YES_FLAG;
         EXIT;
      END LOOP;

      FOR i IN (SELECT config_inst_item_id FROM CSI_ITEM_INSTANCES
                WHERE config_inst_hdr_id  = p_config_hdr_id  AND
                config_inst_rev_num = p_config_rev_nbr AND
                config_inst_item_id = p_config_item_id)
      LOOP
         x_in_inst:=YES_FLAG;
         EXIT;
      END LOOP;
    */
  END check_CZIB_Item;

  /**
    * wrapper FOR CSI_CZ_INT.Get_Connected_Configurations() PROCEDURE
    */
  PROCEDURE Get_Connected_Configurations
  (
  p_Config_Query_Table 	IN  SYSTEM.cz_config_query_table,
  p_Instance_Level	    IN  VARCHAR2,
  x_Config_Pair_Table	OUT NOCOPY SYSTEM.cz_config_pair_table,
  x_run_id              OUT NOCOPY NUMBER
  ) IS

      t_Config_Query_Table  Config_Query_Table;
      t_Config_Pair_Table   Config_Pair_Table;
      v_config_ind          NUMBER:=1;
      v_return_status       VARCHAR2(255);
      v_return_message      VARCHAR2(2000);
      v_msg_data            VARCHAR2(2000);
      v_message_count       NUMBER;

  BEGIN
      x_run_id:=0;
      Initialize(SYSDATE);

      x_Config_Pair_Table:=SYSTEM.cz_config_pair_table(SYSTEM.cz_config_pair_record
                                                       (NULL,NULL,NULL,NULL,NULL,NULL,
                                                        NULL,NULL,NULL,NULL,NULL,NULL,
                                                        NULL,NULL,NULL,NULL));

      FOR i IN p_Config_Query_Table.FIRST..p_Config_Query_Table.LAST
      LOOP
         t_Config_Query_Table(i).CONFIG_HEADER_ID:=p_Config_Query_Table(i).CONFIG_HEADER_ID;
         t_Config_Query_Table(i).CONFIG_REVISION_NUMBER:=p_Config_Query_Table(i).CONFIG_REVISION_NUMBER;

         LOG_REPORT(m_RUN_ID,'Get_Connected_Configurations  IN config_hdr_id / config_rev_nbr : '||
         TO_CHAR(t_Config_Query_Table(i).CONFIG_HEADER_ID)||' / '||TO_CHAR(t_Config_Query_Table(i).CONFIG_REVISION_NUMBER));

      END LOOP;

      -- CSI_CZ_INT.Get_Connected_Configurations --
      Get_Connected_Configurations
       (
        p_Config_Query_Table  => t_Config_Query_Table,
        p_Instance_Level	=> p_Instance_Level,
        x_Config_Pair_Table   => t_Config_Pair_Table,
        x_return_status	      => v_return_status,
        x_return_message	=> v_return_message
       );

      IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
          x_run_id:=m_RUN_ID;
          LOG_REPORT(x_run_id,'IB API Error : '||v_return_message);
      END IF;

      --
      -- translate internal CSI_CZ_INT type into global SQL type
      --
      IF t_Config_Pair_Table.COUNT>0 THEN
         v_config_ind := 1;
         x_Config_Pair_Table:=SYSTEM.cz_config_pair_table(SYSTEM.cz_config_pair_record(NULL,NULL,NULL,NULL,NULL,NULL,
                                                                                       NULL,NULL,NULL,NULL,NULL,NULL,
                                                                                       NULL,NULL,NULL,NULL));

         FOR i IN t_Config_Pair_Table.FIRST..t_Config_Pair_Table.LAST
         LOOP

            x_Config_Pair_Table(v_config_ind).subject_header_id        := t_Config_Pair_Table(i).subject_header_id;
            x_Config_Pair_Table(v_config_ind).subject_revision_number  := t_Config_Pair_Table(i).subject_revision_number;
            x_Config_Pair_Table(v_config_ind).subject_item_id          := t_Config_Pair_Table(i).subject_item_id;
            x_Config_Pair_Table(v_config_ind).object_header_id         := t_Config_Pair_Table(i).object_header_id;
            x_Config_Pair_Table(v_config_ind).object_revision_number   := t_Config_Pair_Table(i).object_revision_number;
            x_Config_Pair_Table(v_config_ind).object_item_id           := t_Config_Pair_Table(i).object_item_id;
            x_Config_Pair_Table(v_config_ind).root_header_id           := t_Config_Pair_Table(i).root_header_id;
            x_Config_Pair_Table(v_config_ind).root_revision_number     := t_Config_Pair_Table(i).root_revision_number;
            x_Config_Pair_Table(v_config_ind).root_item_id             := t_Config_Pair_Table(i).root_item_id;
            x_Config_Pair_Table(v_config_ind).source_application_id    := t_Config_Pair_Table(i).source_application_id;
            x_Config_Pair_Table(v_config_ind).source_txn_header_ref    := t_Config_Pair_Table(i).source_txn_header_ref;
            x_Config_Pair_Table(v_config_ind).source_txn_line_ref1     := t_Config_Pair_Table(i).source_txn_line_ref1;
            x_Config_Pair_Table(v_config_ind).source_txn_line_ref2     := t_Config_Pair_Table(i).source_txn_line_ref2;
            x_Config_Pair_Table(v_config_ind).source_txn_line_ref3     := t_Config_Pair_Table(i).source_txn_line_ref3;
            x_Config_Pair_Table(v_config_ind).lock_id                  := t_Config_Pair_Table(i).lock_id;
            x_Config_Pair_Table(v_config_ind).lock_status              := t_Config_Pair_Table(i).lock_status;

            x_Config_Pair_Table.EXTEND(1,1);
            v_config_ind :=v_config_ind+1;
         END LOOP;
         x_Config_Pair_Table.DELETE(v_config_ind);
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
         x_run_id:=m_RUN_ID;
         LOG_REPORT(x_run_id,'Internal Error : '||SQLERRM);
  END Get_Connected_Configurations;

  /**
    * wrapper FOR CSI_CZ_INT.Get_Configuration_Revision() PROCEDURE
    *
    * 1.	IF LEVEL IS "Installed", retrieve the "Revision Number" FROM CSI_Item_Instances
    *      FOR the Config_Header_Id passed.
    * 2.	IF LEVEL IS NULL OR "PENDING", THEN
    *     a.	Retrive the "Revision Number" FROM Csi_Item_Instances FOR the given Config_Header_Id.
    *     b.	CHECK IN Transcation Details, IF there IS a revision ON TRANSACTION details
    *         FOR the config_Header_ID, which IS NOT a base revision ON ANY other line IN TRANSACTION details.
    *     c.	IF a revision IS FOUND THEN RETURN Revision AND the LEVEL AS PENDING,
    *         otherwise RETURN the revision FROM the Csi_Item_Instances AND LEVEL AS INSTALLED.
    */
  PROCEDURE Get_Configuration_Revision
  (
  p_Config_Header_Id	    IN      NUMBER,
  p_target_commitment_date  IN      DATE,
  px_Instance_Level         IN OUT NOCOPY  VARCHAR2,
  x_config_rec              OUT NOCOPY     SYSTEM.CZ_CONFIG_REC,
  x_run_id                  OUT NOCOPY     NUMBER
  ) IS

      v_return_status  VARCHAR2(255);
      v_return_message VARCHAR2(2000);
      v_msg_data       VARCHAR2(2000);
      v_message_count      NUMBER;
      l_Config_Rev_Number  NUMBER;
      l_config_rec         config_rec;

  BEGIN
      x_run_id:=0;
      x_config_rec := SYSTEM.CZ_CONFIG_REC(NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL);

      Initialize(SYSDATE);

      -- CSI_CZ_INT.Get_Configuration_Revision --
      Get_Configuration_Revision
      (
      p_Config_Header_Id	    => p_Config_Header_Id,
      p_target_commitment_date    => p_target_commitment_date,
      px_Instance_Level		    => px_Instance_Level,
      x_Config_Rev_Number	    => l_Config_Rev_Number,
      x_config_rec                => l_config_rec,
      x_return_status		    => v_return_status,
      x_return_message		    => v_return_message
      );

      x_config_rec.source_application_id := l_config_rec.source_application_id;
      x_config_rec.source_txn_header_ref := l_config_rec.source_txn_header_ref;
      x_config_rec.source_txn_line_ref1  := l_config_rec.source_txn_line_ref1;
      x_config_rec.source_txn_line_ref2  := l_config_rec.source_txn_line_ref2;
      x_config_rec.source_txn_line_ref3  := l_config_rec.source_txn_line_ref3;
      x_config_rec.instance_id           := l_config_rec.instance_id;
      x_config_rec.lock_id               := l_config_rec.lock_id;
      x_config_rec.lock_status           := l_config_rec.lock_status;
      x_config_rec.config_inst_hdr_id    := l_config_rec.config_inst_hdr_id;
      x_config_rec.config_inst_item_id   := l_config_rec.config_inst_item_id;
      x_config_rec.config_inst_rev_num   := l_config_rec.config_inst_rev_num;

      IF (v_return_status <> fnd_api.g_ret_sts_success) THEN
          DEBUG('Get_Configuration_Revision : '||v_return_message);
          x_run_id:=m_RUN_ID;
          LOG_REPORT(x_run_id,'IB API Error : '||v_return_message);
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
         x_run_id:=m_RUN_ID;
         LOG_REPORT(x_run_id,'Internal Error : '||SQLERRM);
  END Get_Configuration_Revision;

  --
  -- this procedure is used in order to create IB data for
  -- the copied model
  --
  PROCEDURE clone_IB_Data
  (
  p_config_hdr_id  IN  NUMBER,
  p_config_rev_nbr IN  NUMBER,
  x_run_id         OUT NOCOPY NUMBER
  ) IS

      t_instance_hdr_tbl       int_array_tbl_type;
      t_instance_rev_nbr_tbl   int_array_tbl_type;
      t_config_item_tbl        int_array_tbl_type;
      t_config_instance_tbl    SYSTEM.cz_config_instance_tbl_type;
      v_txn_type_id            NUMBER:=CZ_TRANSACTION_TYPE_ID;

  BEGIN
      x_run_id:=0;
      ERROR_CODE:='0101';

      Initialize(SYSDATE);
      t_config_instance_tbl := SYSTEM.cz_config_instance_tbl_type(SYSTEM.cz_config_instance_type(NULL,NULL,NULL,NULL));

      ERROR_CODE:='0102';
      --
      -- collect all instances
      --
      SELECT instance_hdr_id,instance_rev_nbr,config_item_id
      BULK COLLECT INTO t_instance_hdr_tbl,t_instance_rev_nbr_tbl,t_config_item_tbl
      FROM  CZ_CONFIG_ITEMS
      WHERE config_hdr_id = p_config_hdr_id  AND
            config_rev_nbr= p_config_rev_nbr AND
            component_instance_type='I'      AND
            ib_trackable=YES_FLAG AND deleted_flag=NO_FLAG;

      ERROR_CODE:='0103';

      IF t_instance_hdr_tbl.COUNT=0 THEN
         RETURN;
      END IF;

      ERROR_CODE:='0104';

      FOR i IN t_instance_hdr_tbl.FIRST..t_instance_hdr_tbl.LAST
      LOOP
         t_config_instance_tbl(i).config_hdr_id     :=t_instance_hdr_tbl(i);
         t_config_instance_tbl(i).config_item_id    :=t_config_item_tbl(i);
         t_config_instance_tbl(i).old_config_rev_nbr:=t_instance_rev_nbr_tbl(i);
         t_config_instance_tbl(i).new_config_rev_nbr:=t_instance_rev_nbr_tbl(i);
         t_config_instance_tbl.EXTEND(1,1);
      END LOOP;

      ERROR_CODE:='0105';

      t_config_instance_tbl.DELETE(t_config_instance_tbl.COUNT);

      ERROR_CODE:='0106';

      --
      -- create IB data
      --
      Update_Instances
       (
       p_config_instance_tbl    => t_config_instance_tbl,
       p_effective_date         => NULL,
       p_txn_type_id            => v_txn_type_id,
       x_run_id                 => x_run_id
       );

      ERROR_CODE:='0107';

  EXCEPTION
      WHEN OTHERS THEN
           DEBUG('ERROR_CODE='||ERROR_CODE||' : '||SQLERRM);
           x_run_id:=m_RUN_ID;
           LOG_REPORT(x_run_id,'Internal Error (ERROR_CODE='||ERROR_CODE||') : '||SQLERRM);
  END clone_IB_Data;


  PROCEDURE Test_Update_Instances
  (
  p_instance_hdr_id  NUMBER,
  p_config_item_id   NUMBER,
  p_old_rev_nbr      NUMBER,
  p_new_rev_nbr      NUMBER
  ) IS
      v_run_id            NUMBER;
      v_txn_type_id       NUMBER:=CZ_TRANSACTION_TYPE_ID;

  BEGIN
      --DBMS_OUTPUT.enable(2000000);
      Update_Instances
      (
       p_config_instance_tbl  => SYSTEM.cz_config_instance_tbl_type(SYSTEM.cz_config_instance_type(p_instance_hdr_id,p_config_item_id,p_old_rev_nbr,p_new_rev_nbr)),
       p_effective_date       => SYSDATE,
       p_txn_type_id          => v_txn_type_id,
       x_run_id               => v_run_id
       );
      DEBUG('v_run_id='||TO_CHAR(v_run_id));
  END Test_Update_Instances;

  PROCEDURE Test_Connected_Configurations IS

      v_run_id             NUMBER;
      t_config_pair_table  SYSTEM.cz_config_pair_table:=SYSTEM.cz_config_pair_table();
  BEGIN
      --DBMS_OUTPUT.enable(2000000);
      Get_Connected_Configurations
       (
        p_Config_Query_Table  => SYSTEM.cz_config_query_table(SYSTEM.cz_config_query_record(1,1)),
        p_Instance_Level	  => 'PENDING',
        x_Config_Pair_Table	  => t_config_pair_table,
        x_run_id              => v_run_id
       );
      DEBUG('v_run_id='||TO_CHAR(v_run_id));
  END Test_Connected_Configurations;


  PROCEDURE Test_Configuration_Revision
  (
  p_config_hdr_id IN NUMBER
  ) IS

      v_rev_nbr  NUMBER;
      v_run_id   NUMBER;
      v_level    VARCHAR2(255):='INSTALLED';
      v_config_rec  SYSTEM.cz_config_rec;

  BEGIN

      Get_Configuration_Revision
       (
        p_Config_Header_Id	    => p_config_hdr_id,
        p_target_commitment_date  => SYSDATE,
        px_Instance_Level         => v_level,
        --x_Config_Rev_Number	    => v_rev_nbr,
        x_config_rec              => v_config_rec,
        x_run_id                  => v_run_id
       );

       DEBUG('Config_Rev_Number='||TO_CHAR(v_rev_nbr));

  END Test_Configuration_Revision;


END CZ_IB_TRANSACTIONS;

/
