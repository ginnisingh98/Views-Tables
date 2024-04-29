--------------------------------------------------------
--  DDL for Package Body OKS_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_MASS_UPDATE_PVT" AS
/* $Header: OKSRMUPB.pls 120.61.12010000.3 2009/01/15 13:35:19 cgopinee ship $ */

    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OBJECT                          |SEL|INS|UPD|DEL|CRE|OTHER                 |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_CLASS_OPERATIONS            | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_SUBCLASSES_B                | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_OPER_INST_PVT               |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_STREAM_LEVELS_V             | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_CUST_ACCOUNTS                | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| MTL_SYSTEM_ITEMS_TL             | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| MTL_SYSTEM_ITEMS_B_KFV          | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_ITEMS                     | X | X |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_RENEW_UTIL_PVT              |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_VERS_NUMBERS              | X |   | X |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| FND_ATTACHED_DOCUMENTS          |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| okc_k_headers_all_b                 | X |   | X |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| JTF_NOTES_PUB                   |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| JTF_NOTES_VL                    | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_PARTIES                      | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_CUST_ACCT_RELATE_ALL         | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| DUAL                            | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_GROUPS_B                  | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_RELATIONSHIPS                | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_ORG_CONTACTS                 | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_CUST_SITE_USES_ALL           | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| HZ_CUST_ACCT_SITES_ALL          | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_INSTANCE_K_DTLS_TEMP        | X | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_K_SALES_CREDITS_V           | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_ACCESSES_V                | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_CLASSES_B                   | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_DATATYPES                   |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_KHR_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_CHR_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_GVE_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_CPL_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKX_CUST_SITE_USES_V            | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_K_HEADERS_B                 | X | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_ACCESSES                  |   | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_K_SALES_CREDITS             |   | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CS_CTR_ASSOCIATIONS             | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_COVERAGES_PUB               |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_INST_CND_PUB                |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_LINES_B                   | X | X | X |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_LINES_TL                  |   | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_K_LINES_B                   | X | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_K_LINES_TL                  |   | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_BILLING_PROFILES_B          | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_BILL_SCH                    |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_HEADERS_B_S               | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_OPERATION_LINES             | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_OPERATION_INSTANCES         | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_ITEMS_V                   | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_LINES_V                   | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_K_PARTY_ROLES_B             | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_INSTANCE_TEMP               | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_STATUSES_V                  | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_STATUSES_B                  | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CS_COUNTERS                     | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CS_COUNTER_GROUPS               | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CS_INCIDENTS_ALL_B              | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_BATCH_RULES                 | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CSI_MASS_EDIT_ENTRIES_TL        | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_INSTANCE_HISTORY            | X | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_QA_CHECK_PUB                |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKC_CONTRACT_PUB                |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_WF_K_PROCESS_PVT            |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_IHD_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_INS_PVT                     |   |   |   |   |   |X                     |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| CSI_ITEM_INSTANCES              | X |   |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+
    --| OKS_INST_HIST_DETAILS           |   | X |   |   |   |                      |
    --+---------------------------------+---+---+---+---+---+----------------------+

   l_hdr_id       NUMBER;
   l_line_id      NUMBER;
   l_lineno_new   NUMBER := 0;
   l_Tlineno_new   NUMBER := 0;
   l_gl_dummy     NUMBER := 0;
    TYPE Var2000TabTyp IS TABLE OF Varchar2(2000)
     INDEX BY BINARY_INTEGER;
    ------*  Procedure create_transaction_source *-------
    -- Procedure to create transaction souce in operation
    -- instance and opeatiopn lines.
    -- One line per contract will be created in operation
    -- instance and one line for each new subline will be
    -- created in operation lines.
    -----------------------------------------------------


   PROCEDURE create_transaction_source (
      p_batch_id                          NUMBER,
      p_source_line_id                    NUMBER,
      p_target_line_id                    NUMBER,
      p_source_chr_id                     NUMBER,
      p_target_chr_id                     NUMBER,
      p_transaction                       VARCHAR2,
      x_return_status            OUT NOCOPY     VARCHAR2,
      x_msg_count                OUT NOCOPY     NUMBER,
      x_msg_data                 OUT NOCOPY     VARCHAR2
   )
   IS
      CURSOR cop_csr (
         p_opn_code                          VARCHAR2
      )
      IS
         SELECT ID
           FROM okc_class_operations
          WHERE cls_code = (SELECT cls_code
                              FROM okc_subclasses_b
                             WHERE code = 'SERVICE')
            AND opn_code = p_opn_code;


      CURSOR check_oper_inst_csr (
         p_cop_id                          NUMBER,
         p_chr_id                          NUMBER,
         p_batch_id                        NUMBER
      )
      IS
         SELECT ID
           FROM okc_operation_instances
          WHERE cop_id        = p_cop_id
            AND target_chr_id = p_chr_id
            AND batch_id      = p_batch_id
            AND status_code   = 'PROCESSED';

         Cursor check_rec_exists(P_Id Number) Is
            Select 'X'
            From   Okc_operation_lines ol
                  ,okc_operation_instances Ins
            Where  ol.subject_chr_id = P_target_chr_id
            And    ol.object_chr_id = p_source_chr_id
            And    ol.subject_cle_id Is Null
            And    ol.object_cle_id Is Null
            And    ins.id = p_id;

      l_cop_id                   NUMBER;
      l_api_version     CONSTANT NUMBER                          := 1.0;
      l_init_msg_list   CONSTANT VARCHAR2 (1)                    := 'F';
      l_return_status            VARCHAR2 (1)                    := 'S';
      l_oiev_tbl_in              okc_oper_inst_pvt.oiev_tbl_type;
      l_oiev_tbl_out             okc_oper_inst_pvt.oiev_tbl_type;
      l_olev_tbl_in              okc_oper_inst_pvt.olev_tbl_type;
      l_olev_tbl_out             okc_oper_inst_pvt.olev_tbl_type;
      l_oie_id                   NUMBER;
      l_oper_instance_id         NUMBER;
      l_exists                   Varchar2(1);
   BEGIN
      x_return_status := l_return_status;

      -- get class operation id
      OPEN cop_csr (p_transaction);
      FETCH cop_csr  INTO l_cop_id;
      CLOSE cop_csr;



    OPEN check_oper_inst_csr(l_cop_id, p_target_chr_id,p_batch_id);
    FETCH check_oper_inst_csr INTO l_oie_id;

    IF check_oper_inst_csr%FOUND
    THEN
         l_return_status           := 'S';
         l_oper_instance_id        := l_oie_id;

    ELSE
        l_oper_instance_id := okc_p_util.raw_to_number (SYS_GUID ());
        INSERT INTO OKC_OPERATION_INSTANCES(
        id,
        cop_id,
        status_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        name,
        target_chr_id,
	    request_id,
	    program_application_id,
	    program_id,
	    program_update_date,
         jtot_object1_code,
         object1_id1,
         object1_id2,
         batch_id

       )
      VALUES (
         l_oper_instance_id,
        l_cop_id,
        'PROCESSED',
        1,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        null,
        p_target_chr_id,
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        null,
        null,
        null,
        p_batch_id
       );
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.OKS_IB_UTIL_UB.Create_transaction_source',
                                      '.Create_Operation_Instance(Return status = '||l_return_status ||')'  );
         END IF;

      End If;
      CLOSE check_oper_inst_csr;

      INSERT INTO OKC_OPERATION_LINES(
        id,
        select_yn,
        process_flag,
        active_yn,
        oie_id,
	   parent_ole_id,
        subject_chr_id,
        object_chr_id,
        subject_cle_id,
        object_cle_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        message_code)
      VALUES (
        okc_p_util.raw_to_number (SYS_GUID ()),
        null,
        'P',
        'Y',
        l_oper_instance_id,
	    null,
        p_target_chr_id,
        p_source_chr_id,
        p_target_line_id,
        p_source_line_id,
        1,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
	   decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
	   decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        null);


          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.OKS_IB_UTIL_UB.Create_transaction_source',
                'OKC_OPER_INST_PUB.Create_Operation_Line(Return status = '||l_return_status ||')'  );
          END IF;
If p_transaction = 'RENEWAL' Then
      Open check_rec_exists(l_oper_instance_id);
      Fetch check_rec_exists into l_exists ;
      Close check_rec_exists;
      If l_exists is  Null Then
        INSERT INTO OKC_OPERATION_LINES(
        id,
        select_yn,
        process_flag,
        active_yn,
        oie_id,
	   parent_ole_id,
        subject_chr_id,
        object_chr_id,
        subject_cle_id,
        object_cle_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        message_code)
      VALUES (
        okc_p_util.raw_to_number (SYS_GUID ()),
        null,
        'P',
        'Y',
        l_oper_instance_id,
	    null,
        p_target_chr_id,
        p_source_chr_id,
        Null,
        Null,
        1,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
	   decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
	   decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        null);


          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.OKS_IB_UTIL_UB.Create_transaction_source',
                'OKC_OPER_INST_PUB.Create_Operation_Line(Return status = '||l_return_status ||')'  );
          END IF;
     End If;

  End If;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error while creating the transaction sourec : '
         || SQLCODE||':'|| SQLERRM );
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.OKS_IB_UTIL_UB.Create_transaction_source',
                'Error while creating the transaction sourec :( sqlcode = '||SQLCODE
                ||') sqlerrm = ( '|| SQLERRM || ')' );
          END IF;

         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the transaction sourec : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;




   Function get_ste_code(p_sts_code Varchar2) return Varchar2
   Is
    CUrsor l_ste_csr Is
    Select ste_code
    From   Okc_statuses_b
    Where code = p_sts_code;
    l_ste_code Varchar2(30);
    Begin
          Open l_ste_csr;
          Fetch l_ste_csr into l_ste_code;
          Close l_ste_csr;
          return(l_ste_code);
    End;


Function Negotiated_amount
        (P_start_date IN Date
        ,P_end_date IN Date
        ,P_price_uom IN Varchar2
        ,P_period_type IN Varchar2
        ,P_period_start  IN Varchar2
        ,P_new_start_date  IN Date
        ,P_amount  IN  Number
        ,P_Currency  IN  Varchar2)  Return Number Is
l_duration_xfer Number;
l_duration_total Number;
l_amount  Number;
l_price_uom Varchar2(30);
price_uom_trf  Varchar2(30);

Begin

       If P_price_uom is Null Then
           l_price_uom := Oks_misc_util_web.duration_unit
                          (
                            P_start_Date,
                            P_end_date);

       Else
           l_price_uom := p_price_uom;

       End If;

       l_duration_xfer :=  OKS_TIME_MEASURES_PUB.get_quantity
                                (trunc(P_new_start_date ) ,
                                 trunc(P_end_date),
                                 l_price_uom ,
                                 P_period_type ,
                                 P_period_Start );



      l_duration_total  := OKS_TIME_MEASURES_PUB.get_quantity
                                (trunc(P_Start_date) ,
                                 trunc(P_end_date),
                                 l_price_uom,
                                 P_period_type ,
                                 P_period_Start );


     l_amount := oks_extwar_util_pvt.round_currency_amt(P_amount * l_duration_xfer/l_duration_total,P_currency);

     return (nvl(l_amount,0));


End;

Function get_line_status(p_lse_id Number,P_start_date date, p_end_date Date, P_line_status varchar2,p_batch_status Varchar2) return Varchar2 Is
l_sts_code Varchar2(50);
begin
         If p_lse_id in (14,18) Then
              IF trunc(p_start_date) > trunc(SYSDATE)
              THEN
                   l_sts_code := get_status_code('SIGNED');

              ELSIF  trunc(p_start_date) <= trunc(SYSDATE)  AND p_end_date >= trunc(SYSDATE)
              THEN
                  l_sts_code := get_status_code('ACTIVE');

              END IF;

         Else
              If p_line_status = 'ENTERED' Then
                  l_sts_code := get_status_code('ENTERED');
              Else
                  If get_ste_code(p_batch_status) = 'ACTIVE' Then
                    IF trunc(p_start_date) > trunc(SYSDATE)
                    THEN
                         l_sts_code := get_status_code('SIGNED');

                    ELSIF  trunc(p_start_date) <= trunc(SYSDATE)  AND trunc(p_end_date) >= trunc(SYSDATE)
                    THEN
                         l_sts_code := get_status_code('ACTIVE');

                    END IF;
                  Else
                    l_sts_code := p_batch_status;
                  End if;
               End If;


         End If;
return(l_sts_code);
End;


   Function get_status_code(p_ste_code Varchar2) return Varchar2
   Is
    CUrsor l_sts_csr Is
    Select code
    From   Okc_statuses_b
    Where ste_code = p_ste_code
    And default_yn = 'Y';
    l_sts_code Varchar2(30);
    Begin
          Open l_sts_csr;
          Fetch l_sts_csr into l_sts_code;
          Close l_sts_csr;
          return(l_sts_code);
    End;


   -----------*  Procedure get_sts_code *--------------
   -- Procedure to get the default sts code and ste code.

   -----------------------------------------------------

   PROCEDURE get_sts_code(
          p_ste_code                          VARCHAR2,
          p_sts_code                          VARCHAR2,
          x_ste_code               OUT NOCOPY VARCHAR2,
          x_sts_code               OUT NOCOPY VARCHAR2
      ) IS
          CURSOR l_ste_csr IS
               SELECT code
                 FROM okc_statuses_b
                WHERE ste_code = p_ste_code
                  AND default_yn = 'Y';

          CURSOR l_sts_csr IS
               SELECT a.code, a.ste_code
                 FROM okc_statuses_b a, okc_statuses_b b
                WHERE b.code = p_sts_code
                  AND b.ste_code = a.ste_code
                  AND a.default_yn = 'Y';

          l_sts_code                    VARCHAR2( 30 );
     BEGIN
          IF p_sts_code IS NULL THEN
               OPEN l_ste_csr;
               FETCH l_ste_csr INTO x_sts_code;
               CLOSE l_ste_csr;
               x_ste_code := p_ste_code;
          ELSE
               OPEN l_sts_csr;
               FETCH l_sts_csr INTO x_sts_code, x_ste_code;
               CLOSE l_sts_csr;
          END IF;
     EXCEPTION
          WHEN OTHERS THEN
               OKC_API.SET_MESSAGE(
                    g_app_name,
                    g_unexpected_error,
                    g_sqlcode_token,
                    SQLCODE,
                    g_sqlerrm_token,
                    SQLERRM
                );
   END;

   --------*  Procedure initialize_okc_hdr_tbl *--------
   -- Procedure to initialize okc_hdr plsql table before
   -- assigning values
   -----------------------------------------------------

   PROCEDURE initialize_okc_hdr_tbl (
      x_okc_hdr_tbl              OUT NOCOPY okc_chr_pvt.chrv_tbl_type,
      p_index                             NUMBER DEFAULT g_num_one
   )
   IS
   BEGIN
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.initialize_okc_tbl',
                         'Begin'
                        );
      END IF;

      x_okc_hdr_tbl (p_index).ID                    := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).object_version_number := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).sfwt_flag             := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).chr_id_response       := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).chr_id_award          := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).chr_id_renewed        := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).inv_organization_id   := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).sts_code              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).qcl_id                := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).scs_code              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).contract_number       := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).currency_code         := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).contract_number_modifier := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).archived_yn           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).deleted_yn            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).cust_po_number_req_yn := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).pre_pay_req_yn        := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).cust_po_number        := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).short_description     := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).comments              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).description           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).dpas_rating           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).cognomen              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).template_yn           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).template_used         := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).date_approved         := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).datetime_cancelled    := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).auto_renew_days       := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).date_issued           := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).datetime_responded    := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).non_response_reason   := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).non_response_explain  := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).rfp_type              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).chr_type              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).keep_on_mail_list     := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).set_aside_reason      := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).set_aside_percent     := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).response_copies_req   := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).date_close_projected  := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).datetime_proposed     := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).date_signed           := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).date_terminated       := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).date_renewed          := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).trn_code              := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).start_date            := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).end_date              := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).org_id                := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).buy_or_sell           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).issue_or_receive      := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).estimated_amount      := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).chr_id_renewed_to     := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).estimated_amount_renewed
                                                    := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).currency_code_renewed := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).upg_orig_system_ref   := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).upg_orig_system_ref_id
                                                    := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).application_id        := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).orig_system_source_code
                                                    := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).orig_system_id1       := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).orig_system_reference1
                                                    := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).program_id            := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).request_id            := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).price_list_id         := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).pricing_date          := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).sign_by_date          := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).program_update_date   := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).total_line_list_price := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).program_application_id
                                                    := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).user_estimated_amount := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).governing_contract_yn := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute_category    := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute1            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute2            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute3            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute4            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute5            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute6            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute7            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute8            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute9            := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute10           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute11           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute12           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute13           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute14           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).attribute15           := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).created_by            := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).creation_date         := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).last_updated_by       := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).last_update_date      := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).last_update_login     := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).old_sts_code          := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).new_sts_code          := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).old_ste_code          := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).new_ste_code          := okc_api.g_miss_char;
      --new columns to replace rules
      x_okc_hdr_tbl (p_index).conversion_type       := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).payment_instruction_type := okc_api.g_miss_char;

      x_okc_hdr_tbl (p_index).conversion_rate       := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).conversion_rate_date  := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).conversion_euro_rate  := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).cust_acct_id          := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).bill_to_site_use_id   := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).inv_rule_id           := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).renewal_type_code     := okc_api.g_miss_char;
      x_okc_hdr_tbl (p_index).renewal_notify_to     := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).renewal_end_date      := okc_api.g_miss_date;
      x_okc_hdr_tbl (p_index).ship_to_site_use_id   := okc_api.g_miss_num;
      x_okc_hdr_tbl (p_index).payment_term_id       := okc_api.g_miss_num;
   END initialize_okc_hdr_tbl;

   --------*  Procedure initialize_oks_hdr_tbl *--------
   -- Procedure to initialize oks_hdr plsql table before
   -- assigning values
   -----------------------------------------------------

   PROCEDURE initialize_oks_hdr_tbl (
      x_oks_hdr_tbl              OUT NOCOPY oks_khr_pvt.khrv_tbl_type,
      p_index                             NUMBER DEFAULT g_num_one
   )
   IS
   BEGIN
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.initialize_oks_tbl',
                         'Begin'
                        );
      END IF;

      x_oks_hdr_tbl (p_index).ID                     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).chr_id                 := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).acct_rule_id           := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).payment_type           := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).cc_no                  := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).cc_expiry_date         := okc_api.g_miss_date;
      x_oks_hdr_tbl (p_index).cc_bank_acct_id        := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).cc_auth_code           := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).commitment_id          := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).grace_duration         := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).grace_period           := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).est_rev_percent        := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).est_rev_date           := okc_api.g_miss_date;
      x_oks_hdr_tbl (p_index).tax_amount             := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).tax_status             := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).tax_code               := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).tax_exemption_id       := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).billing_profile_id     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_status         := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).electronic_renewal_flag := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).quote_to_contact_id    := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).quote_to_site_id       := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).quote_to_email_id      := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).quote_to_phone_id      := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).quote_to_fax_id        := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_po_required    := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_po_number      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_price_list     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_pricing_type   := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_markup_percent := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_grace_duration := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_grace_period   := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_est_rev_percent := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_est_rev_duration
                                                     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_est_rev_period := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_price_list_used := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_type_used      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_notification_to := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_po_used        := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_pricing_type_used
                                                     := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_markup_percent_used
                                                     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).rev_est_percent_used   := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).rev_est_duration_used  := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).rev_est_period_used    := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).billing_profile_used   := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).ern_flag_used_yn       := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).evn_threshold_amt      := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).evn_threshold_cur      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).ern_threshold_amt      := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).ern_threshold_cur      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).renewal_grace_duration_used
                                                     := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).renewal_grace_period_used
                                                     := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).inv_trx_type           := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).inv_print_profile      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).ar_interface_yn        := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).hold_billing           := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).summary_trx_yn         := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).service_po_number      := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).service_po_required    := okc_api.g_miss_char;
      x_oks_hdr_tbl (p_index).object_version_number  := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).security_group_id      := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).request_id             := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).created_by             := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).creation_date          := okc_api.g_miss_date;
      x_oks_hdr_tbl (p_index).last_updated_by        := okc_api.g_miss_num;
      x_oks_hdr_tbl (p_index).last_update_date       := okc_api.g_miss_date;
      x_oks_hdr_tbl (p_index).last_update_login      := okc_api.g_miss_num;
   END initialize_oks_hdr_tbl;

   ----------*  Function check_strmlvl_exists *---------
   -- function to check if billing schedule exists for a
   -- service line.
   -----------------------------------------------------

   FUNCTION check_strmlvl_exists (
      p_cle_id                   IN       NUMBER
   )
      RETURN BOOLEAN
   IS
      CURSOR l_billsch_csr (
         p_cle_id                   IN       NUMBER
      )
      IS
         SELECT ID
           FROM oks_stream_levels_v
          WHERE cle_id = p_cle_id;

      l_strmlvl_id   NUMBER;
   BEGIN
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'oks_mass_update.check_strmlvl_exists',
                                      'Begin' );
      END IF;

      OPEN l_billsch_csr (p_cle_id);
      FETCH l_billsch_csr INTO l_strmlvl_id;

      IF (l_billsch_csr%FOUND)
      THEN
         RETURN (FALSE);
      ELSE
         RETURN (TRUE);
      END IF;

      CLOSE l_billsch_csr;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN (TRUE);
   END check_strmlvl_exists;

   -------------*  Procedure get_party_id *-------------
   -- Procedure to get party_id for a given account
   -----------------------------------------------------

   PROCEDURE get_party_id (
      p_cust_id                  IN       NUMBER,
      x_party_id                 OUT NOCOPY NUMBER
   )
   IS
      CURSOR l_party_csr
      IS
         SELECT party_id
           FROM hz_cust_accounts
          WHERE cust_account_id = p_cust_id;
   BEGIN
      OPEN l_party_csr;

      FETCH l_party_csr
       INTO x_party_id;

      CLOSE l_party_csr;
   END get_party_id;

   -------------*  Procedure get_invoice_text *-------------
   -- Procedure to get format the invoice text
   -----------------------------------------------------

   FUNCTION get_invoice_text (
      p_product_item             IN       NUMBER,
      p_start_date               IN       DATE,
      p_end_date                 IN       DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR l_inv_csr (
         p_product_item                      NUMBER
      )
      IS
         SELECT t.description NAME,
                b.concatenated_segments description
           FROM mtl_system_items_b_kfv b,
                mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_product_item
            AND ROWNUM < 2;

      l_object_code              okc_k_items.jtot_object1_code%TYPE;
      l_object1_id1              okc_k_items.object1_id1%TYPE;
      l_object1_id2              okc_k_items.object1_id2%TYPE;
      l_no_of_items              okc_k_items.number_of_items%TYPE;
      l_name                     VARCHAR2 (2000);
      l_desc                     VARCHAR2 (2000);
      l_formatted_invoice_text   VARCHAR2 (2000);
   BEGIN
      OPEN l_inv_csr (p_product_item);

      FETCH l_inv_csr
       INTO l_name,
            l_desc;

      CLOSE l_inv_csr;

      IF fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_DESC'
      THEN
         l_desc := l_name;
      ELSE
         l_desc := l_desc;
      END IF;

      l_formatted_invoice_text := SUBSTR (   l_desc
                                          || ':'
                                          || p_start_date
                                          || ':'
                                          || p_end_date,
                                          1,
                                          450
                                         );
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'oks_mass_update.get_invoice_text',
                                      'l_formatted_invoice_text = ('|| l_formatted_invoice_text || ')' );
      END IF;

      RETURN (l_formatted_invoice_text);
   END get_invoice_text;

   ------------*  Procedure get_setup_attr *------------
   -- Procedure to get the GCD set up attributes required
   -- for transfer contracts creation.
   -- qcl_id, prd_id, contract_group,third party rle_code
   -----------------------------------------------------

   PROCEDURE get_setup_attr (
      p_party_id                 IN       NUMBER,
      p_org_id                   IN       NUMBER,
      setup_attr                 OUT NOCOPY     setup_rec,
      x_return_status            OUT NOCOPY     VARCHAR2,
      x_msg_count                OUT NOCOPY     NUMBER,
      x_msg_data                 OUT NOCOPY     VARCHAR2
   )
   IS
      l_rnrl_rec_out   oks_renew_util_pvt.rnrl_rec_type;
   BEGIN
      Oks_Renew_Util_Pub.get_renew_rules (
           p_api_version        => 1.0,
           p_init_msg_list      => 'T',
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_chr_id             => NULL,
           p_party_id           => p_party_id,
           p_org_id             => p_org_id,
           p_date               => SYSDATE,
           p_rnrl_rec           => NULL,
           x_rnrl_rec           => l_rnrl_rec_out
          );

       IF (Fnd_Log.LEVEL_EVENT >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.string(Fnd_Log.LEVEL_EVENT,G_MODULE_CURRENT||'.get_setup_attr',
                'get_renew_rules: status = ( '|| x_return_status|| ' )' );
       END IF;
       If Not x_return_status = 'S' Then

         Raise G_EXCEPTION_HALT_VALIDATION;
      End If;
      setup_attr.cgp_new_id := l_rnrl_rec_out.cgp_new_id;
      setup_attr.pdf_id     := l_rnrl_rec_out.pdf_id;
      setup_attr.qcl_id     := l_rnrl_rec_out.qcl_id;
      setup_attr.rle_code   := l_rnrl_rec_out.rle_code;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.get_setup_attr',
                            'get_renew_rules: values = ( group ='
                         || setup_attr.cgp_new_id
                         || 'pdf id ='
                         || setup_attr.pdf_id
                         || 'qcl_id ='
                         || setup_attr.qcl_id
                         || 'rle_code = '
                         || setup_attr.rle_code
                         || ' )'
                        );
      END IF;


     EXCEPTION
          WHEN G_EXCEPTION_HALT_VALIDATION THEN

               NULL;
   END get_setup_attr;




   -----------*  Function get_major_version *-----------
   -- Procedure to get the contracts major version to
   -- copy the notes
   -----------------------------------------------------

   FUNCTION get_major_version (
      p_chr_id                            NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR l_cvm_csr
      IS
         SELECT TO_CHAR (major_version)
           FROM okc_k_vers_numbers
          WHERE chr_id = p_chr_id;

      x_from_version   fnd_attached_documents.pk2_value%TYPE   := NULL;
   BEGIN
      OPEN l_cvm_csr;

      FETCH l_cvm_csr
       INTO x_from_version;

      CLOSE l_cvm_csr;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.get_major_version',
                         'version = ( ' || x_from_version || ' )'
                        );
      END IF;

      RETURN x_from_version;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END get_major_version;

   --------*  Procedure set_attch_session_vars *--------
   -- Procedure to set the attached session variables
   -- to copy the notes
   -----------------------------------------------------

   PROCEDURE set_attach_session_vars (
      p_chr_id                            NUMBER
   )
   IS
      l_app_id   NUMBER;

      CURSOR l_chr_csr
      IS
         SELECT application_id
           FROM okc_k_headers_all_b
          WHERE ID = p_chr_id;
   BEGIN
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.set_attach_ses_vars',
                         'Begin'
                        );
      END IF;

      IF (    p_chr_id IS NOT NULL
          AND fnd_attachment_util_pkg.function_name IS NULL
         )
      THEN
         OPEN l_chr_csr;

         FETCH l_chr_csr
          INTO l_app_id;

         CLOSE l_chr_csr;

         IF (l_app_id = 515)
         THEN
            fnd_attachment_util_pkg.function_name := 'OKSAUDET';
            fnd_attachment_util_pkg.function_type := 'O';
         ELSE
            fnd_attachment_util_pkg.function_name := 'OKCAUDET';
            fnd_attachment_util_pkg.function_type := 'O';
         END IF;
      END IF;
   END set_attach_session_vars;

   -----------*  Procedure create_csi_note *------------
   -- Procedure to copy the csi note to each contract.
   -----------------------------------------------------

   PROCEDURE create_csi_note (
      p_source_object_id         IN       NUMBER,
      p_note                     IN       VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_jtf_note_id             NUMBER;
      l_jtf_note_contexts_tab   jtf_notes_pub.jtf_note_contexts_tbl_type;

   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.create_csi_note',
                         'note = ( ' || p_note || ' )'
                        );
      END IF;

      jtf_notes_pub.create_note
                          (p_jtf_note_id                => NULL,
                           p_api_version                => 1.0,
                           p_init_msg_list              => 'F',
                           p_commit                     => 'F',
                           p_validation_level           => 0,
                           x_return_status              => x_return_status,
                           x_msg_count                  => x_msg_count,
                           x_msg_data                   => x_msg_data,
                           p_source_object_code         => 'OKS_HDR_NOTE',
                           p_source_object_id           => p_source_object_id,
                           p_notes                      => p_note,
                           p_notes_detail               => NULL,
                           p_note_status                => 'I',
                           p_note_type                  => NULL,  --- What should be the note type
                           p_entered_by                 => fnd_global.user_id,
                           p_entered_date               => SYSDATE,
                           x_jtf_note_id                => l_jtf_note_id,
                           p_creation_date              => SYSDATE,
                           p_created_by                 => fnd_global.user_id,
                           p_last_update_date           => SYSDATE,
                           p_last_updated_by            => fnd_global.user_id,
                           p_last_update_login          => fnd_global.login_id,
                           p_attribute1                 => NULL,
                           p_attribute2                 => NULL,
                           p_attribute3                 => NULL,
                           p_attribute4                 => NULL,
                           p_attribute5                 => NULL,
                           p_attribute6                 => NULL,
                           p_attribute7                 => NULL,
                           p_attribute8                 => NULL,
                           p_attribute9                 => NULL,
                           p_attribute10                => NULL,
                           p_attribute11                => NULL,
                           p_attribute12                => NULL,
                           p_attribute13                => NULL,
                           p_attribute14                => NULL,
                           p_attribute15                => NULL,
                           p_context                    => NULL,
                           p_jtf_note_contexts_tab      => l_jtf_note_contexts_tab
                          );
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || '.create_csi_note',
                         'status = ( ' || x_return_status || ' )'
                        );
      END IF;

      IF NOT x_return_status = okc_api.g_ret_sts_success
      THEN
         okc_api.set_message (g_app_name,
                              'OKS_CSI_NOTES_ERROR');

         RAISE g_exception_halt_validation;
      END IF;


   EXCEPTION
      WHEN g_exception_halt_validation
      THEN

         fnd_file.put_line(fnd_file.log,' Error while creating the csi note: '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         fnd_file.put_line(fnd_file.log,' Error while creating the csi note: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_csi_note;

   -----------*  Procedure get_notes_details *----------
   -- Procedure to get the notes details which need to be
   -- copied from impacted contract to new contract.
   -----------------------------------------------------

   PROCEDURE get_notes_details (
      p_source_object_id         IN       NUMBER,
      x_notes_tbl                OUT NOCOPY jtf_note_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR get_notes_details_cur (
         l_id                       IN       NUMBER
      )
      IS
         SELECT b.jtf_note_id jtf_note_id,
                b.source_object_code source_object_code,
                b.note_status note_status,
                b.note_type note_type,
                b.notes notes,
                b.notes_detail notes_detail
           FROM jtf_notes_vl b
          WHERE b.source_object_id = l_id;

      i   NUMBER := 0;
   BEGIN
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.get_notes_details',
                         'Begin'
                        );
      END IF;

      i := 0;
      l_notes_tbl.DELETE;

      FOR get_notes_details_rec IN get_notes_details_cur (p_source_object_id)
      LOOP
         l_notes_tbl (i).source_object_code :=
                                     get_notes_details_rec.source_object_code;
         l_notes_tbl (i).notes := get_notes_details_rec.notes;
         jtf_notes_pub.writelobtodata (get_notes_details_rec.jtf_note_id,
                                       l_notes_tbl (i).notes_detail
                                      );
         l_notes_tbl (i).note_status := get_notes_details_rec.note_status;
         l_notes_tbl (i).note_type := get_notes_details_rec.note_type;
         i := i + 1;
      END LOOP;

      x_return_status := 'S';
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         fnd_file.put_line(fnd_file.log,' Error while getting the notes details: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END get_notes_details;

   -------*  Function check_acct_not_related *----------
   -- Function to check if bill to contact account is
   -- related to the transfer party accounts and its
   -- related accounts for the contracts org id.
   -----------------------------------------------------

   FUNCTION check_acct_not_related (
       p_party_id                 IN       NUMBER,
       p_acct_id                  IN       NUMBER,
       p_org_id                   IN       NUMBER
    )
       RETURN BOOLEAN
    IS
       l_dummy_var   VARCHAR2 (1);

       CURSOR check_acct_csr
       IS
          SELECT 'x'
            FROM DUAL
           WHERE p_acct_id IN (
                    SELECT ca1.cust_account_id id1
                      FROM hz_cust_accounts ca1,
                           hz_parties party
                     WHERE ca1.party_id = p_party_id
                       AND ca1.party_id = party.party_id
                       AND ca1.status = 'A'
                    UNION
                    SELECT ca2.cust_account_id id1
                      FROM hz_cust_accounts ca2,
                           hz_parties party1
                     WHERE ca2.party_id = party1.party_id
                       AND ca2.cust_account_id IN (
                              SELECT a.related_cust_account_id
                                FROM hz_cust_acct_relate_all a,
                                     hz_cust_accounts b
                               WHERE b.cust_account_id = a.cust_account_id
                                 AND b.party_id = p_party_id
                                 AND b.status = 'A'
                                 AND a.status = 'A'
                                 AND a.org_id = p_org_id)
                       AND ca2.status = 'A');
   BEGIN
       OPEN check_acct_csr;
       FETCH check_acct_csr  INTO l_dummy_var;
       IF check_acct_csr%FOUND
       THEN
          RETURN (FALSE);
          IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
          THEN
           fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_csi_note',
                         'Account = '|| p_acct_id || 'is related to '|| p_party_id );
          END IF;

       ELSE
          RETURN (TRUE);
       END IF;
       CLOSE check_acct_csr;

   EXCEPTION
      WHEN OTHERS
      THEN

          fnd_file.put_line(fnd_file.log,' Error while checking the related accounts : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

   END check_acct_not_related;

   ------------*  Procedure Site_address *--------------
   -- Procedure to get the primary address.
   -----------------------------------------------------

      FUNCTION site_address (
         p_customer_id                       NUMBER,
         p_party_id                          NUMBER,
         p_code                              VARCHAR2,
         p_org_id                            NUMBER
      )
         RETURN NUMBER
      IS
         CURSOR l_address_csr
         IS
             SELECT CS.SITE_USE_ID ID1
            FROM HZ_CUST_SITE_USES_all CS
                ,HZ_PARTY_SITES PS
                ,HZ_CUST_ACCT_SITES_ALL CA
            WHERE PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
            AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
            And Ps.party_id = p_party_id
            And Ca.cust_account_id = p_customer_id
            And Cs.site_use_code = p_code
             AND Ps.identifying_address_flag = 'Y'
             AND cs.status = 'A'
            AND cs.org_id = p_org_id
            ;

         l_site_id   NUMBER;
      BEGIN
         OPEN l_address_csr;

         FETCH l_address_csr
          INTO l_site_id;

         IF l_address_csr%NOTFOUND
         THEN
            CLOSE l_address_csr;

            RETURN (NULL);
         END IF;

         CLOSE l_address_csr;

         RETURN (l_site_id);
      END;

   -------*  Procedure validate_contract_number *-------
   -- Procedure to validate the contract number
   -----------------------------------------------------

   PROCEDURE validate_contract_number (
      p_contract_number_modifier IN       VARCHAR2,
      p_contract_number          IN       VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_dummy_var   VARCHAR2 (1);

      CURSOR l_chr_csr2
      IS
         SELECT 'x'
           FROM okc_k_headers_all_b
          WHERE contract_number = p_contract_number
            AND contract_number_modifier = p_contract_number_modifier;

      l_found       BOOLEAN      := FALSE;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF (    p_contract_number_modifier IS NOT NULL
          AND p_contract_number IS NOT NULL
         )
      THEN
         OPEN l_chr_csr2;

         FETCH l_chr_csr2
          INTO l_dummy_var;

         l_found := l_chr_csr2%FOUND;

         CLOSE l_chr_csr2;
      END IF;

      IF (l_found)
      THEN
         x_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_CONTRACT_EXISTS',
                              'CONTRACT_NUMBER',
                              p_contract_number,
                              'CONTRACT_NUMBER_MODIFIER',
                              p_contract_number_modifier
                             );
      END IF;
   END validate_contract_number;

   -------*  Procedure validate_contract_group *--------
   -- Procedure to validate the contract group
   -----------------------------------------------------

   PROCEDURE validate_contract_group (
      p_group_id                 IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_dummy_var   VARCHAR2 (1) := '1';

      CURSOR l_grpid_csr
      IS
         SELECT 'x'
           FROM okc_k_groups_b
          WHERE     ID = p_group_id
                AND public_yn = 'Y'
             OR user_id = fnd_global.user_id;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF (   p_group_id <> okc_api.g_miss_num
          OR p_group_id IS NOT NULL)
      THEN
         OPEN l_grpid_csr;

         FETCH l_grpid_csr
          INTO l_dummy_var;

         IF l_grpid_csr%NOTFOUND
         THEN
            x_return_status := okc_api.g_ret_sts_error;
            okc_api.set_message (g_app_name,
                                 'OKS_INV_GROUP',
                                 'GROUP_ID',
                                 p_group_id
                                );

            CLOSE l_grpid_csr;
         END IF;

         IF l_grpid_csr%ISOPEN
         THEN
            CLOSE l_grpid_csr;
         END IF;
      END IF;
   END validate_contract_group;

   -----------*  Procedure validate_party_id *----------
   -- Procedure to validate the transfer party id
   -----------------------------------------------------

   PROCEDURE validate_party_id (
      p_party_id                 IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_dummy_var   VARCHAR2 (3);

      CURSOR l_party_csr
      IS
         SELECT 'x'
           FROM hz_parties party
          WHERE EXISTS (SELECT 'x'
                          FROM hz_cust_accounts acct
                         WHERE party.party_id = acct.party_id
                           AND acct.status = 'A')
            AND party.party_id = p_party_id;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF (   p_party_id = okc_api.g_miss_num
          OR p_party_id IS NULL)
      THEN
         x_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name, 'OKS_REQ_PARTY');
      ELSE
         OPEN l_party_csr;

         FETCH l_party_csr
          INTO l_dummy_var;

         IF l_party_csr%NOTFOUND
         THEN
            x_return_status := okc_api.g_ret_sts_error;
            okc_api.set_message (g_app_name,
                                 'OKS_INV_PARTY',
                                 'PARTY_ID',
                                 p_party_id
                                );

            CLOSE l_party_csr;
         END IF;

         IF l_party_csr%ISOPEN
         THEN
            CLOSE l_party_csr;
         END IF;
      END IF;
   END validate_party_id;

   -------*  Procedure validate_billing_contact *-------
   -- Procedure to validate the billing contact
   -----------------------------------------------------

   PROCEDURE validate_billing_contact (
      p_contact_id               IN       NUMBER,
      p_party_id                 IN       NUMBER,
      p_trxn_date                IN       DATE,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_dummy_var   VARCHAR2 (1);

      CURSOR l_cust_ctc_csr
      IS
         SELECT 'x'
           FROM hz_relationships r,
                hz_parties p3,
                hz_parties p2,
                hz_org_contacts oc
          WHERE p2.party_id = r.subject_id
            AND r.relationship_code IN ('CONTACT_OF', 'EMPLOYEE_OF')
            AND r.content_source_type = 'USER_ENTERED'
            AND p3.party_id = r.party_id
            AND oc.party_relationship_id = r.relationship_id
            AND r.object_id = p_party_id
            AND trunc(p_trxn_date) BETWEEN NVL (r.start_date, SYSDATE)
                                AND NVL (r.end_date, SYSDATE)
            AND r.status = 'A'
            AND r.party_id = p_contact_id;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      OPEN l_cust_ctc_csr;
      FETCH l_cust_ctc_csr INTO l_dummy_var;

      IF l_cust_ctc_csr%NOTFOUND
      THEN
         x_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_INV_CONTACT',
                              'CONTACT_ID',
                              p_contact_id,
                              'PARTY_ID',
                              p_party_id
                             );

         CLOSE l_cust_ctc_csr;
      END IF;

      IF l_cust_ctc_csr%ISOPEN
      THEN
         CLOSE l_cust_ctc_csr;
      END IF;
   END validate_billing_contact;



   ---------*  Procedure validate_site_use_id *---------
   -- Procedure to validate the bill to and ship to site
   -- use ids
   -----------------------------------------------------

   FUNCTION validate_site_use_id (
      p_site_use_id              IN       NUMBER,
      p_site_use_code            IN       VARCHAR2,
      p_cust_acct_id             IN       NUMBER,
      p_org_id                   IN       NUMBER
   ) return VARCHAR2
   IS
      l_dummy_var   VARCHAR2 (3) := 'N';

      CURSOR l_site_csr
      IS
         SELECT 'Y'
           FROM hz_cust_site_uses_all a,
                hz_cust_acct_sites_all b
          WHERE a.site_use_id = p_site_use_id
            AND a.site_use_code = p_site_use_code
            AND a.cust_acct_site_id = b.cust_acct_site_id
            AND a.status = 'A'
            AND b.status = 'A'
            AND a.org_id = p_org_id
            AND b.cust_account_id = p_cust_acct_id;

   BEGIN


      OPEN l_site_csr;
      FETCH l_site_csr INTO l_dummy_var;
      CLOSE l_site_csr;

      return(l_dummy_var);

   END validate_site_use_id;

   ---------*  Procedure validate_account_id *----------
   -- Procedure to validate the account id
   -----------------------------------------------------

  FUNCTION validate_account_id (
      p_account_id  NUMBER,
      p_party_id    Number,
      p_org_id      NUMBER
      ) Return Number
   IS
      l_dummy_var   VARCHAR2 (3);
Cursor Check_Acct_Csr Is
SELECT  'Y'
From    HZ_CUST_ACCOUNTS CA1
      , HZ_PARTIES party
WHERE   CA1.party_id = P_party_id
And     CA1. cust_account_id = p_account_id
And     CA1.party_id = party.party_id
And     CA1.status = 'A'

UNION

SELECT  'Y'
FROM    HZ_CUST_ACCOUNTS CA2
      , HZ_CUST_ACCT_RELATE_ALL A
      , HZ_CUST_ACCOUNTS B
WHERE   CA2.cust_account_id = A.RELATED_CUST_ACCOUNT_ID
And     B.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
And     Ca2.cust_account_id = p_account_id
And     B.party_id = p_party_id and B.status = 'A'
And     A.status = 'A'
And     A.org_id = p_org_id
And     CA2.status = 'A';

BEGIN


      IF p_account_id IS NOT NULL THEN
         OPEN Check_Acct_Csr;
         FETCH Check_Acct_Csr INTO l_dummy_var;
         CLOSE Check_Acct_Csr;

         If l_dummy_var = 'Y' then

              return(p_account_id);
         Else
              return(null);
         End if;
      Else
              return(null);
      END IF;

   END validate_account_id;



   Function Get_address
   (P_address_id  Number,
    P_account_id  Number,
    p_party_id  Number,
    P_Site_use  Varchar2,
    P_org_id  Number
    )  Return Number Is
    l_address_valid  Varchar2(1) := 'N';
    l_address_id Number;
    L_valid_account  Number;
    Begin

        If P_account_id Is Not null Then
          L_valid_account := validate_account_id(p_account_id,p_party_id,p_org_id);

          If l_valid_account Is not null and P_address_Id Is not null Then
               l_address_valid := validate_site_use_id
                               (
                                p_site_use_id   => P_address_id,
                                p_site_use_code => P_Site_use,
                                p_cust_acct_id  => p_account_id,
                                p_org_id        => p_org_id
                                );
          End If;

          If l_address_valid <> 'Y' or P_address_Id Is Null Then

               l_address_id :=  site_address(p_account_id,
                                             p_party_id,
                                             P_Site_use,
                                             p_org_id
                                              );


         Else
               l_address_id := P_address_id;

          End If;

               return(l_address_id);

        Else
           Return(Null);
        End If;




    End;

    Function get_modifier(Contract_id  Number) return varchar2 Is
    Cursor l_renewal_csr Is
          SELECT object_chr_id
          FROM okc_operation_instances op
               , okc_class_operations cls
               , okc_subclasses_b sl
               , okc_operation_lines ol
          WHERE ol.subject_chr_id = contract_id
          And   ol.subject_cle_id is null
          And   op.id = ol.oie_id
          AND   op.cop_id = cls.id
          And   cls.cls_code = sl.cls_code
          And   sl.code = 'SERVICE'
          And   cls.opn_code in ('RENEWAL','REN_CON');

    Cursor check_renis_xfd(p_contract_id Number) Is
          Select 'x'
          From   Oks_instance_k_dtls_temp
          Where  contract_id = p_contract_id
          And    new_contract_id is not null;

          l_renewal_id Number;
          l_trf        Varchar2(1);

    Begin

          Open l_renewal_csr;
          Fetch l_renewal_csr into l_renewal_id;
          Close l_renewal_csr;

          If l_renewal_id is not null Then
                Open check_renis_xfd(l_renewal_id);
                Fetch check_renis_xfd into l_trf;
                Close check_renis_xfd;


               If l_trf = 'x' Then
                   return(fnd_profile.value('OKC_CONTRACT_IDENTIFIER'));
               Else
                   return(null);

               End If;
          Else
                   return(null);

          End If;


    End;



   -------*  Procedure create_contract_header *---------
   -- Procedure to create the contract header
   -- which will create records in okc and oks header tables
   -- also will copy the sales credits from impacted
   -- contarct to new contracts.
   ------------------------------------------------------

   PROCEDURE create_contract_header (
      p_api_version              IN       NUMBER,
      p_batch_rules              IN       batch_rules_rec_type,
      p_transfer_date            IN       DATE,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_Data                 OUT NOCOPY VARCHAR2

   )
   IS
      CURSOR get_hdr_details_csr
      IS
         SELECT DISTINCT (temp.new_contract_id) contract_id,
                         temp.contract_id,
                         kh.scs_code hdr_scs,
                         st.ste_code hdr_sts,
                         kh.authoring_org_id hdr_authorg,
                         kh.inv_organization_id hdr_invorg,
                         kh.price_list_id hdr_pl,
                         kh.currency_code hdr_curr,
                         kh.payment_term_id hdr_payment,
                         kh.conversion_type hdr_conv_type,
                         kh.conversion_rate hdr_conv_rate,
                         kh.conversion_rate_date hdr_conv_date,
                         kh.conversion_euro_rate hdr_euro_rate,
                         ks.hold_billing hdr_hold_bill,
                         ks.summary_trx_yn hdr_sum_trx,
                         ks.payment_type hdr_payment_type,
                         ks.inv_trx_type hdr_inv_trx,
                         ks.period_start hdr_period_start,
                         ks.period_type  hdr_period_type,
                         gov.isa_agreement_id agreement_id,
                         (SELECT MIN (temp1.new_start_date)
                            FROM oks_instance_k_dtls_temp temp1
                           WHERE temp1.contract_id = temp.contract_id) hdr_sdate,
                         (SELECT MAX (temp1.new_end_date)
                            FROM oks_instance_k_dtls_temp temp1
                           WHERE temp1.contract_id = temp.contract_id) hdr_edate,
                         kh.contract_number contract_number,
                         kh.contract_number_modifier,
                         get_modifier(temp.contract_id),
                         (SELECT okc_p_util.raw_to_number (SYS_GUID ())
                          FROM okc_k_headers_all_b  where id = contract_id ) oks_id,
                          ks.price_uom

                    FROM okc_k_headers_all_b kh,
                         oks_k_headers_b ks,
                         oks_instance_k_dtls_temp temp,
                         okc_statuses_b st,
                         okc_governances gov
                   WHERE kh.ID = temp.contract_id
                     AND temp.new_contract_id is not null
                     AND st.code = kh.sts_code
                     AND ks.chr_id(+) = kh.ID
                     AND gov.chr_id(+) = kh.ID
                     AND gov.dnz_chr_id(+) = kh.ID;

      CURSOR get_hdr_salescredits_csr
      IS
         SELECT DISTINCT (temp.new_contract_id),
                         sc.ctc_id,
                         sc.sales_credit_type_id1,
                         sc.PERCENT,
                         sc.sales_group_id
                    FROM oks_k_sales_credits_v sc,
                         oks_instance_k_dtls_temp temp
                   WHERE sc.chr_id = temp.contract_id
                     AND sc.cle_id IS NULL
                     AND temp.new_contract_id IS NOT NULL;

      CURSOR get_hdr_access_csr
      IS
         SELECT DISTINCT (temp.new_contract_id),
                         ac.GROUP_ID,
                         ac.resource_id,
                         ac.access_level
                    FROM okc_k_accesses_v ac,
                         oks_instance_k_dtls_temp temp
                   WHERE chr_id = temp.contract_id;

      CURSOR l_app_csr (
         p_scs_code                          VARCHAR2
      )
      IS
         SELECT application_id
           FROM okc_classes_b cls,
                okc_subclasses_b scs
          WHERE cls.code = scs.cls_code
            AND scs.code = p_scs_code;

     --Territory changes
     CURSOR Salesrep_details(p_resource_id number, p_org_id Number) IS
           SELECT Salesrep_id
           FROM   jtf_rs_salesreps Sales
           WHERE  sales.resource_id = P_resource_id
           And    sales.org_id = p_org_id;

     --Check for vendor object_code
     CURSOR object_code_csr( p_code VARCHAR2 ) IS
               SELECT 'x'
                 FROM okc_contact_sources_v
                WHERE cro_code = p_code
                  AND buy_or_sell = 'S'
                  AND rle_code = 'VENDOR'
                  AND jtot_object_code = 'OKX_SALEPERS';
     Cursor l_ste_csr(p_sts_code varchar2) Is
            Select ste_code
            From   okc_statuses_b
            WHere  code = p_sts_code;

     Cursor l_warranty_csr(p_hdr_Id Number) Is
            Select lse_id
            From   Okc_k_lines_b kl
            Where  chr_id = p_hdr_id
            And    lse_id in (1,19,14);




      hdr_id                         okc_datatypes.numbertabtyp;
      old_contract_id                okc_datatypes.numbertabtyp;

      hdr_inv_org_id                 okc_datatypes.numbertabtyp;
      hdr_sts_code                   okc_datatypes.var30tabtyp;
      hdr_qcl_id                     okc_datatypes.numbertabtyp;
      hdr_scs_code                   okc_datatypes.var30tabtyp;
      hdr_contract_number            okc_datatypes.var120tabtyp;
      hdr_currency_code              okc_datatypes.var15tabtyp;
      hdr_contract_number_modifier   okc_datatypes.var120tabtyp;
      hdr_short_description          okc_datatypes.var600tabtyp;
      hdr_start_date                 okc_datatypes.datetabtyp;
      hdr_end_date                   okc_datatypes.datetabtyp;
      hdr_date_renewed               okc_datatypes.datetabtyp;
      hdr_authoring_org_id           okc_datatypes.numbertabtyp;
      hdr_price_list_id              okc_datatypes.numbertabtyp;
      hdr_conversion_type            okc_datatypes.var30tabtyp;
      hdr_conversion_rate            okc_datatypes.numbertabtyp;
      hdr_conversion_rate_date       okc_datatypes.datetabtyp;
      hdr_conversion_euro_rate       okc_datatypes.numbertabtyp;
      hdr_cust_acct_id               okc_datatypes.number15tabtyp;
      hdr_bill_to_site_use_id        okc_datatypes.number15tabtyp;
      hdr_inv_rule_id                okc_datatypes.number15tabtyp;
      hdr_renewal_type_code          okc_datatypes.var30tabtyp;
      hdr_ship_to_site_use_id        okc_datatypes.number15tabtyp;
      hdr_payment_term_id            okc_datatypes.number15tabtyp;
      hdr_hold_bill                  okc_datatypes.var3tabtyp;
      hdr_sum_trx                    okc_datatypes.var3tabtyp;
      hdr_payment_type               okc_datatypes.var3tabtyp;
      hdr_inv_trx                    okc_datatypes.var3tabtyp;
      hdr_agreement_id               okc_datatypes.numbertabtyp;
      hdr_identifier                 okc_datatypes.var120tabtyp;
      hdr_oks_id                     okc_datatypes.numbertabtyp;
      hdr_period_type                okc_datatypes.var10tabtyp;
      hdr_period_start               okc_datatypes.var30tabtyp;
      ar_interface_yn                okc_datatypes.var30tabtyp;
      renewal_status                 okc_datatypes.var30tabtyp;
      Accting_rule                   okc_datatypes.numbertabtyp;
      Billing_profile                okc_datatypes.numbertabtyp;
      price_uom                      okc_datatypes.var30tabtyp;
-- Sales credits
      ctc_id                         okc_datatypes.numbertabtyp;
      sales_credit_type_id1          okc_datatypes.var40tabtyp;
      PERCENT                        okc_datatypes.numbertabtyp;
      sales_group_id                 okc_datatypes.numbertabtyp;
-- Access
      resource_id                    okc_datatypes.numbertabtyp;
      groupid                        okc_datatypes.numbertabtyp;
      access_level                   okc_datatypes.var3tabtyp;
      setup_attr                     setup_rec;
      l_return_status                VARCHAR2 (1)                 := 'S';
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2 (2000);
      j                              NUMBER                       := 1;
      k                              NUMBER                       := 1;
      l_third_party_id               NUMBER;
-- plsql tables
      l_khrv_tbl_out                 oks_khr_pvt.khrv_tbl_type;
      l_cpsv_tbl_in                  okc_cps_pvt.cpsv_tbl_type;
      l_chrv_tbl_in                  okc_chr_pvt.chrv_tbl_type;
      l_khrv_tbl_in                  oks_khr_pvt.khrv_tbl_type;
      l_gvev_tbl_in                  okc_gve_pvt.gvev_tbl_type;
      l_cgcv_tbl_in                  okc_cgc_pvt.cgcv_tbl_type;
      l_cpl_tbl_in                   okc_cpl_pvt.cplv_tbl_type;
      l_ctcv_tbl_in                  okc_ctc_pvt.ctcv_tbl_type;
-- Local variables
      l_ren_identifier               VARCHAR2(120);
      l_sts_code                     VARCHAR2 (30);
      l_ste_code                     VARCHAR2 (30);
      l_time                         NUMBER;
      l_valid_billto                 VARCHAR2(1);
      l_valid_shipto                 VARCHAR2(1);
      l_lse_id                       NUMBER;

      l_gen_return_Rec    JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
      l_salesrep_id  Number;
      l_salesgroup_id  Number;
      l_temp  Varchar2(30);

-- Main
   BEGIN

      l_return_status := okc_api.g_ret_sts_success;
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.creat_contract_header',
                         'Begin'
                        );
      END IF;

      l_ren_identifier := fnd_profile.value('OKC_CONTRACT_IDENTIFIER');
      OPEN get_hdr_details_csr;

      FETCH get_hdr_details_csr
      BULK COLLECT INTO hdr_id,
             old_contract_id,
             hdr_scs_code,
             hdr_sts_code,
             hdr_authoring_org_id,
             hdr_inv_org_id,
             hdr_price_list_id,
             hdr_currency_code,
             hdr_payment_term_id,
             hdr_conversion_type,
             hdr_conversion_rate,
             hdr_conversion_rate_date,
             hdr_conversion_euro_rate,
             hdr_hold_bill,
             hdr_sum_trx,
             hdr_payment_type,
             hdr_inv_trx,
             hdr_period_start,
             hdr_period_type,
             hdr_agreement_id,
             hdr_start_date,
             hdr_end_date,
             hdr_contract_number,
             hdr_contract_number_modifier,
             hdr_identifier,
             hdr_oks_id,
             price_uom;

      CLOSE get_hdr_details_csr;

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_header',
                         'Contracts count = (' || hdr_id.COUNT ||')');
      END IF;

      l_chrv_tbl_in.DELETE;
      l_khrv_tbl_in.DELETE;

      If hdr_id.count >0
      THEN
         initialize_okc_hdr_tbl (x_okc_hdr_tbl => l_chrv_tbl_in);
         initialize_oks_hdr_tbl (x_oks_hdr_tbl => l_khrv_tbl_in);
      END IF;
      l_time := 0;
      FOR i IN 1 .. hdr_id.COUNT
      LOOP
      l_valid_shipto := Null;
      l_valid_billto := Null;
          IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
          THEN
             fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'Process Contract id = (' ||i|| '--->'|| hdr_id(i)
                             ||'). Set org context( authoring_org_id ='|| hdr_authoring_org_id(i)
                             ||', org id = '||hdr_inv_org_id (i)|| ')' );
          END IF;
         get_setup_attr (p_party_id           => p_batch_rules.new_party_id,
                         p_org_id             => hdr_authoring_org_id (i),
                         setup_attr           => setup_attr,
                         x_return_status      => l_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data
                        );


         IF NOT l_return_status = okc_api.g_ret_sts_success THEN

                    Raise G_EXCEPTION_HALT_VALIDATION;
         End if;

         OPEN l_app_csr (hdr_scs_code (i));
         FETCH l_app_csr INTO l_chrv_tbl_in (i).application_id;
         CLOSE l_app_csr;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_header',
                         'Application org id = '||l_chrv_tbl_in (i).application_id );
         END IF;

         l_chrv_tbl_in (i).ID                       := hdr_id (i);
         l_chrv_tbl_in (i).document_id              := hdr_id (i);
         l_chrv_tbl_in (i).object_version_number    := 1;
         l_chrv_tbl_in (i).sfwt_flag                := 'N';
         l_chrv_tbl_in (i).chr_id_renewed           := NULL;
         l_chrv_tbl_in (i).chr_id_response          := NULL;
         l_chrv_tbl_in (i).chr_id_award             := NULL;
         l_chrv_tbl_in (i).inv_organization_id      := hdr_inv_org_id (i);
         l_chrv_tbl_in (i).start_date               := hdr_start_date (i);
         l_chrv_tbl_in (i).end_date                 := hdr_end_date (i);
         --l_chrv_tbl_in (i).Date_renewed             := nvl(hdr_date_renewed(i),p_transfer_date);
         l_chrv_tbl_in (i).org_id                   := hdr_authoring_org_id (i);
         l_chrv_tbl_in (i).authoring_org_id         := hdr_authoring_org_id (i);
         l_chrv_tbl_in (i).scs_code                 := hdr_scs_code (i);
         l_chrv_tbl_in (i).price_list_id            := hdr_price_list_id (i);
         l_chrv_tbl_in (i).currency_code            := hdr_currency_code (i);
         l_chrv_tbl_in (i).conversion_type          := hdr_conversion_type (i);
         l_chrv_tbl_in (i).conversion_rate          := hdr_conversion_rate (i);
         l_chrv_tbl_in (i).conversion_rate_date     := hdr_conversion_rate_date (i);
         l_chrv_tbl_in (i).conversion_euro_rate     := hdr_conversion_euro_rate (i);
         l_chrv_tbl_in (i).payment_term_id          := hdr_payment_term_id (i);

         --Fix for Bug 5140969
         Open l_warranty_csr(old_contract_id(i));
         Fetch l_warranty_csr into l_lse_id;
         Close l_warranty_csr;
         If l_lse_id = 14 Then
             l_chrv_tbl_in (i).contract_number := hdr_contract_number (i);
             -- Contract number modifier
             IF p_batch_rules.contract_modifier IS NOT NULL
             THEN
                  l_chrv_tbl_in (i).contract_number_modifier :=
                                          p_batch_rules.contract_modifier  ||':'||
                                          (sysdate+l_time)||' '||to_char(sysdate + l_time,'HH24:MI:SS');
             ELSE

                  l_chrv_tbl_in (i).contract_number_modifier :=
                                          fnd_profile.value('OKS_TRANSFER_CONTRACT_IDENTIFIER')
                                          ||':'||(sysdate+l_time)||' '|| to_char(sysdate + l_time,'HH24:MI:SS');

             END IF;
             ar_interface_yn(i) := 'N';
             renewal_status(i) := 'COMPLETE';
             If trunc(hdr_start_date (i)) > trunc(sysdate) Then
                           l_chrv_tbl_in (i).sts_code    := get_status_code('SIGNED');
             Else
                           l_chrv_tbl_in (i).sts_code    := get_status_code('ACTIVE');
             End If;
             l_chrv_tbl_in (i).date_signed := SYSDATE;
             l_chrv_tbl_in (i).date_approved := SYSDATE;
             Accting_rule(i) := NULL;
             l_chrv_tbl_in (i).inv_rule_id  := NULL;
             l_chrv_tbl_in (i).qcl_id  := Null;
             Billing_profile(i)        := Null;




         Else

              fnd_file.put_line(fnd_file.log,'retain k no'||p_batch_rules.retain_contract_number_flag ||p_batch_rules.contract_modifier );

              IF NVL (p_batch_rules.retain_contract_number_flag, 'N') = 'N'
              THEN
                      okc_contract_pvt.generate_contract_number
                       (p_scs_code             => hdr_scs_code (i),
                        p_modifier             => p_batch_rules.contract_modifier,
                        x_return_status        => l_return_status,
                        x_contract_number      => l_chrv_tbl_in (i).contract_number
                       );

                      IF NOT l_return_status = okc_api.g_ret_sts_success THEN
                            Raise G_EXCEPTION_HALT_VALIDATION;
                      End if;
                     IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                     THEN
                     fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'After generate contract number, status = ('
                             || l_return_status|| '). Contract Number = ('
                             ||l_chrv_tbl_in (i).contract_number || ')');
                     END IF;

                     -- Contract number modifier
                     IF p_batch_rules.contract_modifier IS NOT NULL
                     THEN
                        l_chrv_tbl_in (i).contract_number_modifier :=
                                          Nvl(p_batch_rules.contract_modifier ,fnd_profile.value('OKS_TRANSFER_CONTRACT_IDENTIFIER'))
                                          ||':'|| sysdate ||' '||to_char(sysdate,'HH24:MI:SS');
                     Else
                       l_chrv_tbl_in (i).contract_number_modifier := Null;
                     End If;
             ELSE
                    l_chrv_tbl_in (i).contract_number := hdr_contract_number (i);

                    -- Contract number modifier
                    IF p_batch_rules.contract_modifier IS NOT NULL
                    THEN
                       l_chrv_tbl_in (i).contract_number_modifier :=
                                          Nvl(hdr_identifier (i),p_batch_rules.contract_modifier ) ||':'||
                                          (sysdate+l_time)||' '||to_char(sysdate + l_time,'HH24:MI:SS');
                    ELSE

                       l_chrv_tbl_in (i).contract_number_modifier :=
                                          nvl(hdr_identifier (i),fnd_profile.value('OKS_TRANSFER_CONTRACT_IDENTIFIER'))
                                          ||':'||(sysdate+l_time)||' '|| to_char(sysdate + l_time,'HH24:MI:SS');


                    END IF;
            END IF;
                 IF p_batch_rules.bill_lines_flag = 'R'
                 THEN
                    IF hdr_identifier (i) = l_ren_identifier
                    THEN
                        ar_interface_yn(i) := 'Y';
                    ELSE
                        IF hdr_sts_code(i) = 'ENTERED' Then
                             ar_interface_yn(i) := 'Y';
                        Else
                             ar_interface_yn(i) := 'R';
                        End If;
                    END IF;
                 ELSE
                        ar_interface_yn(i) := p_batch_rules.bill_lines_flag;
                 END IF;
                If get_ste_code(p_batch_rules.contract_status) = 'ENTERED' or hdr_sts_code(i) = 'ENTERED' Then
                    renewal_status(i) := 'DRAFT';
                Else
                    renewal_status(i) := 'COMPLETE';
                End If;
                Accting_rule(i)                      := p_batch_rules.accounting_rule;
                Billing_profile(i)                   := p_batch_rules.billing_profile_id;
                l_chrv_tbl_in (i).inv_rule_id             :=
                                         NVL (p_batch_rules.invoicing_rule,
                                              -2);
                l_chrv_tbl_in (i).qcl_id                   := setup_attr.qcl_id;


               IF hdr_sts_code(i) = 'ENTERED'
               THEN
                  l_chrv_tbl_in (i).sts_code                 := get_status_code('ENTERED');
                  l_chrv_tbl_in (i).date_signed := '';
                  l_chrv_tbl_in (i).date_approved := '';
               ELSE

                  IF get_ste_code(p_batch_rules.contract_status) = 'ACTIVE'
                  THEN
                      If trunc(hdr_start_date (i)) > trunc(sysdate) Then
                           l_chrv_tbl_in (i).sts_code    := get_status_code('SIGNED');
                      Else
                           l_chrv_tbl_in (i).sts_code    := p_batch_rules.contract_status;
                      End If;
                      l_chrv_tbl_in (i).date_signed := SYSDATE;
                      l_chrv_tbl_in (i).date_approved := SYSDATE;
                  ELSE
                      l_chrv_tbl_in (i).sts_code                 := p_batch_rules.contract_status;
                      l_chrv_tbl_in (i).date_signed := '';
                      l_chrv_tbl_in (i).date_approved := '';
                  END IF;
               END IF;
           End If;


         l_time := l_time + 1/(24 * 60 * 60) ;

         fnd_file.put_line(fnd_file.log,l_chrv_tbl_in (i).contract_number ||l_chrv_tbl_in (i).contract_number_modifier);
         fnd_file.put_line(fnd_file.log,l_chrv_tbl_in (i).id);
        IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
        THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_header',
                         'After contract Modifier ('
                         || l_chrv_tbl_in (i).contract_number_modifier || ')');
        END IF;

        validate_contract_number
           (p_contract_number_modifier      => l_chrv_tbl_in (i).contract_number_modifier,
            p_contract_number               => l_chrv_tbl_in (i).contract_number,
            x_return_status                 => l_return_status
           );
        fnd_file.put_line(fnd_file.log,'validate_contract_number'||l_return_status);
        IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
        THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_header',
                         'after Validate contract number status = ('
                         || l_return_status || ')');
        END IF;

        l_chrv_tbl_in (i).short_description :=
                    'Transferred from Contract : ' || hdr_contract_number (i)||' '||hdr_contract_number_modifier(i) ;


         l_chrv_tbl_in (i).archived_yn              := 'N';
         l_chrv_tbl_in (i).deleted_yn               := 'N';
         l_chrv_tbl_in (i).cust_po_number_req_yn    := 'N';
         l_chrv_tbl_in (i).buy_or_sell              := 'S';
         l_chrv_tbl_in (i).issue_or_receive         := 'I';
         l_chrv_tbl_in (i).chr_type                 := 'CYA';
         l_chrv_tbl_in (i).template_yn              := 'N';
         l_chrv_tbl_in (i).old_sts_code             := '';
         l_chrv_tbl_in (i).old_ste_code             := '';
         l_chrv_tbl_in (i).new_sts_code             := '';
         l_chrv_tbl_in (i).new_ste_code             := '';
         l_chrv_tbl_in (i).chr_id_renewed_to        := NULL;
         l_chrv_tbl_in (i).pre_pay_req_yn           := '';
         l_chrv_tbl_in (i).cust_po_number           := '';
         l_chrv_tbl_in (i).comments                 := '';
         l_chrv_tbl_in (i).description              := '';
         l_chrv_tbl_in (i).dpas_rating              := NULL;
         l_chrv_tbl_in (i).cognomen                 := '';
         l_chrv_tbl_in (i).template_used            := '';
         l_chrv_tbl_in (i).datetime_cancelled       := '';
         l_chrv_tbl_in (i).auto_renew_days          := NULL;
         l_chrv_tbl_in (i).date_issued              := '';
         l_chrv_tbl_in (i).datetime_responded       := '';
         l_chrv_tbl_in (i).non_response_reason      := '';
         l_chrv_tbl_in (i).non_response_explain     := '';
         l_chrv_tbl_in (i).rfp_type                 := '';
         l_chrv_tbl_in (i).keep_on_mail_list        := '';
         l_chrv_tbl_in (i).set_aside_reason         := '';
         l_chrv_tbl_in (i).set_aside_percent        := NULL;
         l_chrv_tbl_in (i).response_copies_req      := '';
         l_chrv_tbl_in (i).date_close_projected     := '';
         l_chrv_tbl_in (i).datetime_proposed        := '';
         l_chrv_tbl_in (i).date_terminated          := '';
         l_chrv_tbl_in (i).date_renewed             := '';
         l_chrv_tbl_in (i).trn_code                 := '';
         l_chrv_tbl_in (i).estimated_amount         := NULL;
         l_chrv_tbl_in (i).estimated_amount_renewed := NULL;
         l_chrv_tbl_in (i).currency_code_renewed    := '';
         l_chrv_tbl_in (i).upg_orig_system_ref      := '';
         l_chrv_tbl_in (i).upg_orig_system_ref_id   := NULL;
         l_chrv_tbl_in (i).orig_system_source_code  := '';
         l_chrv_tbl_in (i).orig_system_id1          := NULL;
         l_chrv_tbl_in (i).orig_system_reference1   := NULL;
         l_chrv_tbl_in (i).program_id               := NULL;
         l_chrv_tbl_in (i).request_id               := NULL;
         l_chrv_tbl_in (i).program_update_date      := '';
         l_chrv_tbl_in (i).program_application_id   := NULL;
         l_chrv_tbl_in (i).pricing_date             := '';
         l_chrv_tbl_in (i).sign_by_date             := '';
         l_chrv_tbl_in (i).total_line_list_price    := NULL;
         l_chrv_tbl_in (i).user_estimated_amount    := NULL;
         l_chrv_tbl_in (i).governing_contract_yn    := '';
         l_chrv_tbl_in (i).attribute_category       := '';
         l_chrv_tbl_in (i).attribute1               := '';
         l_chrv_tbl_in (i).attribute2               := '';
         l_chrv_tbl_in (i).attribute3               := '';
         l_chrv_tbl_in (i).attribute4               := '';
         l_chrv_tbl_in (i).attribute5               := '';
         l_chrv_tbl_in (i).attribute6               := '';
         l_chrv_tbl_in (i).attribute7               := '';
         l_chrv_tbl_in (i).attribute8               := '';
         l_chrv_tbl_in (i).attribute9               := '';
         l_chrv_tbl_in (i).attribute10              := '';
         l_chrv_tbl_in (i).attribute11              := '';
         l_chrv_tbl_in (i).attribute12              := '';
         l_chrv_tbl_in (i).attribute13              := '';
         l_chrv_tbl_in (i).attribute14              := '';
         l_chrv_tbl_in (i).attribute15              := '';
         l_chrv_tbl_in (i).renewal_type_code        := '';
         l_chrv_tbl_in (i).renewal_notify_to        := NULL;
         l_chrv_tbl_in (i).renewal_end_date         := NULL;
         l_chrv_tbl_in (i).created_by               := fnd_global.user_id;
         l_chrv_tbl_in (i).creation_date            := SYSDATE;
         l_chrv_tbl_in (i).last_updated_by          := fnd_global.user_id;
         l_chrv_tbl_in (i).last_update_date         := SYSDATE;
         l_chrv_tbl_in (i).last_update_login        := fnd_global.login_id;
         l_chrv_tbl_in (i).cust_acct_id             := NULL;
         l_chrv_tbl_in (i).payment_instruction_type := '';

         IF p_batch_rules.bill_address_id Is Not Null Then
            L_valid_billto :=  validate_site_use_id
                               (
                                p_site_use_id   => p_batch_rules.bill_address_id,
                                p_site_use_code => 'BILL_TO',
                                p_cust_acct_id  => p_batch_rules.bill_account_id,
                                p_org_id        => hdr_authoring_org_id (i)
                                );
         End If;
         fnd_file.put_line(fnd_file.log,'l_valid_billto'||l_valid_billto);
         If l_valid_billto <> 'Y' or p_batch_rules.bill_address_id Is Null Then

             l_chrv_tbl_in(i).bill_to_site_use_id := site_address(nvl(p_batch_rules.bill_account_id,p_batch_rules.new_customer_id),
                                                                  p_batch_rules.new_party_id,
                                                                  'BILL_TO',
                                                                  hdr_authoring_org_id (i)
                                                                  );
         Else
             l_chrv_tbl_in(i).bill_to_site_use_id := p_batch_rules.bill_address_id;
         End If;




         IF p_batch_rules.Ship_address_id Is Not Null Then
            L_valid_Shipto :=  validate_site_use_id
                               (
                                p_site_use_id   => p_batch_rules.Ship_address_id,
                                p_site_use_code => 'SHIP_TO',
                                p_cust_acct_id  => p_batch_rules.Ship_account_id,
                                p_org_id        => hdr_authoring_org_id (i)
                                );
         End If;
         fnd_file.put_line(fnd_file.log,'L_valid_Shipto'||L_valid_Shipto);
         If L_valid_Shipto <> 'Y' or p_batch_rules.Ship_address_id Is Null Then

             l_chrv_tbl_in(i).Ship_to_site_use_id := site_address(nvl(p_batch_rules.Ship_account_id
                                                                     ,p_batch_rules.new_customer_id),
                                                                  p_batch_rules.new_party_id,
                                                                  'SHIP_TO',
                                                                  hdr_authoring_org_id (i)
                                                                  );
         Else
             l_chrv_tbl_in(i).Ship_to_site_use_id := p_batch_rules.Ship_address_id;
         End If;



         -- Assigning records for okS_k_headers_b
         l_khrv_tbl_in (i).ID := hdr_oks_id(i); --okc_p_util.raw_to_number (SYS_GUID ());
         l_khrv_tbl_in (i).chr_id := hdr_id (i);
         l_khrv_tbl_in (i).summary_trx_yn := hdr_sum_trx (i);
         l_khrv_tbl_in (i).hold_billing := hdr_hold_bill (i);
         l_khrv_tbl_in (i).inv_trx_type := hdr_inv_trx (i);

--      l_khrv_tbl_in (1).est_rev_percent         :=
--      l_khrv_tbl_in (1).est_rev_date            := p_header_rec.est_rev_date;
         fnd_file.put_line(fnd_file.log,'setup_attr.pdf_id ***'||setup_attr.pdf_id );

         -- create wf process
         IF setup_attr.pdf_id IS NOT NULL and l_lse_id <> 14
         THEN
            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
             fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'Inside pdf assignment');
            END IF;

            l_cpsv_tbl_in (i).ID                     := okc_p_util.raw_to_number (SYS_GUID ());
            l_cpsv_tbl_in (i).chr_id                 := hdr_id (i);
            l_cpsv_tbl_in (i).pdf_id                 := setup_attr.pdf_id;
            l_cpsv_tbl_in (i).user_id                := fnd_global.user_id;
            l_cpsv_tbl_in (i).created_by             := fnd_global.user_id;
            l_cpsv_tbl_in (i).creation_date          := SYSDATE;
            l_cpsv_tbl_in (i).last_updated_by        := fnd_global.user_id;
            l_cpsv_tbl_in (i).last_update_date       := SYSDATE;
            l_cpsv_tbl_in (i).object_version_number  := 1;
            l_cpsv_tbl_in (i).crt_id                 := NULL;
            l_cpsv_tbl_in (i).process_id             := NULL;
            l_cpsv_tbl_in (i).in_process_yn          := '';
            l_cpsv_tbl_in (i).attribute_category     := '';
            l_cpsv_tbl_in (i).attribute1             := '';
            l_cpsv_tbl_in (i).attribute2             := '';
            l_cpsv_tbl_in (i).attribute3             := '';
            l_cpsv_tbl_in (i).attribute4             := '';
            l_cpsv_tbl_in (i).attribute5             := '';
            l_cpsv_tbl_in (i).attribute6             := '';
            l_cpsv_tbl_in (i).attribute7             := '';
            l_cpsv_tbl_in (i).attribute8             := '';
            l_cpsv_tbl_in (i).attribute9             := '';
            l_cpsv_tbl_in (i).attribute10            := '';
            l_cpsv_tbl_in (i).attribute11            := '';
            l_cpsv_tbl_in (i).attribute12            := '';
            l_cpsv_tbl_in (i).attribute13            := '';
            l_cpsv_tbl_in (i).attribute14            := '';
            l_cpsv_tbl_in (i).attribute15            := '';
            l_cpsv_tbl_in (i).last_update_login      := fnd_global.login_id;
         END IF;
         -- create contract group
         IF setup_attr.cgp_new_id IS NOT NULL
         THEN

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
             fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'Inside contract group assignment');
            END IF;

            l_cgcv_tbl_in (i).ID                     := okc_p_util.raw_to_number (SYS_GUID ());
            l_cgcv_tbl_in (i).cgp_parent_id          := setup_attr.cgp_new_id;
            l_cgcv_tbl_in (i).included_chr_id        := hdr_id (i);
            l_cgcv_tbl_in (i).object_version_number  := 1;
            l_cgcv_tbl_in (i).scs_code               := hdr_scs_code (i);
            l_cgcv_tbl_in (i).created_by             := fnd_global.user_id;
            l_cgcv_tbl_in (i).creation_date          := SYSDATE;
            l_cgcv_tbl_in (i).last_updated_by        := fnd_global.user_id;
            l_cgcv_tbl_in (i).last_update_date       := SYSDATE;
            l_cgcv_tbl_in (i).last_update_login      := fnd_global.login_id;
         END IF;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_header',
                         'Party roles assignment, Vendor = '|| hdr_authoring_org_id (i)
                         || 'Customer = '|| p_batch_rules.new_party_id );
         END IF;

         l_cpl_tbl_in (j).ID := okc_p_util.raw_to_number (SYS_GUID ());
         l_cpl_tbl_in (j).object_version_number := 1;
         l_cpl_tbl_in (j).sfwt_flag := 'N';
         l_cpl_tbl_in (j).cpl_id := '';
         l_cpl_tbl_in (j).chr_id := hdr_id (i);
         l_cpl_tbl_in (j).cle_id := '';
         IF hdr_scs_code(i) IN ('WARRANTY' , 'SERVICE' )
         THEN
         l_cpl_tbl_in (j).rle_code := 'VENDOR';
         ELSE
         l_cpl_tbl_in (j).rle_code := 'MERCHANT';
         END IF;
         l_cpl_tbl_in (j).dnz_chr_id := hdr_id (i);
         l_cpl_tbl_in (j).object1_id1 := hdr_authoring_org_id (i);
         l_cpl_tbl_in (j).object1_id2 := '#';
         l_cpl_tbl_in (j).jtot_object1_code := 'OKX_OPERUNIT';
         l_cpl_tbl_in (j).cognomen := '';
         l_cpl_tbl_in (j).code := '';
         l_cpl_tbl_in (j).facility := '';
         l_cpl_tbl_in (j).minority_group_lookup_code := '';
         l_cpl_tbl_in (j).small_business_flag := '';
         l_cpl_tbl_in (j).women_owned_flag := '';
         l_cpl_tbl_in (j).alias := '';
         l_cpl_tbl_in (j).primary_yn := '';
         l_cpl_tbl_in (j).cust_acct_id := '';
         l_cpl_tbl_in (j).bill_to_site_use_id := '';
         l_cpl_tbl_in (j).attribute_category := '';
         l_cpl_tbl_in (j).attribute1 := '';
         l_cpl_tbl_in (j).attribute2 := '';
         l_cpl_tbl_in (j).attribute3 := '';
         l_cpl_tbl_in (j).attribute4 := '';
         l_cpl_tbl_in (j).attribute5 := '';
         l_cpl_tbl_in (j).attribute6 := '';
         l_cpl_tbl_in (j).attribute7 := '';
         l_cpl_tbl_in (j).attribute8 := '';
         l_cpl_tbl_in (j).attribute9 := '';
         l_cpl_tbl_in (j).attribute10 := '';
         l_cpl_tbl_in (j).attribute11 := '';
         l_cpl_tbl_in (j).attribute12 := '';
         l_cpl_tbl_in (j).attribute13 := '';
         l_cpl_tbl_in (j).attribute14 := '';
         l_cpl_tbl_in (j).attribute15 := '';
         l_cpl_tbl_in (j).created_by := fnd_global.user_id;
         l_cpl_tbl_in (j).creation_date := SYSDATE;
         l_cpl_tbl_in (j).last_updated_by := fnd_global.user_id;
         l_cpl_tbl_in (j).last_update_date := SYSDATE;
         l_cpl_tbl_in (j).last_update_login := fnd_global.login_id;
        If l_lse_id <> 14 Then
         If NVL(fnd_profile.value('OKS_USE_JTF'),'NO') = 'YES' Then

         --Vendor Contact Derived from territory Setup
         OKS_EXTWARPRGM_PVT.GET_JTF_RESOURCE (p_authorg_id     => hdr_authoring_org_id (i),
                                p_party_id       => p_batch_rules.new_party_id ,
                                x_winners_rec    => l_gen_return_rec,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_return_status  => l_return_status
                              );
         fnd_file.put_line(fnd_file.log,'GET_JTF_RESOURCE ret status'||l_return_status);
         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  	         -- Setup error
  	        fnd_file.put_line(fnd_file.log,'SEND_NOTIFICATION');

     	          OKS_EXTWARPRGM_PVT.SEND_NOTIFICATION(null, hdr_id (i),'SER');
  	     ELSE


                If l_gen_return_rec.trans_object_id.Count > 0 Then

                       For l_counter in l_gen_return_rec.trans_object_id.FIRST..l_gen_return_Rec.trans_object_id.LAST
                       LOOP
                            l_salesrep_id := Null;
                       fnd_file.put_line(fnd_file.log,'in loop'||l_gen_return_Rec.RESOURCE_ID(l_counter)||'org'||hdr_authoring_org_id (i) );

                            OPEN Salesrep_details(l_gen_return_Rec.RESOURCE_ID(l_counter),hdr_authoring_org_id (i) );
                            FETCH Salesrep_details INTO l_Salesrep_id;
                            CLOSE Salesrep_details;
                            fnd_file.put_line(fnd_file.log,'in loop l_Salesrep_id'||l_Salesrep_id);

                            If l_salesrep_id  is not null Then
                               Exit;
                            End If;
                       End Loop;


                      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT,
                                  'Salesrep ID is : ' ||  l_salesrep_id );
                      END IF;
                      IF l_salesrep_id  Is Null THEN
                          fnd_file.put_line(fnd_file.log,'SEND_NOTIFICATION 1');

                          OKS_EXTWARPRGM_PVT.SEND_NOTIFICATION(null,hdr_id(i) ,'ISP');
                      End If;
                  Else
                          fnd_file.put_line(fnd_file.log,'SEND_NOTIFICATION 2');
                          OKS_EXTWARPRGM_PVT.SEND_NOTIFICATION(null, hdr_id(i),'NRS');
                  END IF;

           END IF;
           fnd_file.put_line(fnd_file.log,'l_salesrep_id value'||l_salesrep_id);
           If l_salesrep_id Is Not Null And fnd_profile.VALUE('OKS_VENDOR_CONTACT_ROLE' ) IS NOT NULL THEN
               l_salesgroup_id := Null;
               fnd_file.put_line(fnd_file.log,'l_salesrep_id not nul');
               l_salesgroup_id := jtf_rs_integration_pub.get_default_sales_group
                                  (p_salesrep_id    => l_salesrep_id,
                                   p_org_id         => hdr_authoring_org_id (i),
                                   p_date           => hdr_start_date (i));


               OPEN object_code_csr( fnd_profile.VALUE('OKS_VENDOR_CONTACT_ROLE' ));
               FETCH object_code_csr INTO l_temp;
               IF object_code_csr%NOTFOUND THEN
                    CLOSE object_code_csr;
                    OKC_API.SET_MESSAGE(
                         g_app_name,
                         g_unexpected_error,
                         g_sqlcode_token,
                         SQLCODE,
                         g_sqlerrm_token,
                         'Wrong vendor contact role assigned'
                     );

                    l_return_status := okc_api.g_ret_sts_error;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
               CLOSE object_code_csr;


               l_ctcv_tbl_in (k).ID := okc_p_util.raw_to_number (SYS_GUID ());
               l_ctcv_tbl_in (k).object_version_number := 1;

               l_ctcv_tbl_in (k).cpl_id := l_cpl_tbl_in (j).ID;

               l_ctcv_tbl_in (k).cro_code := fnd_profile.VALUE('OKS_VENDOR_CONTACT_ROLE' );
               l_ctcv_tbl_in (k).dnz_chr_id := hdr_id (i);
               l_ctcv_tbl_in (k).contact_sequence := 1;
               l_ctcv_tbl_in (k).object1_id1 := l_salesrep_id;
               l_ctcv_tbl_in (k).object1_id2 := '#';
               l_ctcv_tbl_in (k).jtot_object1_code := 'OKX_SALEPERS' ;
               l_ctcv_tbl_in (k).primary_yn := 'N';
               l_ctcv_tbl_in (k).resource_class := '';
               l_ctcv_tbl_in (k).sales_group_id := l_salesgroup_id;

               l_ctcv_tbl_in (k).attribute_category := '';
               l_ctcv_tbl_in (k).attribute1 := '';
               l_ctcv_tbl_in (k).attribute2 := '';
               l_ctcv_tbl_in (k).attribute3 := '';
               l_ctcv_tbl_in (k).attribute4 := '';
               l_ctcv_tbl_in (k).attribute5 := '';
               l_ctcv_tbl_in (k).attribute6 := '';
               l_ctcv_tbl_in (k).attribute7 := '';
               l_ctcv_tbl_in (k).attribute8 := '';
               l_ctcv_tbl_in (k).attribute9 := '';
               l_ctcv_tbl_in (k).attribute10 := '';
               l_ctcv_tbl_in (k).attribute11 := '';
               l_ctcv_tbl_in (k).attribute12 := '';
               l_ctcv_tbl_in (k).attribute13 := '';
               l_ctcv_tbl_in (k).attribute14 := '';
               l_ctcv_tbl_in (k).attribute15 := '';
               l_ctcv_tbl_in (k).created_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).creation_date := SYSDATE;
               l_ctcv_tbl_in (k).last_updated_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).last_update_date := SYSDATE;
               l_ctcv_tbl_in (k).last_update_login := fnd_global.login_id;
               l_ctcv_tbl_in (k).start_date := hdr_start_date (i);
               l_ctcv_tbl_in (k).end_date := hdr_end_date (i);


               K := K + 1;

         End If;
         End If;
End If;

         l_cpl_tbl_in (j + 1).ID := okc_p_util.raw_to_number (SYS_GUID ());
         l_cpl_tbl_in (j + 1).object_version_number := 1;
         l_cpl_tbl_in (j + 1).sfwt_flag := 'N';
         l_cpl_tbl_in (j + 1).cpl_id := '';
         l_cpl_tbl_in (j + 1).chr_id := hdr_id (i);
         l_cpl_tbl_in (j + 1).cle_id := '';
         IF hdr_scs_code(i) IN ('WARRANTY' , 'SERVICE' )
         THEN
         l_cpl_tbl_in (j + 1).rle_code := 'CUSTOMER';
         ELSE
         l_cpl_tbl_in (j + 1).rle_code := 'SUBSCRIBER';
         END IF;
         l_cpl_tbl_in (j + 1).dnz_chr_id := hdr_id (i);
         l_cpl_tbl_in (j + 1).object1_id1 := p_batch_rules.new_party_id;
         l_cpl_tbl_in (j + 1).object1_id2 := '#';
         l_cpl_tbl_in (j + 1).jtot_object1_code := 'OKX_PARTY';
         l_cpl_tbl_in (j + 1).cognomen := '';
         l_cpl_tbl_in (j + 1).code := '';
         l_cpl_tbl_in (j + 1).facility := '';
         l_cpl_tbl_in (j + 1).minority_group_lookup_code := '';
         l_cpl_tbl_in (j + 1).small_business_flag := '';
         l_cpl_tbl_in (j + 1).women_owned_flag := '';
         l_cpl_tbl_in (j + 1).alias := '';
         l_cpl_tbl_in (j + 1).primary_yn := '';
         l_cpl_tbl_in (j + 1).cust_acct_id := '';
         l_cpl_tbl_in (j + 1).bill_to_site_use_id := '';
         l_cpl_tbl_in (j + 1).attribute_category := '';
         l_cpl_tbl_in (j + 1).attribute1 := '';
         l_cpl_tbl_in (j + 1).attribute2 := '';
         l_cpl_tbl_in (j + 1).attribute3 := '';
         l_cpl_tbl_in (j + 1).attribute4 := '';
         l_cpl_tbl_in (j + 1).attribute5 := '';
         l_cpl_tbl_in (j + 1).attribute6 := '';
         l_cpl_tbl_in (j + 1).attribute7 := '';
         l_cpl_tbl_in (j + 1).attribute8 := '';
         l_cpl_tbl_in (j + 1).attribute9 := '';
         l_cpl_tbl_in (j + 1).attribute10 := '';
         l_cpl_tbl_in (j + 1).attribute11 := '';
         l_cpl_tbl_in (j + 1).attribute12 := '';
         l_cpl_tbl_in (j + 1).attribute13 := '';
         l_cpl_tbl_in (j + 1).attribute14 := '';
         l_cpl_tbl_in (j + 1).attribute15 := '';
         l_cpl_tbl_in (j + 1).created_by := fnd_global.user_id;
         l_cpl_tbl_in (j + 1).creation_date := SYSDATE;
         l_cpl_tbl_in (j + 1).last_updated_by := fnd_global.user_id;
         l_cpl_tbl_in (j + 1).last_update_date := SYSDATE;
         l_cpl_tbl_in (j + 1).last_update_login := fnd_global.login_id;

         IF p_batch_rules.bill_contact_id IS NOT NULL
         THEN
            IF check_acct_not_related(p_batch_rules.new_party_id,
                                  p_batch_rules.bill_account_id,
                                  hdr_authoring_org_id (i))
            THEN
               get_party_id (p_cust_id       => p_batch_rules.bill_account_id,
                             x_party_id      => l_third_party_id
                            );
               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING (fnd_log.level_event,
                                 g_module_current || 'oks_mass_update.create_contract_header',
                                 'Billing account not related, create billing contact.'
                                 || l_third_party_id);
               END IF;

               l_cpl_tbl_in (j + 2).ID :=
                                        okc_p_util.raw_to_number (SYS_GUID ());
               l_cpl_tbl_in (j + 2).object_version_number := 1;
               l_cpl_tbl_in (j + 2).sfwt_flag := 'N';
               l_cpl_tbl_in (j + 2).cpl_id := '';
               l_cpl_tbl_in (j + 2).chr_id := hdr_id (i);
               l_cpl_tbl_in (j + 2).cle_id := '';
               l_cpl_tbl_in (j + 2).rle_code := setup_attr.rle_code ; --'THIRD_PARTY';
               l_cpl_tbl_in (j + 2).dnz_chr_id := hdr_id (i);
               l_cpl_tbl_in (j + 2).object1_id1 := l_third_party_id;
               l_cpl_tbl_in (j + 2).object1_id2 := '#';
               l_cpl_tbl_in (j + 2).jtot_object1_code := 'OKX_PARTY';
               l_cpl_tbl_in (j + 2).cognomen := '';
               l_cpl_tbl_in (j + 2).code := '';
               l_cpl_tbl_in (j + 2).facility := '';
               l_cpl_tbl_in (j + 2).minority_group_lookup_code := '';
               l_cpl_tbl_in (j + 2).small_business_flag := '';
               l_cpl_tbl_in (j + 2).women_owned_flag := '';
               l_cpl_tbl_in (j + 2).alias := '';
               l_cpl_tbl_in (j + 2).primary_yn := '';
               l_cpl_tbl_in (j + 2).cust_acct_id := '';
               l_cpl_tbl_in (j + 2).bill_to_site_use_id := '';
               l_cpl_tbl_in (j + 2).attribute_category := '';
               l_cpl_tbl_in (j + 2).attribute1 := '';
               l_cpl_tbl_in (j + 2).attribute2 := '';
               l_cpl_tbl_in (j + 2).attribute3 := '';
               l_cpl_tbl_in (j + 2).attribute4 := '';
               l_cpl_tbl_in (j + 2).attribute5 := '';
               l_cpl_tbl_in (j + 2).attribute6 := '';
               l_cpl_tbl_in (j + 2).attribute7 := '';
               l_cpl_tbl_in (j + 2).attribute8 := '';
               l_cpl_tbl_in (j + 2).attribute9 := '';
               l_cpl_tbl_in (j + 2).attribute10 := '';
               l_cpl_tbl_in (j + 2).attribute11 := '';
               l_cpl_tbl_in (j + 2).attribute12 := '';
               l_cpl_tbl_in (j + 2).attribute13 := '';
               l_cpl_tbl_in (j + 2).attribute14 := '';
               l_cpl_tbl_in (j + 2).attribute15 := '';
               l_cpl_tbl_in (j + 2).created_by := fnd_global.user_id;
               l_cpl_tbl_in (j + 2).creation_date := SYSDATE;
               l_cpl_tbl_in (j + 2).last_updated_by := fnd_global.user_id;
               l_cpl_tbl_in (j + 2).last_update_date := SYSDATE;
               l_cpl_tbl_in (j + 2).last_update_login := fnd_global.login_id;


               l_ctcv_tbl_in (k).ID := okc_p_util.raw_to_number (SYS_GUID ());
               l_ctcv_tbl_in (k).object_version_number := 1;
               l_ctcv_tbl_in (k).cpl_id := l_cpl_tbl_in (j + 2).ID;
               l_ctcv_tbl_in (k).cro_code := 'BILLING';
               l_ctcv_tbl_in (k).dnz_chr_id := hdr_id (i);
               l_ctcv_tbl_in (k).contact_sequence := 1;
               l_ctcv_tbl_in (k).object1_id1 := p_batch_rules.bill_contact_id;
               l_ctcv_tbl_in (k).object1_id2 := '#';
               l_ctcv_tbl_in (k).jtot_object1_code := 'OKX_PCONTACT';
               l_ctcv_tbl_in (k).primary_yn := 'N';
               l_ctcv_tbl_in (k).resource_class := '';
               l_ctcv_tbl_in (k).sales_group_id := NULL;
               l_ctcv_tbl_in (k).attribute_category := '';
               l_ctcv_tbl_in (k).attribute1 := '';
               l_ctcv_tbl_in (k).attribute2 := '';
               l_ctcv_tbl_in (k).attribute3 := '';
               l_ctcv_tbl_in (k).attribute4 := '';
               l_ctcv_tbl_in (k).attribute5 := '';
               l_ctcv_tbl_in (k).attribute6 := '';
               l_ctcv_tbl_in (k).attribute7 := '';
               l_ctcv_tbl_in (k).attribute8 := '';
               l_ctcv_tbl_in (k).attribute9 := '';
               l_ctcv_tbl_in (k).attribute10 := '';
               l_ctcv_tbl_in (k).attribute11 := '';
               l_ctcv_tbl_in (k).attribute12 := '';
               l_ctcv_tbl_in (k).attribute13 := '';
               l_ctcv_tbl_in (k).attribute14 := '';
               l_ctcv_tbl_in (k).attribute15 := '';
               l_ctcv_tbl_in (k).created_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).creation_date := SYSDATE;
               l_ctcv_tbl_in (k).last_updated_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).last_update_date := SYSDATE;
               l_ctcv_tbl_in (k).last_update_login := fnd_global.login_id;
               l_ctcv_tbl_in (k).start_date := hdr_start_date (i);
               l_ctcv_tbl_in (k).end_date := hdr_end_date (i);
               j := j + 3;
            ELSE
               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
                  fnd_log.STRING (fnd_log.level_event,
                                 g_module_current || 'oks_mass_update.create_contract_header',
                                 'Billing account are related, create billing contact.');
               END IF;

               l_ctcv_tbl_in (k).ID := okc_p_util.raw_to_number (SYS_GUID ());
               l_ctcv_tbl_in (k).object_version_number := 1;
               l_ctcv_tbl_in (k).cpl_id := l_cpl_tbl_in (j + 1).ID;
               l_ctcv_tbl_in (k).cro_code := 'BILLING';
               l_ctcv_tbl_in (k).dnz_chr_id := hdr_id (i);
               l_ctcv_tbl_in (k).contact_sequence := 1;
               l_ctcv_tbl_in (k).object1_id1 := p_batch_rules.bill_contact_id;
               l_ctcv_tbl_in (k).object1_id2 := '#';
               l_ctcv_tbl_in (k).jtot_object1_code := 'OKX_PCONTACT';
               l_ctcv_tbl_in (k).primary_yn := 'N';
               l_ctcv_tbl_in (k).resource_class := '';
               l_ctcv_tbl_in (k).sales_group_id := NULL;
               l_ctcv_tbl_in (k).attribute_category := '';
               l_ctcv_tbl_in (k).attribute1 := '';
               l_ctcv_tbl_in (k).attribute2 := '';
               l_ctcv_tbl_in (k).attribute3 := '';
               l_ctcv_tbl_in (k).attribute4 := '';
               l_ctcv_tbl_in (k).attribute5 := '';
               l_ctcv_tbl_in (k).attribute6 := '';
               l_ctcv_tbl_in (k).attribute7 := '';
               l_ctcv_tbl_in (k).attribute8 := '';
               l_ctcv_tbl_in (k).attribute9 := '';
               l_ctcv_tbl_in (k).attribute10 := '';
               l_ctcv_tbl_in (k).attribute11 := '';
               l_ctcv_tbl_in (k).attribute12 := '';
               l_ctcv_tbl_in (k).attribute13 := '';
               l_ctcv_tbl_in (k).attribute14 := '';
               l_ctcv_tbl_in (k).attribute15 := '';
               l_ctcv_tbl_in (k).created_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).creation_date := SYSDATE;
               l_ctcv_tbl_in (k).last_updated_by := fnd_global.user_id;
               l_ctcv_tbl_in (k).last_update_date := SYSDATE;
               l_ctcv_tbl_in (k).last_update_login := fnd_global.login_id;
               l_ctcv_tbl_in (k).start_date := hdr_start_date (i);
               l_ctcv_tbl_in (k).end_date := hdr_end_date (i);
               K := K + 1;
               j := j + 2;
            END IF;
         ELSE
            j := j + 2;
         END IF;



      END LOOP;

      -- Insert into okc tables
      IF l_chrv_tbl_in.COUNT > 0
      THEN
 fnd_file.put_line(fnd_file.log,' insert_row_upg');
         okc_chr_pvt.insert_row_upg (x_return_status      => l_return_status,
                                     p_chrv_tbl           => l_chrv_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_chr_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_chr_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;

         IF l_return_status <> okc_api.g_ret_sts_success
         THEN

            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- Insert into oks tables
      IF l_khrv_tbl_in.COUNT > 0
      THEN

            FORALL i IN hdr_oks_id.FIRST..hdr_oks_id.LAST
                INSERT INTO OKS_K_HEADERS_B(
                  id,
                  chr_id,
                  acct_rule_id,
                  tax_code,
                  billing_profile_id,
                  inv_trx_type,
                  inv_print_profile,
                  ar_interface_yn,
                  hold_billing,
                  summary_trx_yn,
                  object_version_number,
                  period_start,
                  period_type,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  renewal_status,
                  price_uom)
                VALUES (
                  hdr_oks_id (i),
                  hdr_id (i),
                  Accting_rule(i),
                  '',
                   Billing_profile(i),
                  hdr_inv_trx (i),
                  'Y',
                  ar_interface_yn(i),
                  hdr_hold_bill (i),
                  hdr_sum_trx (i),
                  1,
                  hdr_period_start(i),
                  hdr_period_type(i),
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.login_id,
                  renewal_status(i),
                  price_uom(i));

         fnd_file.put_line(fnd_file.log,'(OKS) -> Created oks header table records sucessfully');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'oks_chr_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
      END IF;

      -- create party roles
      IF l_cpl_tbl_in.COUNT > 0
      THEN
         okc_cpl_pvt.insert_row_upg (x_return_status      => l_return_status,
                                     p_cplv_tbl           => l_cpl_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_cpl_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_cpl_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
         IF l_return_status <> okc_api.g_ret_sts_success
         THEN

            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- create party contacts
      IF l_cpl_tbl_in.COUNT > 0
      THEN
         okc_ctc_pvt.insert_row_upg (x_return_status      => x_return_status,
                                     p_ctcv_tbl           => l_ctcv_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_ctc_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_ctc_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
         IF l_return_status <> okc_api.g_ret_sts_success
         THEN

            RAISE g_exception_halt_validation;
         END IF;
      END IF;
/*
      -- insert goverance
      IF l_gvev_tbl_in.COUNT > 0
      THEN
         okc_gve_pvt.insert_row_upg (x_return_status      => x_return_status,
                                     p_gvev_tbl           => l_gvev_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_gve_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_gve_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
         IF x_return_status <> okc_api.g_ret_sts_success
         THEN
            RAISE g_exception_halt_validation;
         END IF;
      END IF;
*/
      -- Insert approval workflow
      IF l_cpsv_tbl_in.COUNT > 0
      THEN
         okc_cps_pvt.insert_row_upg (x_return_status      => l_return_status,
                                     p_cpsv_tbl           => l_cpsv_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_cps_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_cps_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
         IF l_return_status <> okc_api.g_ret_sts_success
         THEN
            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- insert contract group
      IF l_cgcv_tbl_in.COUNT > 0
      THEN
         okc_cgc_pvt.insert_row_upg (x_return_status      => l_return_status,
                                     p_cgcv_tbl           => l_cgcv_tbl_in
                                    );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Call to okc_cgc_pvt.insert_row_upg , status = ( '
                            || l_return_status || ' )');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'okc_cgc_pvt.insert_row_upg, status = ('
                             || l_return_status || ')');
         END IF;
         IF l_return_status <> okc_api.g_ret_sts_success
         THEN

            RAISE g_exception_halt_validation;
         END IF;
      END IF;

      -- insert access
      OPEN get_hdr_access_csr;

      FETCH get_hdr_access_csr
      BULK COLLECT INTO hdr_id,
             groupid,
             resource_id,
             access_level;

      CLOSE get_hdr_access_csr;

      IF hdr_id.COUNT > 0
      THEN
         FORALL i IN 1 .. hdr_id.COUNT
            INSERT INTO okc_k_accesses
                        (ID,
                         chr_id,
                         GROUP_ID,
                         resource_id,
                         access_level,
                         object_version_number,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login
                        )
                 VALUES (okc_p_util.raw_to_number (SYS_GUID ()),
                         hdr_id (i),
                         groupid (i),
                         resource_id (i),
                         access_level (i),
                         1,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id
                        );
         fnd_file.put_line(fnd_file.log,'(OKS) -> Created access sucessfully');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'AFter creating the access for each contract');
         END IF;
      END IF;

      -- insert header sales credits
      OPEN get_hdr_salescredits_csr;

      FETCH get_hdr_salescredits_csr
      BULK COLLECT INTO hdr_id,
             ctc_id,
             sales_credit_type_id1,
             PERCENT,
             sales_group_id;

      CLOSE get_hdr_salescredits_csr;

      IF hdr_id.COUNT > 0
      THEN
         FORALL i IN 1 .. hdr_id.COUNT
            INSERT INTO oks_k_sales_credits
                        (ID,
                         PERCENT,
                         sales_group_id,
                         chr_id,
                         cle_id,
                         ctc_id,
                         sales_credit_type_id1,
                         sales_credit_type_id2,
                         object_version_number,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date
                        )
                 VALUES (okc_p_util.raw_to_number (SYS_GUID ()),
                         PERCENT (i),
                         sales_group_id (i),
                         hdr_id (i),
                         NULL,
                         ctc_id (i),
                         sales_credit_type_id1 (i),
                         '#',
                         1,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE
                        );
         fnd_file.put_line(fnd_file.log,'(OKS) -> Created sales credits sucessfully');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'AFter inserting sales credits for header');
         END IF;

      END IF;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error while creating the contract header : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the contract header : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_contract_header;

   -------*  Procedure create_contract_line *---------
   -- Procedure to create the contract service line
   -- which will create records in okc and oks line tables
   -- will copy the sales credits
   -- instantite/associate the coverage
   -- instantiate the counters
   -- create the events
   ------------------------------------------------------

   PROCEDURE create_contract_line (
      p_api_version              IN       NUMBER,
      p_batch_rules              IN       batch_rules_rec_type,
      p_transfer_date            IN       DATE,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_Data                 OUT NOCOPY VARCHAR2

   )
   IS
      CURSOR get_srv_details_csr
      IS
         SELECT Lines.*,
               CASE
               WHEN (lines.contract_id <>
                       LAG (lines.contract_id) OVER (ORDER BY lines.contract_id,lines.line_no)
                       or LAG (lines.contract_id) OVER (ORDER BY lines.contract_id,lines.line_no) Is null
                     )
               THEN get_Topline_number ('NEW')
               ELSE get_Topline_number ('OLD')
               END  line_number

         from (Select DISTINCT (temp.new_serviceline_id) srvline_id,
                         itm.object1_id1 srv_itm,
                         itm.object1_id2 srv_invorg,
                         itm.jtot_object1_code srv_jtot_code,
                         kl.price_list_id srv_pl,
                         kl.currency_code srv_curr,
                         temp.new_contract_id contract_id,
                         itm.number_of_items no_items,
                         itm.uom_code uom_code,
                         ks.tax_code tax_code,
                         kl.lse_id lse_id,
                         kl.line_renewal_type_code renewal_type,
                         kl.price_unit unit_price,
                         (SELECT MIN (new_start_date)
                            FROM oks_instance_k_dtls_temp temp1
                           WHERE temp1.topline_id = temp.topline_id) new_sdt,
                         (SELECT MAX (new_end_date)
                            FROM oks_instance_k_dtls_temp temp1
                           WHERE temp1.topline_id = temp.topline_id) new_edt,
                         Ks.invoice_text,
                         ks.coverage_id,
                         ks.standard_cov_yn,
                         st.ste_code line_sts,
                         (SELECT okc_p_util.raw_to_number (SYS_GUID ())
                          FROM okc_k_lines_b WHERE id = topline_id) oks_id,
                          topline_id,
                          Ks.price_uom,
                          kh.authoring_org_id,
                          Kl.Line_Number Line_no


                    FROM oks_instance_k_dtls_temp temp,
                         okc_k_lines_b kl,
                         okc_k_items itm,
                         oks_k_lines_v ks,
                         okc_statuses_b st,
                         okc_k_headers_all_b kh
                   WHERE temp.topline_id = kl.ID
                     AND temp.new_serviceline_id IS NOT NULL
                     AND itm.cle_id = kl.ID
                     AND itm.jtot_object1_code IN ('OKX_WARRANTY', 'OKX_SERVICE')
                     AND ks.cle_id(+) = kl.ID
                     AND st.code = kl.sts_code
                     And  Kh.id = kl.dnz_chr_id) lines
                     ;

      CURSOR get_line_salescredits_csr
      IS
         SELECT DISTINCT (temp.new_serviceline_id),
                         temp.new_contract_id,
                         sc.ctc_id,
                         sc.sales_credit_type_id1,
                         sc.PERCENT,
                         sc.sales_group_id
                    FROM oks_k_sales_credits_v sc,
                         oks_instance_k_dtls_temp temp
                   WHERE sc.cle_id = temp.topline_id
                     AND temp.new_serviceline_id IS NOT NULL;



      -- plsql collections
      srvline_id              okc_datatypes.numbertabtyp;
      oldline_id              okc_datatypes.numbertabtyp;
      srv_itm                 okc_datatypes.var40tabtyp;
      srv_invorg              okc_datatypes.var200tabtyp;
      srv_jtot_code           okc_datatypes.var30tabtyp;
      price_uom               okc_datatypes.var30tabtyp;
      srv_pl                  okc_datatypes.numbertabtyp;
      srv_curr                okc_datatypes.var15tabtyp;
      contract_id             okc_datatypes.numbertabtyp;
      number_of_items         okc_datatypes.numbertabtyp;
      uom_code                okc_datatypes.var3tabtyp;
      lse_id                  okc_datatypes.numbertabtyp;
      new_sdt                 okc_datatypes.datetabtyp;
      new_edt                 okc_datatypes.datetabtyp;
      line_date_renewed       okc_datatypes.datetabtyp;
      tax_code                okc_datatypes.numbertabtyp;
      renewal_type            okc_datatypes.var30tabtyp;
      unit_price              okc_datatypes.numbertabtyp;
      srv_inv_text            var2000tabtyp;
      coverage_id             okc_datatypes.numbertabtyp;
      stand_cov_yn            okc_datatypes.var3tabtyp;
      line_number             okc_datatypes.numbertabtyp;
      line_no                 okc_datatypes.numbertabtyp;

      oks_id                  okc_datatypes.numbertabtyp;
      line_sts                okc_datatypes.var30tabtyp;
      l_cimv_tbl_in           okc_cim_pvt.cimv_tbl_type;
      -- Sales credits
      ctc_id                  okc_datatypes.numbertabtyp;
      sales_credit_type_id1   okc_datatypes.var40tabtyp;
      PERCENT                 okc_datatypes.numbertabtyp;
      sales_group_id          okc_datatypes.numbertabtyp;
      org_id                  okc_datatypes.numbertabtyp;
      -- Local Variables
      l_tabsize               NUMBER;
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (2000);
      l_return_status         VARCHAR2 (1)                     := 'S';
      --Coverage
      l_cov_rec               oks_coverages_pub.ac_rec_type;
      l_coverage_id           NUMBER;
      l_ctr_grpid             NUMBER;
      l_ctr_grp_id_template   NUMBER;
      l_ctr_grp_id_instance   NUMBER;
      l_inp_rec               okc_inst_cnd_pub.instcnd_inp_rec;

   -- Main Begin
   BEGIN
      l_return_status := okc_api.g_ret_sts_success;

      l_Tlineno_new := 0;
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'Begin');
      END IF;

      OPEN get_srv_details_csr;

      FETCH get_srv_details_csr
      BULK COLLECT INTO srvline_id,
             srv_itm,
             srv_invorg,
             srv_jtot_code,
             srv_pl,
             srv_curr,
             contract_id,
             number_of_items,
             uom_code,
             tax_code,
             lse_id,
             renewal_type,
             unit_price,
             new_sdt,
             new_edt,
             srv_inv_text,
             coverage_id,
             stand_cov_yn,
             line_sts,
             oks_id,
             Oldline_Id,
             price_uom,
             org_id,
             line_no,
             line_number

             ;

      CLOSE get_srv_details_csr;
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'Impacted lines count = ( ' || srvline_id.COUNT ||')');
      END IF;


      IF srvline_id.count >0
      THEN
      -- create okc lines
      l_tabsize := srvline_id.COUNT;
      FORALL i IN 1 .. l_tabsize
         INSERT INTO okc_k_lines_b
                     (ID,
                      line_number,
                      chr_id,
                      cle_id,
                      dnz_chr_id,
                      display_sequence,
                      sts_code,
                      lse_id,
                      exception_yn,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      price_negotiated,
                      price_level_ind,
                      price_unit,
                      currency_code,
                      last_update_login,
                      start_date,
                      end_date,
                      price_list_id,
                      cust_acct_id,
                      bill_to_site_use_id,
                      inv_rule_id,
                      line_renewal_type_code,
                      ship_to_site_use_id,
                      annualized_factor
                     )
              VALUES (srvline_id (i),
                      line_number (i),
                      contract_id (i),
                      NULL,
                      contract_id (i),
                      1,
                      get_line_status(lse_id(i),new_sdt(i),new_edt(i),line_sts(i),p_batch_rules.contract_status),
                      --DECODE(lse_id(i),14,get_status(new_sdt(i), new_edt(i)),
                      --       DECODE(line_sts(i),'ENTERED',get_status_code('ENTERED'),p_batch_rules.contract_status)),
                      lse_id (i),
                      'N',
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      0,
                      'N',
                      0,
                      srv_curr (i),
                      fnd_global.user_id,
                      new_sdt (i),
                      new_edt (i),
                      srv_pl (i),


validate_account_id(nvl(p_batch_rules.bill_account_id,p_batch_rules.new_customer_id),p_batch_rules.new_party_id,org_id (i)),
                      get_address(p_batch_rules.bill_address_id,
                                       nvl(p_batch_rules.bill_account_id,p_batch_rules.new_customer_id),
                                       p_batch_rules.new_party_id,
                                       'BILL_TO',
                                       org_id (i))
                      ,
                      p_batch_rules.invoicing_rule,
                      renewal_type (i),
                      get_address(p_batch_rules.Ship_address_id,
                                  nvl(p_batch_rules.Ship_account_id,p_batch_rules.new_customer_id),
                                  p_batch_rules.new_party_id,
                                  'SHIP_TO',
                                  org_id (i)),
                      Oks_setup_util_pub.Get_Annualized_Factor(new_sdt(i),
                               new_edt(i),
                               lse_id(i))

                     );
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc line table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'After insert into okc_k_lines_b table ');
      END IF;


      -- insert into okc tl table
      FOR lang_i IN
         okc_util.g_language_code.FIRST .. okc_util.g_language_code.LAST
      LOOP
         FORALL i IN 1 .. l_tabsize
            INSERT INTO okc_k_lines_tl
                        (ID,
                         LANGUAGE,
                         source_lang,
                         sfwt_flag,
                         NAME,
                         item_description,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login
                        )
                 VALUES (srvline_id (i),
                         okc_util.g_language_code (lang_i),
                         okc_util.get_userenv_lang,
                         'N',
                         null,
                         null,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id
                        );
      END LOOP;
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc tl table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'After insert into okc_k_lines_tl table ');
      END IF;

-- create item record in okc_k_items
      FORALL i IN 1 .. l_tabsize
         INSERT INTO okc_k_items
                     (ID,
                      cle_id,
                      --chr_id,
                      cle_id_for,
                      dnz_chr_id,
                      object1_id1,
                      object1_id2,
                      jtot_object1_code,
                      uom_code,
                      exception_yn,
                      number_of_items,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      upg_orig_system_ref,
                      upg_orig_system_ref_id,
                      priced_item_yn,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
              VALUES (okc_p_util.raw_to_number (SYS_GUID ()),
                      srvline_id (i),
                      --contract_id (i),
                      NULL,
                      contract_id (i),
                      srv_itm (i),
                      srv_invorg (i),
                      srv_jtot_code (i),
                      uom_code (i),
                      'N',
                      number_of_items (i),
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.login_id,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL
                     );

      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc item records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'After insert into okc_k_items table ');
      END IF;

      -- create oks line
      FORALL i IN 1 .. l_tabsize
         INSERT INTO oks_k_lines_b
                     (ID,
                      cle_id,
                      dnz_chr_id,
                      acct_rule_id,
                      tax_code,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      coverage_id,
                      standard_cov_yn,
                      price_uom
                     )
              VALUES (oks_id (i),
                      srvline_id (i),
                      contract_id (i),
                      p_batch_rules.accounting_rule,
                      tax_code (i),
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.login_id,
                      coverage_id (i),
                      stand_cov_yn (i),
                      price_uom(i)
                     );

      fnd_file.put_line(fnd_file.log,'(OKS) -> Created oks line table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'After insert into oks_lines table ');
      END IF;
      -- insert invoice text in oks tl table
      FOR lang_i IN
         okc_util.g_language_code.FIRST .. okc_util.g_language_code.LAST
      LOOP
         FORALL i IN 1 .. l_tabsize
            INSERT INTO oks_k_lines_tl
                        (ID,
                         LANGUAGE,
                         source_lang,
                         sfwt_flag,
                         invoice_text,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login
                        )
                 VALUES (oks_id (i),
                         okc_util.g_language_code (lang_i),
                         okc_util.get_userenv_lang,
                         'N',
                         (substr(srv_inv_text(i),1,instr(srv_inv_text(i),':',1,1))|| new_sdt (i)||' - '|| new_edt (i)),
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id
                        );
      END LOOP;

      fnd_file.put_line(fnd_file.log,'(OKS) -> Created oks tl table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'After insert into okc_lines_tl table ');
      END IF;

      OPEN get_line_salescredits_csr;

      FETCH get_line_salescredits_csr
      BULK COLLECT INTO srvline_id,
             contract_id,
             ctc_id,
             sales_credit_type_id1,
             PERCENT,
             sales_group_id;

      CLOSE get_line_salescredits_csr;

      FORALL i IN 1 .. srvline_id.COUNT
            INSERT INTO oks_k_sales_credits
                        (ID,
                         PERCENT,
                         sales_group_id,
                         chr_id,
                         cle_id,
                         ctc_id,
                         sales_credit_type_id1,
                         sales_credit_type_id2,
                         object_version_number,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date
                        )
                 VALUES (okc_p_util.raw_to_number (SYS_GUID ()),
                         PERCENT (i),
                         sales_group_id (i),
                         contract_id (i),
                         srvline_id(i),
                         ctc_id (i),
                         sales_credit_type_id1 (i),
                         '#',
                         1,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE
                        );
         fnd_file.put_line(fnd_file.log,'(OKS) -> Created sales credits sucessfully');

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
              fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_header',
                             'AFter inserting sales credits for header');
         END IF;

      END IF;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error while creating the service lines : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the service lines : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_contract_line;

   -------*  Procedure create_contract_subline *---------
   -- Procedure to create the contract subline
   -- which will create records in okc and oks lines tables
   -- also will create billing schedule for each associated
   -- service line.
   ------------------------------------------------------

   PROCEDURE create_contract_subline (
      p_api_version              IN       NUMBER,
      p_batch_rules              IN       batch_rules_rec_type,
      p_transfer_date            IN       DATE,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_Data                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR get_subline_details_csr
      IS
         SELECT temp.new_subline_id subline_id,
                temp.new_start_date subline_sdate,
                temp.new_end_date subline_edate,
                temp.new_serviceline_id srvline_id,
                temp.new_contract_id contract_id,
                temp.instance_id instance_id,
                itm.number_of_items number_of_items,
                itm.uom_code uom_code,
                kl.lse_id lse_id,
                kl.line_renewal_type_code renewal_type,
                kl.currency_code urr_code,
                kl.price_unit unit_price,
                DECODE(st.ste_code, 'CANCELLED',Negotiated_amount(kl.start_date,kl.end_date,ks.price_uom,kh.period_type,kh.period_start,temp.new_start_date,kl.price_negotiated, kl.currency_code ) ,
                       (temp.amount - kl.price_negotiated)) price_negotiated,
                ks.tax_code tax_code,
                Ks.invoice_text,
                (CASE
                    WHEN (temp.new_serviceline_id <>
                             (LAG (temp.new_serviceline_id) OVER (ORDER BY temp.new_serviceline_id)
                             )
                         )
                       THEN get_line_number ('NEW')
                    ELSE get_line_number ('OLD')
                 END
                ) line_number,
                kl1.start_date srv_sdate,
                kl1.end_date srv_edate,
                st.ste_code subline_sts,
                (SELECT okc_p_util.raw_to_number (SYS_GUID ())
                 FROM okc_k_lines_b WHERE id = subline_id) oks_id,
                 ks.price_uom,
                 ks.toplvl_price_qty,
                 ks.toplvl_uom_code

           FROM oks_instance_k_dtls_temp temp,
                okc_k_lines_b kl,
                okc_k_lines_b kl1,
                okc_k_items itm,
                oks_k_lines_v ks,
                okc_statuses_b st,
                oks_k_headers_b kh
          WHERE temp.subline_id = kl.ID
            AND temp.new_subline_id IS NOT NULL
            AND itm.cle_id = kl.ID
            AND itm.jtot_object1_code IN ('OKX_CUSTPROD')
            AND ks.cle_id(+) = kl.ID
            AND kl1.ID = temp.new_serviceline_id
            AND st.code = kl.sts_code
            And kl.dnz_chr_id = Kh.chr_Id;

      CURSOR get_billfreq_csr (
         p_bf_id                             NUMBER
      )
      IS
         SELECT billing_type,
                INTERVAL,
                interface_offset,
                invoice_offset,
                billing_level
           FROM oks_billing_profiles_b
          WHERE ID = p_bf_id;

      subline_id         okc_datatypes.numbertabtyp;
      subline_sdate      okc_datatypes.datetabtyp;
      subline_edate      okc_datatypes.datetabtyp;
      srvline_id         okc_datatypes.numbertabtyp;
      contract_id        okc_datatypes.numbertabtyp;
      instance_id        okc_datatypes.numbertabtyp;
      number_of_items    okc_datatypes.numbertabtyp;
      uom_code           okc_datatypes.var3tabtyp;
      lse_id             okc_datatypes.numbertabtyp;
      renewal_type       okc_datatypes.var30tabtyp;
      price_uom          okc_datatypes.var30tabtyp;
      toplvl_uom          okc_datatypes.var30tabtyp;

      toplvl_price       okc_datatypes.numbertabtyp;

      line_date_renewed  okc_datatypes.datetabtyp;
      subline_curr       okc_datatypes.var15tabtyp;
      unit_price         okc_datatypes.numbertabtyp;
      tax_code           okc_datatypes.numbertabtyp;
      prod_name          okc_datatypes.var450tabtyp;
      prod_desc          okc_datatypes.var450tabtyp;
      line_number        okc_datatypes.numbertabtyp;
      price_negotiated   okc_datatypes.numbertabtyp;
      srv_sdate          okc_datatypes.datetabtyp;
      srv_edate          okc_datatypes.datetabtyp;
      oks_id             okc_datatypes.numbertabtyp;
      subline_sts        okc_datatypes.var30tabtyp;
      sl_inv_text        var2000tabtyp;
      l_tabsize          NUMBER;
      -- Billing variables
      l_billing_rec      billing_rec_type;
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (2000);
      l_return_status    VARCHAR2 (1)               := 'S';
   BEGIN
      l_return_status := okc_api.g_ret_sts_success;

      l_lineno_new := 0;
      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
          fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_subLine',
                         'Begin');
      END IF;

      x_return_status := 'S';

      OPEN get_subline_details_csr;

      FETCH get_subline_details_csr
      BULK COLLECT INTO subline_id,
             subline_sdate,
             subline_edate,
             srvline_id,
             contract_id,
             instance_id,
             number_of_items,
             uom_code,
             lse_id,
             renewal_type,
             subline_curr,
             unit_price,
             price_negotiated,
             tax_code,
             sl_inv_text,
             line_number,
             srv_sdate,
             srv_edate,
             subline_sts,
             oks_id,
             price_uom,
             toplvl_price,
             toplvl_uom
             ;

      CLOSE get_subline_details_csr;

      IF subline_id.COUNT > 0
      THEN

      l_tabsize := subline_id.COUNT;
      FORALL i IN 1 .. l_tabsize
         INSERT INTO okc_k_lines_b
                     (ID,
                      line_number,
                      --chr_id,
                      cle_id,
                      dnz_chr_id,
                      display_sequence,
                      sts_code,
                      lse_id,
                      exception_yn,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      price_negotiated,
                      price_level_ind,
                      price_unit,
                      currency_code,
                      last_update_login,
                      start_date,
                      end_date,
                      line_renewal_type_code,
                      annualized_factor
                     )
              VALUES (subline_id (i),
                      line_number (i),
                      --contract_id (i),
                      srvline_id (i),
                      contract_id (i),
                      2,
                      get_line_status(lse_id(i),subline_sdate (i),subline_edate (i),subline_sts(i),p_batch_rules.contract_status),
                     -- DECODE(lse_id(i),18,get_status(subline_sdate (i),subline_edate (i)),
                     --        DECODE(subline_sts(i),'ENTERED',get_status_code('ENTERED'),p_batch_rules.contract_status)),
                      lse_id (i),
                      'N',
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      NVL(price_negotiated (i),0),                -- price_negotiated
                      'Y',
                      NVL(unit_price (i),0),                            -- unit price
                      subline_curr (i),
                      fnd_global.user_id,
                      subline_sdate (i),
                      subline_edate (i),
                      renewal_type (i),
                      Oks_setup_util_pub.Get_Annualized_Factor(subline_sdate (i),
                               subline_edate (i),
                               lse_id(i))


                     );
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc line table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'after insert into okc_k_lines table');
      END IF;

      FOR lang_i IN
         okc_util.g_language_code.FIRST .. okc_util.g_language_code.LAST
      LOOP
         FORALL i IN 1 .. l_tabsize
            INSERT INTO okc_k_lines_tl
                        (ID,
                         LANGUAGE,
                         source_lang,
                         sfwt_flag,
                         NAME,
                         item_description,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login
                        )
                 VALUES (subline_id (i),
                         okc_util.g_language_code (lang_i),
                         okc_util.get_userenv_lang,
                         'N',
                         null,
                         null,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id
                        );
      END LOOP;
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc line tl table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'after insert into okc_k_lines_tl table');
      END IF;

      -- create item record in okc_k_items
      FORALL i IN 1 .. l_tabsize
         INSERT INTO okc_k_items
                     (ID,
                      cle_id,
                      --chr_id,
                      cle_id_for,
                      dnz_chr_id,
                      object1_id1,
                      object1_id2,
                      jtot_object1_code,
                      uom_code,
                      exception_yn,
                      number_of_items,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      upg_orig_system_ref,
                      upg_orig_system_ref_id,
                      priced_item_yn,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
              VALUES (okc_p_util.raw_to_number (SYS_GUID ()),
                      subline_id (i),
                      --contract_id (i),
                      NULL,
                      contract_id (i),
                      instance_id (i),
                      '#',
                      'OKX_CUSTPROD',
                      uom_code (i),
                      'N',
                      number_of_items (i),
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL
                     );
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created okc items table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'after insert into okc_k_items table');
      END IF;

      -- create oks line
      FORALL i IN 1 .. l_tabsize
         INSERT INTO oks_k_lines_b
                     (ID,
                      cle_id,
                      dnz_chr_id,
                      tax_code,
                      price_uom,
                      toplvl_price_qty,
                      toplvl_uom_code,
                      object_version_number,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login
                     )
              VALUES (oks_id (i),
                      subline_id (i),
                      contract_id (i),
                      tax_code (i),
                      price_uom(i),
                      toplvl_price(i),
                      toplvl_uom(i),
                      1,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      fnd_global.user_id
                     );
      fnd_file.put_line(fnd_file.log,'(OKS) -> Created oks line table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'after insert into oks_k_lines table');
      END IF;

      FOR lang_i IN
         okc_util.g_language_code.FIRST .. okc_util.g_language_code.LAST
      LOOP
         FORALL i IN 1 .. l_tabsize
            INSERT INTO oks_k_lines_tl
                        (ID,
                         LANGUAGE,
                         source_lang,
                         sfwt_flag,
                         status_text,
                         invoice_text,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login
                        )
                 VALUES (oks_id (i),
                         okc_util.g_language_code (lang_i),
                         okc_util.get_userenv_lang,
                         'N',
                         'Subline created from transfers',
                         (substr(sl_inv_text(i),1,instr(sl_inv_text(i),':',1,3))||subline_sdate(i)||' - '|| subline_edate(i)),
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id
                        );
      END LOOP;

      fnd_file.put_line(fnd_file.log,'(OKS) -> Created oks line tl table records sucessfully');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.create_contract_Line',
                         'after insert into oks_k_lines_tl table');
      END IF;




      END IF;
      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error while creating the sublines : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the sublines : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_contract_subline;



---------* Procedure to Terminate Cancel Header  *-----------
-------------------------------------------------------------

Procedure Teminate_Cancel_Header
(
   p_Contract_status  Varchar2,
   contract_id     Number,
   Hdr_start_date  Date,
   Term_cancel_source Varchar2,
   Termination_reason Varchar2,
   Cancel_reason Varchar2,
   x_return_status  Out NOCOPY Varchar2,
   x_msg_data       Out NOCOPY Varchar2,
   x_msg_count      Out NOCOPY Number
) Is
      --Contract Header
      l_chrv_tbl_in             okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out            okc_contract_pub.chrv_tbl_type;
      l_cancel_date             Date;
      l_term_date               Date;
      l_return_status           Varchar2(1);

Begin
               l_return_status := okc_api.g_ret_sts_success;

               l_chrv_tbl_in.DELETE;

               IF get_ste_code(p_Contract_Status) = 'ENTERED'
               THEN
                  oks_ib_util_pvt.check_termcancel_lines
                                                (p_line_id        => contract_id,
                                                 p_line_type      => 'TL',
                                                 p_txn_type       => 'C',
                                                 x_date           => l_cancel_date
                                                );

                  IF l_cancel_date IS NOT NULL
                  THEN

                     fnd_file.put_line(fnd_file.log,'(OKS) -> Cancel the Header = ( '
                                        || contract_id  ||' ) with date = ( ' || l_cancel_date||' )' );

                     oks_change_status_pvt.Update_header_status(
                               x_return_status      => l_return_status,
                               x_msg_data           => x_msg_data,
                               x_msg_count          => x_msg_count,
                               p_init_msg_list      => 'F',
                               p_id                 => contract_id ,
                               p_new_sts_code       => get_status_code('CANCELLED'),--code fix for bug 6350309
                               p_canc_reason_code   => Cancel_reason, --batch_rules_rec.termination_reason_code,
                               p_old_sts_code       => P_Contract_Status,
                               p_comments           => null,
                               p_term_cancel_source => Term_cancel_source,
                               p_date_cancelled     => l_cancel_date,
                               p_validate_status    => 'N');

                    fnd_file.put_line(fnd_file.log,'(OKS) -> Update contract Header status = ( '
                                       || l_return_status || ' )');

                    IF NOT l_return_status = okc_api.g_ret_sts_success
                    THEN
                       RAISE g_exception_halt_validation;
                    END IF;

                  END IF;
               ELSE
                  oks_ib_util_pvt.check_termcancel_lines
                                                (p_line_id        => Contract_id,
                                                 p_line_type      => 'TL',
                                                 p_txn_type       => 'T',
                                                 x_date           => l_term_date
                                                );

                  IF l_term_date IS NOT NULL
                  THEN
                     l_chrv_tbl_in (1).ID              := contract_id ;
                     l_chrv_tbl_in (1).date_terminated := l_term_date;
                     l_chrv_tbl_in (1).trn_code        := termination_reason;
                     IF trunc(hdr_start_date) <= trunc(sysdate) then

                          If trunc(l_term_date) <= trunc(sysdate) Then
                             l_chrv_tbl_in (1).sts_code    := get_status_code('TERMINATED');
                          End If;
                     End If;

                     fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate the Header ( = '
                                        || contract_id  ||' ) with date = ( ' || l_term_date || ' )');

                     okc_contract_pub.update_contract_header
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_chrv_tbl               => l_chrv_tbl_in,
                                       x_chrv_tbl               => l_chrv_tbl_out
                                      );
                    fnd_file.put_line(fnd_file.log,'(OKS) -> Update contract Header status = ( '
                                       || l_return_status || ' )');

                    IF NOT l_return_status = okc_api.g_ret_sts_success
                    THEN
                       RAISE g_exception_halt_validation;
                    END IF;

                    END IF;
               END IF;
    x_return_status := l_return_status;
    EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error in Teminate_Cancel_Header: '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error in Teminate_Cancel_Header: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

End;




---------* Procedure to Terminate Cancel Top Line *----------
--------------------------------------------------------------
Procedure Teminate_Cancel_Topline
(
   line_status  Varchar2,
   Service_line_id Number,
   contract_id     Number,
   line_start_date  Date,
   Term_cancel_source Varchar2,
   Termination_reason Varchar2,
   Cancel_reason Varchar2,
   x_return_status  Out NOCOPY  Varchar2,
   x_msg_data       Out NOCOPY Varchar2,
   x_msg_count      Out NOCOPY Number
) Is
          --Contract Line Table
      l_clev_tbl_in             okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out            okc_contract_pub.clev_tbl_type;
      l_cancel_date   Date;
      l_term_date     Date;
      l_return_status Varchar2(1);


Begin

              l_clev_tbl_in.DELETE;

               l_return_status := FND_API.G_RET_STS_SUCCESS;

               IF get_ste_code(line_status)= 'ENTERED'
               THEN
                  oks_ib_util_pvt.check_termcancel_lines
                                                 (p_line_id        => Service_line_id,
                                                  p_line_type      => 'SL',
                                                  p_txn_type       => 'C',
                                                  x_date           => l_cancel_date
                                                 );

                  IF l_cancel_date IS NOT NULL
                  THEN

                     fnd_file.put_line(fnd_file.log,'(OKS) -> Cancel the Line = ( '|| Service_line_id
                                        ||' ) with date = ( ' || l_cancel_date ||' )' );

                     oks_change_status_pvt.Update_line_status (
                              x_return_status       => l_return_status,
                              x_msg_data            => x_msg_data,
                              x_msg_count           => x_msg_count,
                              p_init_msg_list       => 'F',
                              p_id                  => contract_id ,
                              p_cle_id              => Service_line_id ,
                              p_new_sts_code        => get_status_code('CANCELLED'),--code fix for bug 6350309
                              p_canc_reason_code    => cancel_reason,--batch_rules_rec.termination_reason_code,
                              p_old_sts_code        => line_status ,
                              p_old_ste_code        => 'ENTERED',
                              p_new_ste_code        => 'CANCELLED',
                              p_term_cancel_source  => Term_cancel_source,
                              p_date_cancelled      => l_cancel_date,
                              p_comments            => NULL,
                              p_validate_status     => 'N') ;

                  IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                     Raise G_EXCEPTION_HALT_VALIDATION;
                  End if;

                  END IF;
               ELSE
                  oks_ib_util_pvt.check_termcancel_lines
                                                 (p_line_id        => Service_line_id,
                                                  p_line_type      => 'SL',
                                                  p_txn_type       => 'T',
                                                  x_date           => l_term_date
                                                 );

                  IF l_term_date IS NOT NULL
                  THEN
                     l_clev_tbl_in (1).ID                 := Service_line_id;
                     l_clev_tbl_in (1).date_terminated    := l_term_date;
                     l_clev_tbl_in (1).trn_code           := Termination_reason;
                     l_clev_tbl_in (1).term_cancel_source := Term_cancel_source;
                     If trunc(line_start_date) <= trunc(sysdate) Then

                          If trunc(l_term_date) <= trunc(sysdate) Then
                              l_clev_tbl_in (1).sts_code     := get_status_code('TERMINATED');
                          End If;

                     End If;
                     fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate the Line = ( '
                                        || Service_line_id ||' ) with date = ( ' || l_term_date ||' )' );

                     okc_contract_pub.update_contract_line
                                      (p_api_version            => l_api_version,
                                       p_init_msg_list          => l_init_msg_list,
                                       p_restricted_update      => okc_api.g_true,
                                       x_return_status          => l_return_status,
                                       x_msg_count              => x_msg_count,
                                       x_msg_data               => x_msg_data,
                                       p_clev_tbl               => l_clev_tbl_in,
                                       x_clev_tbl               => l_clev_tbl_out
                                      );
                     fnd_file.put_line(fnd_file.log,'(OKS) -> Update contract Line status = ( '
                                        || l_return_status ||' )' );

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN

                        RAISE g_exception_halt_validation;
                     END IF;

                  END IF;
               END IF;

               x_return_status := l_return_status;
 EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error in Teminate_Cancel_Topline : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error in Teminate_Cancel_Topline: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );


 End;

PROCEDURE CREATE_COV_BILLSCHD
    (
     P_Contract_status      IN Varchar2,
     p_billing_profile_id   IN NUMBER,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     Termination_reason     IN VARCHAR2,
     P_batch_id             IN Number,
     P_transfer_attachments IN VARCHAR2,
     P_Transfer_Notes       IN VARCHAR2
    )
    IS


    CURSOR get_srv_details_csr(p_contract_id Number)  IS
        Select Distinct temp.new_serviceline_Id
              ,temp.topline_id
              ,line.start_date
              ,line.end_date
              ,ks.coverage_id
              ,ks.standard_cov_yn
              ,ki.object1_id1 srv_itm
              ,St.ste_code
              ,kl.start_date
        From   Oks_instance_k_dtls_temp temp
             , okc_k_lines_b line
             , Okc_k_lines_b Kl
             , oks_k_lines_b Ks
             , Okc_k_items Ki
             , Okc_statuses_b St
        Where  line.id = temp.new_serviceline_id
        And    Kl.Id    = temp.topline_id
        And    Ks.cle_id = line.Id
        And    Ki.cle_id = Line.Id
        And    temp.new_contract_id = p_contract_id
        And    St.code = kl.sts_code;

   Cursor get_contract_csr Is
        Select distinct temp.new_contract_id
               , temp.contract_id
               , kh.authoring_org_id
               , kh.inv_organization_id
               , St.ste_code
               , Ost.ste_code
               ,Decode(kl.lse_id,18,'WARRANTY','OTHERS')
               ,Kh.qcl_id
               ,oKh.start_date
               ,ks.period_start
        From   OKs_instance_k_dtls_temp temp
             , Okc_k_headers_all_b Kh
             , Okc_k_headers_all_b OKH
             , Okc_statuses_b St
             , Okc_statuses_b OSt
             , Okc_k_lines_b Kl
             , Oks_k_headers_b Ks
        Where Kh.Id = temp.new_contract_id
        And   OKH.Id = temp.contract_id
        And   Ks.chr_id = Kh.id
        And   St.code = Kh.sts_code
        And   OSt.code = OKH.sts_code
        And   Kl.dnz_chr_id = temp.contract_id
        And   Kl.Id = temp.subline_id;

  CURSOR get_subline_details_csr(p_contract_id Number)  IS
        Select  temp.new_subline_Id
        From   Oks_instance_k_dtls_temp temp
        Where  temp.new_contract_id = p_contract_id;
      CURSOR get_csi_note_csr (
         p_batch_id                          NUMBER
      )
      IS
         SELECT DESCRIPTION --NAME
           FROM csi_mass_edit_entries_tl
          WHERE source_lang = USERENV ('LANG')
            AND entry_id = p_batch_id
            AND ROWNUM < 2;

      CURSOR l_ctr_csr (
         p_id   NUMBER
      )
      IS
         SELECT counter_group_id
           FROM cs_ctr_associations
          WHERE source_object_id = p_id;

       Cursor get_day_uom_code IS
       select uom_code
       from okc_time_code_units_b
       where tce_code='DAY'
       and quantity=1;


    srvline_id              okc_datatypes.numbertabtyp;
    subline_id              okc_datatypes.numbertabtyp;
    coverage_id             okc_datatypes.numbertabtyp;
    stand_cov_yn            okc_datatypes.var30tabtyp;
    line_status             okc_datatypes.var30tabtyp;
    Contract_status         okc_datatypes.var30tabtyp;
    Old_Contract_status     okc_datatypes.var30tabtyp;
    Contract_Type           okc_datatypes.var30tabtyp;


    srvitm_id               okc_datatypes.numbertabtyp;
    qcl_id                  okc_datatypes.numbertabtyp;

    old_srvline_id          okc_datatypes.numbertabtyp;
    org_id                  okc_datatypes.numbertabtyp;
    organization_id         okc_datatypes.numbertabtyp;
    contract_id             okc_datatypes.numbertabtyp;
    old_contract_id         okc_datatypes.numbertabtyp;
    new_sdt                 okc_datatypes.datetabtyp;
    new_edt                 okc_datatypes.datetabtyp;
    old_hdr_sdt             okc_datatypes.datetabtyp;
    old_line_sdt            okc_datatypes.datetabtyp;
    period_start            okc_datatypes.var30tabtyp;
    qa_contract_id          Number;


    l_rec               OKS_BILLING_PROFILES_PUB.billing_profile_rec;
    l_sll_tbl_out       OKS_BILLING_PROFILES_PUB.stream_level_tbl;
     l_inp_rec               okc_inst_cnd_pub.instcnd_inp_rec;

    l_sll_tbl           OKS_BILL_SCH.streamlvl_tbl;
    l_bil_sch_out_tbl   OKS_BILL_SCH.itembillsch_tbl;
    l_duration          Number;
    l_timeunit          Varchar2(30);
    l_bill_type         Varchar2(1);
    l_invoice_rule_id   Number;
    l_term_date         Date;
    l_cancel_date       Date;
    l_coverage_id       Number;
    l_ctr_grpid         Number;
    l_ctr_grp_id_template Number;
    l_ctr_grp_id_instance Number;
    l_return_status       Varchar2(1);
    G_RAIL_REC           OKS_TAX_UTIL_PVT.ra_rec_type;
    l_tax_inclusive_yn   Varchar2(1);
    l_tax_amount         Number;
    l_msg_tbl            okc_qa_check_pub.msg_tbl_type;
    l                    Number;
    l_count              Number :=1;
    l_ste_code           Varchar2(40);
    l_sts_code           Varchar2(40);
      -- workflow variabled
    l_wf_attributes           oks_wf_k_process_pvt.wf_attr_details;
    m                    Number;

      -- Valiables for notes
      l_jtf_note_id             NUMBER;
      l_jtf_note_contexts_tab   jtf_notes_pub.jtf_note_contexts_tbl_type;
      l_note_details            csi_mass_edit_entries_tl.Description%TYPE;

      l_uom_code         Varchar2(240);
    BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        OPEN get_contract_csr;
        FETCH get_contract_csr
        BULK COLLECT INTO
        Contract_id,
        old_contract_id,
        org_id,
        organization_id,
        Contract_status,
        Old_Contract_status,
        Contract_type,
        Qcl_id,
        old_hdr_sdt,
        Period_start;
        Close get_contract_csr;

        fnd_file.put_line(fnd_file.log,'in cov_bill ');

        For K in Contract_id.first..Contract_id.last
        Loop

            okc_context.set_okc_org_context(org_id(k),organization_id(k));
            OPEN get_srv_details_csr(contract_id(k));
            FETCH get_srv_details_csr
            BULK COLLECT INTO
                  srvline_id,
                  old_srvline_id,
                  new_sdt,
                  new_edt,
                  coverage_id,
                  stand_cov_yn,
                  srvitm_id,
                  line_status,
                  old_line_sdt ;
            CLOSE get_srv_details_csr;

            FOR Line_ctr IN srvline_id.first..srvline_id.last LOOP

                --Create Coverage

                IF     coverage_id (Line_ctr) IS NOT NULL
                   AND NVL (stand_cov_yn (Line_ctr), 'N') = 'N'
                THEN
                     fnd_file.put_line(fnd_file.log,'oldline_id'||old_srvline_id(Line_ctr));
                     fnd_file.put_line(fnd_file.log,'srvline_id'||srvline_id(Line_ctr));
                     fnd_file.put_line(fnd_file.log,'contract_id'||contract_id(k));
                     fnd_file.put_line(fnd_file.log,'org'||okc_context.get_okc_org_id);
                     fnd_file.put_line(fnd_file.log,'organization'||okc_context.get_okc_organization_id);


                     Oks_coverages_pub.create_adjusted_coverage(
                         p_api_version                   => 1.0,
                         p_init_msg_list                 => okc_api.g_false,
                         x_return_status                 => l_return_status,
                         x_msg_count                     => x_msg_count,
                         x_msg_data                      => x_msg_data,
                         p_source_contract_line_id       => old_srvline_id (Line_ctr),
                         p_target_contract_line_id       => srvline_id (Line_ctr),
                        x_Actual_coverage_id            => l_coverage_id
                     );

                     fnd_file.put_line(fnd_file.log,'(OKS) -> Create coverage for line = ( '
                     ||Line_ctr||'-> ' ||srvline_id (Line_ctr)||' ) status = ( '||l_return_status || ' )' );

                     IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                     THEN
                       fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_Line',
                             'create coverage status = ('|| x_return_status || ')');
                     END IF;
                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN

                        RAISE g_exception_halt_validation;
                     Else
                           Update Oks_k_lines_b set coverage_id = l_coverage_id
                           Where cle_id = srvline_id (Line_ctr);
                     END IF;


                  END IF;

                     oks_coverages_pvt.create_k_coverage_ext
                                        (p_api_version           => 1.0,
                                         p_init_msg_list         => okc_api.g_false,
                                         p_src_line_id           => old_srvline_id (Line_ctr),
                                         p_tgt_line_id           => srvline_id (Line_ctr),
                                         x_return_status         => l_return_status,
                                         x_msg_count             => x_msg_count,
                                         x_msg_data              => x_msg_data
                                        );
                     fnd_file.put_line(fnd_file.log,'(OKS) -> Create standard coverage for line = ( '
                               ||Line_ctr||'-> ' ||srvline_id (Line_ctr)||' ) status = ( ' ||l_return_status || ' )' );

                     IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                     THEN
                       fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_Line',
                             'create coverage extension status = ('|| x_return_status || ')');
                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN

                        RAISE g_exception_halt_validation;
                     END IF;


                  l_ctr_grpid := NULL;

                  OPEN l_ctr_csr (srvitm_id (Line_ctr));

                  FETCH l_ctr_csr INTO l_ctr_grpid;
                  CLOSE l_ctr_csr;

                  -- Instantiate Counters
                  IF l_ctr_grpid IS NOT NULL
                  THEN

                     cs_counters_pub.autoinstantiate_counters
                             (p_api_version                    => 1.0,
                              p_init_msg_list                  => okc_api.g_false,
                              p_commit                         => 'F',
                              x_return_status                  => l_return_status,
                              x_msg_count                      => x_msg_count,
                              x_msg_data                       => x_msg_data,
                              p_source_object_id_template      => srvitm_id (Line_ctr),
                              p_source_object_id_instance      => srvline_id (Line_ctr),
                              x_ctr_grp_id_template            => l_ctr_grp_id_template,
                              x_ctr_grp_id_instance            => l_ctr_grp_id_instance
                             );

                         fnd_file.put_line(fnd_file.log,'(OKS) -> Instantiate counters for line = ( '
                                   ||Line_ctr||'-> ' ||srvline_id (Line_ctr)||', '|| srvitm_id (Line_ctr) ||' ) status = ( '||l_return_status || ' )' );

                         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                         THEN
                           fnd_log.STRING (fnd_log.level_event,
                                          g_module_current || 'oks_mass_update.create_contract_Line',
                                          'Instantiate counters status = ('|| l_return_status || ')');
                         END IF;

                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Counter Instantiate (LINE)'
                                   );
                        RAISE g_exception_halt_validation;
                     END IF;

                     -- Instantiate the events
                     l_inp_rec.ins_ctr_grp_id := l_ctr_grp_id_instance;
                     l_inp_rec.tmp_ctr_grp_id := l_ctr_grp_id_template;
                     l_inp_rec.chr_id := contract_id (k);
                     l_inp_rec.cle_id := srvline_id (Line_ctr);
                     l_inp_rec.jtot_object_code := 'OKC_K_LINE';
                     l_inp_rec.inv_item_id := srvitm_id (Line_ctr);
                     okc_inst_cnd_pub.inst_condition
                                          (p_api_version          => 1.0,
                                           p_init_msg_list        => 'T',
                                           x_return_status        => l_return_status,
                                           x_msg_count            => x_msg_count,
                                           x_msg_data             => x_msg_data,
                                           p_instcnd_inp_rec      => l_inp_rec
                                          );

                     fnd_file.put_line(fnd_file.log,'(OKS) -> Instantiate events for line = ( '
                               ||Line_ctr||'-> ' ||srvline_id (Line_ctr)||' ) status = ( '||l_return_status || ' )' );

                     IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                     THEN
                       fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_contract_Line',
                             'create events status = ('|| l_return_status || ')');
                     END IF;

                     IF NOT l_return_status = okc_api.g_ret_sts_success
                     THEN
                        okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Event Instantiate (LINE)'
                                   );
                        RAISE g_exception_halt_validation;
                     END IF;







                --Create Billing Schedule
                fnd_file.put_line(fnd_file.log,'billing Profile'||p_billing_profile_id);
                IF p_billing_profile_id is not null Then
                    l_rec.cle_id := srvline_id(Line_ctr);
                    l_rec.chr_id := contract_id(k);
                    l_rec.billing_profile_id := p_billing_profile_id;
                    l_rec.start_date := new_sdt(Line_ctr);
                    l_rec.end_date := new_edt(Line_ctr);


                    OKS_BILLING_PROFILES_PUB.get_billing_schedule(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_billing_profile_rec => l_rec,
                        x_sll_tbl_out => l_sll_tbl_out,
                        x_return_status => l_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);
                        IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                        THEN
                          fnd_log.STRING (fnd_log.level_event,
                                 g_module_current || 'oks_mass_update.create_billing_schedule',
                                 'get_billing_schedule'|| x_return_status);
                        END IF;
                        IF NOT l_return_status = 'S'
                        THEN

                             RAISE g_exception_halt_validation;
                        END IF;

                       l_sll_tbl(1).cle_id := l_sll_tbl_out(1).cle_id;
                       l_sll_tbl(1).dnz_chr_id := contract_id(k);
                       l_sll_tbl(1).sequence_no := l_sll_tbl_out(1).seq_no;
                       l_sll_tbl(1).start_date := l_sll_tbl_out(1).start_date;
                       l_sll_tbl(1).level_periods := l_sll_tbl_out(1).target_quantity;
                       l_sll_tbl(1).uom_per_period := l_sll_tbl_out(1).duration;
                       l_sll_tbl(1).level_amount := l_sll_tbl_out(1).amount;
                       l_sll_tbl(1).invoice_offset_days := l_sll_tbl_out(1).invoice_offset;
                       l_sll_tbl(1).interface_offset_days := l_sll_tbl_out(1).interface_offset;
                       l_sll_tbl(1).uom_code := l_sll_tbl_out(1).timeunit;
                       l_bill_type           := nvl(l_sll_tbl_out(1).Billing_type,'T');
                       l_invoice_rule_id     := nvl(l_sll_tbl_out(1).Invoice_rule_id,-2);

                End If;
                If p_billing_profile_id is Null OR l_sll_tbl_out.count = 0 THEN

                  If Period_start(k) = 'CALENDAR' Then
	                 Open get_day_uom_code;
	                 Fetch get_day_uom_code into l_uom_code;
	                 Close get_day_uom_code;


                      l_sll_tbl (1).cle_id                := srvline_id(Line_ctr);
                      l_sll_tbl (1).dnz_chr_id            := contract_id(k);
                      l_sll_tbl (1).sequence_no           := 1;
                      l_sll_tbl (1).level_periods         := 1;
                      l_sll_tbl (1).uom_code              := l_uom_code;
                      l_sll_tbl (1).uom_per_period        := new_edt(line_ctr)-new_sdt(line_ctr)+1;
                      l_sll_tbl (1).invoice_offset_days   := 0;
                      l_sll_tbl (1).interface_offset_days := 0;
                      l_sll_tbl (1).level_amount          := null;
                      l_bill_type                         := 'T';
                      l_invoice_rule_id                   := -2;


                  Else
                      okc_time_util_pub.get_duration
                                   (p_start_date         => trunc(new_sdt(Line_ctr)),
                                    p_end_date           => trunc(new_edt(Line_ctr)),
                                    x_duration           => l_duration,
                                    x_timeunit           => l_timeunit,
                                    x_return_status      => l_return_status
                                   );
                       IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                       THEN
                          fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_billing_schedule',
                             'get_duration'|| l_return_status);
                       END IF;
                       IF NOT l_return_status = 'S'
                       THEN

                                RAISE g_exception_halt_validation;
                       END IF;
                      fnd_file.put_line(fnd_file.log,'cle_id'||srvline_id(Line_ctr)||'contract_ctr'||contract_id(k));
                      l_sll_tbl (1).cle_id                := srvline_id(Line_ctr);
                      l_sll_tbl (1).dnz_chr_id             := contract_id(k);
                      l_sll_tbl (1).sequence_no           := 1;
                      l_sll_tbl (1).level_periods         := 1;
                      l_sll_tbl (1).uom_code              := l_timeunit;
                      l_sll_tbl (1).uom_per_period        := l_duration;
                      l_sll_tbl (1).invoice_offset_days   := 0;
                      l_sll_tbl (1).interface_offset_days := 0;
                      l_sll_tbl (1).level_amount          := null;
                      l_bill_type                         := 'T';
                      l_invoice_rule_id                   := -2;
                  End If;
                END IF;

                IF l_sll_tbl.COUNT > 0 THEN


                    OKS_BILL_SCH.create_bill_sch_rules(
                            p_billing_type => l_bill_type,
                            p_sll_tbl => l_sll_tbl,
                            p_invoice_rule_id => l_Invoice_Rule_Id,
                            x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                            x_return_status => l_return_status);

                   fnd_file.put_line(fnd_file.log,'(OKS) -> OKS_BILL_SCH.create_bill_sch_rules:'||l_return_status );

                    IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                    THEN
                      fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.create_billing_schedule',
                             'create_bill_sch_rules'|| x_return_status);
                    END IF;
                    IF NOT l_return_status = 'S'
                    THEN

                        RAISE g_exception_halt_validation;
                    END IF;

                 END IF;
                 l_sll_tbl_out.delete;
                 l_sll_tbl.delete;


             END LOOP; --For Service Lines


            If Contract_type(k) <> 'WARRANTY' THEN

             -- Tax Calculation

               OPEN get_subline_details_csr(contract_id(k));
               FETCH get_subline_details_csr
               BULK COLLECT INTO
                  subline_id;
               CLOSE get_subline_details_csr;

               FOR subline_ctr IN subline_id.first..subline_id.last LOOP

                  l_tax_amount        := 0;
                  G_Rail_rec.Amount   := null;
                    OKS_TAX_UTIL_PVT.Get_Tax
                   (
	           p_api_version      => 1.0,
                   p_init_msg_list    => OKC_API.G_TRUE,
                   p_chr_id           => contract_id(k),
                   p_cle_id           => subline_id(subline_ctr),
                   px_rail_rec        => G_RAIL_REC,
                   x_msg_count	      => x_msg_count,
                   x_msg_data	      => x_msg_data,
                   x_return_status    => l_return_status
                 );

                 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.after_tax',
                      'oks_tax_util_pvt.get_tax(Return status = ' ||l_return_status || ')' );
                 END IF;


                 fnd_file.put_line(fnd_file.log,'(OKS) -> Tax Calculation Status :'||l_return_status );
                 fnd_file.put_line(fnd_file.log,'(OKS) -> Tax Calculation G_RAIL_REC.tax_value :'||G_RAIL_REC.tax_value);

                 l_tax_inclusive_yn   := G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG ;
                 If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'Y' THEN
                     l_tax_amount := 0 ;
                 Else
                     l_tax_amount  := Nvl(G_RAIL_REC.tax_value,0) ;
                 End If;

                 Update oks_k_lines_b
                 set tax_amount = l_tax_amount, tax_inclusive_yn = l_tax_inclusive_yn
                 Where cle_id = subline_id(subline_ctr );

               End loop;

               Forall l in srvline_id.first..srvline_id.last
               Update oks_k_lines_b
               set tax_amount = (select nvl(sum(ks.tax_amount),0) from oks_k_lines_b ks, okc_k_lines_b kl
                                   where kl.cle_id = srvline_id(l) and ks.cle_id = kl.id)
               Where cle_id = srvline_id(l);
               End If;


                           fnd_file.put_line(fnd_file.log,'(OKS) -> Run QA Check, if Batch rules status = ( '
                               || p_contract_status || ' )'|| 'Active');

            -- Run QA Check and launch workflow for entered status contracts
            IF UPPER (P_contract_status) = 'ACTIVE'
            THEN

               If Contract_type(k) <> 'WARRANTY' THEN

                  IF old_contract_status(k) <> 'ENTERED'
                  THEN


                        fnd_file.put_line(fnd_file.log,'(OKS) -> Run QA Check for contract = ( '
                                     || contract_id (k)|| ' ) qcl id = ( '|| qcl_id(k) || ' )');

                        okc_qa_check_pub.execute_qa_check_list
                                          (p_api_version        => 1.0,
                                           p_init_msg_list      => okc_api.g_false,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_qcl_id             => qcl_id(k),
                                           p_chr_id             => contract_id (k),
                                           x_msg_tbl            => l_msg_tbl
                                          );

                         fnd_file.put_line(fnd_file.log,'(OKS) -> Qa check status = ( '
                                     || l_return_status || ' ) qa message count = ( ' || l_msg_tbl.COUNT || ' )');

                         IF l_return_status <> okc_api.g_ret_sts_success
                         THEN
                            x_return_status := l_return_status;
                            RAISE g_exception_halt_validation;
                         END IF;

                         IF l_msg_tbl.COUNT > 0
                         THEN

                            l := l_msg_tbl.FIRST;
                            LOOP

                               IF l_msg_tbl (l).error_status = 'E'
                               THEN
                                 fnd_file.put_line(fnd_file.log,'(OKS) -> qa check failed, contract =  '
                            || l_msg_tbl (l).name);
                                 fnd_file.put_line(fnd_file.log,'(OKS) -> qa check failed, contract =  '
                            || l_msg_tbl (l).description);

                                  EXIT;
                               END IF;

                               EXIT WHEN l = l_msg_tbl.LAST;
                               l := l_msg_tbl.NEXT (l);
                            END LOOP;
                         END IF;

                         IF l_msg_tbl (l).error_status = 'E'
                         THEN
                            qa_contract_id  := contract_id (k);


                            fnd_file.put_line(fnd_file.log,'(OKS) -> qa check failed, contract = ( '
                            || contract_id (k)|| ' ) will be created in Entered status');
                          ELSE
                             qa_contract_id := Null;
                         END IF;
                      ELSE
                            qa_contract_id  := contract_id (k);


                            fnd_file.put_line(fnd_file.log,'(OKS) -> , contract = ( '
                               || contract_id (k) || ' ) will be created in Entered status');

                      END IF; -- status entered
                   ELSE
                           qa_contract_id := null;
                   END IF;


                  IF qa_contract_id Is Not NUll
                      THEN
                             oks_extwarprgm_pvt.get_sts_code ('ENTERED',
                                                NULL,
                                                l_ste_code,
                                                l_sts_code
                                               );

                             UPDATE okc_k_headers_all_b
                             SET sts_code = l_sts_code,
                             date_approved = NULL,
                             date_signed = NULL
                             WHERE ID = qa_contract_id ;

                             /* cgopinee bugfix for 6882512*/
                             /*update status in okc_contacts table*/
                             OKC_CTC_PVT.update_contact_stecode(p_chr_id => qa_contract_id,
   		                                                x_return_status=>l_return_status);

			     IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
				RAISE g_exception_halt_validation;
    			     END IF;


                             UPDATE oks_k_headers_b
                             SET renewal_status= 'DRAFT'
                             WHERE CHR_ID = qa_contract_id ;


                             fnd_file.put_line(fnd_file.log,'(OKS) -> Header status updated to ( '
                                  || l_sts_code ||' ) successfully');


                             UPDATE okc_k_lines_b
                             SET sts_code = l_sts_code
                             WHERE dnz_chr_id = qa_contract_id ;

                             fnd_file.put_line(fnd_file.log,'(OKS) -> Line status updated to ( '
                                  || l_sts_code ||' ) successfully');


                             -- Launch workflow for entered status contracts

                                l_wf_attributes.contract_id       := qa_contract_id ;
                                --l_wf_attributes.contract_number   := Null;
                                --l_wf_attributes.contract_modifier := Null;
                                --l_wf_attributes.process_type      := 'Online';
                                l_wf_attributes.process_type       := 'MANUAL';
                                l_wf_attributes.irr_flag           := 'Y';
                                l_wf_attributes.negotiation_status := 'DRAFT';


                                oks_wf_k_process_pvt.launch_k_process_wf
                                (p_api_version        => 1.0,
                                 p_init_msg_list      => okc_api.g_false,
                                 p_wf_attributes      => l_wf_attributes,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data
                                );
                                fnd_file.put_line(fnd_file.log,'(OKS) -> Lauch workflow process status = ( '
                                     || l_return_status|| ' )');

                               IF l_return_status <> okc_api.g_ret_sts_success
                               THEN
                                   x_return_status := l_return_status;
                                   RAISE g_exception_halt_validation;
                               END IF;

                      END IF;
                   ELSIF UPPER (P_contract_status) = 'ENTERED'
                   THEN


                       IF Contract_type(k) <> 'WARRANTY'
                       THEN


                               l_wf_attributes.contract_id := contract_id (k);
                               --l_wf_attributes.contract_number := Null;
                               --l_wf_attributes.contract_modifier := Null;
                               --l_wf_attributes.process_type := 'Online';
                               l_wf_attributes.process_type       := 'MANUAL';
                               l_wf_attributes.irr_flag           := 'Y';
                               l_wf_attributes.negotiation_status := 'DRAFT';


                               oks_wf_k_process_pvt.launch_k_process_wf
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => okc_api.g_false,
                                          p_wf_attributes      => l_wf_attributes,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => x_msg_count,
                                          x_msg_data           => x_msg_data
                                         );

                               fnd_file.put_line(fnd_file.log,'(OKS) -> Lauch workflow process status = ( '
                                           || k||' )'||l_return_status);

                               IF l_return_status <> okc_api.g_ret_sts_success
                               THEN
                                   x_return_status := l_return_status;
                                          RAISE g_exception_halt_validation;
                               END IF;

                         END IF;

                   END IF;

                   If Contract_type(k) <> 'WARRANTY' THEN

                        -- Copy Attachements
                       IF UPPER (P_transfer_attachments) = 'Y'
                       THEN
                          fnd_file.put_line(fnd_file.log,'(OKS) -> Copy the Attachments to the new contracts');

                             set_attach_session_vars (old_contract_id (k));

                             IF (fnd_attachment_util_pkg.get_atchmt_exists
                                              (l_entity_name      => 'OKC_K_HEADERS_V',
                                               l_pkey1            => to_char(old_contract_id (k)),
                                               l_pkey2            =>  NULL -- l_from_version
                                              ) = 'Y')
                             THEN

                                   fnd_attached_documents2_pkg.copy_attachments
                                   (x_from_entity_name      => 'OKC_K_HEADERS_V',
                                    x_from_pk1_value        => old_contract_id (k),
                                    x_from_pk2_value        => NULL, -- l_from_version,
                                    x_to_entity_name        => 'OKC_K_HEADERS_V',
                                    x_to_pk1_value          => contract_id(k),
                                    x_to_pk2_value          => '0'
                                   );

                                  fnd_file.put_line(fnd_file.log,'(OKS) -> Attachments copied from contract = ( '||old_contract_id (k)
                                  || ' ) to the new contract = ( '|| contract_id (k)||' ) Successfully');

                             END IF;
                       END IF;
                     End If;

                       fnd_file.put_line(fnd_file.log,'(OKS) -> Copy the Notes to the new contracts');

                       OPEN get_csi_note_csr (p_batch_id);
                       FETCH get_csi_note_csr INTO l_note_details;
                       CLOSE get_csi_note_csr;
                       -- Create CSI notes
                       IF l_note_details IS NOT NULL
                       THEN
                                   create_csi_note
                                   (p_source_object_id      => contract_id (k),
                                    p_note                  => l_note_details,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data
                                   );
                                   fnd_file.put_line(fnd_file.log,'(OKS) -> Create IB Note status = ( ' || l_return_status || ' )');
                                   IF NOT l_return_status = okc_api.g_ret_sts_success
                                   THEN
                                        x_return_status := l_return_status;

                                        RAISE g_exception_halt_validation;
                                   END IF;
                       END IF;

                       fnd_file.put_line(fnd_file.log,'(OKS) -> Notes copied from batch Successfully');



                      -- Transfer Notes
                      IF UPPER (P_transfer_notes) = 'Y' and  Contract_type(k) <> 'WARRANTY' THEN


                            get_notes_details (p_source_object_id      => old_contract_id(k),
                                     x_notes_tbl             => l_notes_tbl,
                                     x_return_status         => l_return_status
                                    );
                             fnd_file.put_line(fnd_file.log,'(OKS) -> For Contract = ( '||old_contract_id(k)
                             ||' ) Get Notes details Status = ( ' || l_return_status || ' ) Number of Notes = ( '
                             ||l_notes_tbl.COUNT || ' )');

                             IF NOT l_return_status = okc_api.g_ret_sts_success
                             THEN
                                x_return_status := l_return_status;
                                RAISE g_exception_halt_validation;
                             END IF;

                             IF l_return_status = 'S'
                             THEN
                                IF (l_notes_tbl.COUNT > 0)
                                THEN
                                   FOR m IN l_notes_tbl.FIRST .. l_notes_tbl.LAST
                                   LOOP
                                      jtf_notes_pub.create_note
                                         (p_jtf_note_id                => NULL,
                                          p_api_version                => 1.0,
                                          p_init_msg_list              => 'F',
                                          p_commit                     => 'F',
                                          p_validation_level           => 0,
                                          x_return_status              => l_return_status,
                                          x_msg_count                  => x_msg_count,
                                          x_msg_data                   => x_msg_data,
                                          p_source_object_code         => l_notes_tbl (m).source_object_code,
                                          p_source_object_id           => contract_id(k),
                                          p_notes                      => l_notes_tbl (m).notes,
                                          p_notes_detail               => l_notes_tbl (m).notes_detail,
                                          p_note_status                => l_notes_tbl (m).note_status,
                                          p_note_type                  => l_notes_tbl (m).note_type,
                                          p_entered_by                 => fnd_global.user_id,
                                          p_entered_date               => SYSDATE,
                                          x_jtf_note_id                => l_jtf_note_id,
                                          p_creation_date              => SYSDATE,
                                          p_created_by                 => fnd_global.user_id,
                                          p_last_update_date           => SYSDATE,
                                          p_last_updated_by            => fnd_global.user_id,
                                          p_last_update_login          => fnd_global.login_id,
                                          p_attribute1                 => NULL,
                                          p_attribute2                 => NULL,
                                          p_attribute3                 => NULL,
                                          p_attribute4                 => NULL,
                                          p_attribute5                 => NULL,
                                          p_attribute6                 => NULL,
                                          p_attribute7                 => NULL,
                                          p_attribute8                 => NULL,
                                          p_attribute9                 => NULL,
                                          p_attribute10                => NULL,
                                          p_attribute11                => NULL,
                                          p_attribute12                => NULL,
                                          p_attribute13                => NULL,
                                          p_attribute14                => NULL,
                                          p_attribute15                => NULL,
                                          p_context                    => NULL,
                                          p_jtf_note_contexts_tab      => l_jtf_note_contexts_tab
                                         );

                                         fnd_file.put_line(fnd_file.log,'(OKS) -> Create Notes ( '||m ||' )'|| 'Status = ( '
                                              || l_return_status || ' )');

                                      IF NOT l_return_status = okc_api.g_ret_sts_success
                                      THEN
                                         x_return_status := l_return_status;
                                         RAISE g_exception_halt_validation;
                                      END IF;
                                   END LOOP;
                                END IF;
                             END IF;

                    End If;





        End Loop; -- Contracts
        Forall k in contract_id.first..contract_id.last
        Update oks_k_headers_b
        Set tax_amount = (select Nvl(sum(ks.tax_amount),0) from oks_k_lines_b ks, okc_k_lines_b kl
                          where kl.dnz_chr_id = contract_id(k) and ks.cle_id = kl.id and kl.lse_id in (9,25))
        Where chr_id = contract_id(k);

        x_return_status := l_return_status;
EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         fnd_file.put_line(fnd_file.log,' Error while creating cov,billing schd, tax : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the cov,billing schd, tax : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

END CREATE_COV_BILLSCHD;



   -------*  Procedure terminate_cancel_subline *---------
   -- Procedure to terminate/cancel the subline
   ------------------------------------------------------

   PROCEDURE terminate_subline (
      p_status                   IN       VARCHAR2,
      p_hdr_id                   IN       NUMBER DEFAULT null,
      p_end_date                 IN       DATE DEFAULT SYSDATE,
      p_cle_id                   IN       NUMBER,
      p_termination_date         IN       DATE,
      p_cancellation_date        IN       DATE,
      p_term_flag                IN       VARCHAR2,
      p_terminate_reason         IN       VARCHAR2,
      P_termination_source       IN       VARCHAR2,
      p_suppress_credit          IN       VARCHAR2,
      p_full_credit              IN       VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2
   )
   IS
      l_return_status   VARCHAR2 (1) := 'S';
      l_clev_tbl_in     okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out    okc_contract_pub.clev_tbl_type;
      l_term_date        DATE;
      l_ste_code         VARCHAR2(30);
      l_sts_code         VARCHAR2(30);
      l_term_date_flag   VARCHAR2(1);
      l_msg_data         VARCHAR2(2000);
      l_msg_count        NUMBER;
      l_cancel_reason    VARCHAR2(30);

   BEGIN
      get_sts_code(null ,p_status,l_ste_code,l_sts_code);

      IF p_status = 'ENTERED'
      THEN
         If P_termination_source = 'IBTERMINATE' Then
              l_cancel_reason := 'TERMINATED';
         Else
              l_cancel_reason := 'TRANSFER';
         End If;
         oks_change_status_pvt.Update_line_status (
                              x_return_status       => l_return_status,
                              x_msg_data            => l_msg_data,
                              x_msg_count           => l_msg_count,
                              p_init_msg_list       => 'F',
                              p_id                  => p_hdr_id,
                              p_cle_id              => p_cle_id,
                              p_new_sts_code        => get_status_code('CANCELLED'),--code fix for bug 6350309
                              p_canc_reason_code    => l_cancel_reason,
                              p_old_sts_code        => l_sts_code,
                              p_old_ste_code        => l_ste_code,
                              p_new_ste_code        => 'CANCELLED',
                              p_term_cancel_source  => P_termination_source,
                              p_date_cancelled      => p_cancellation_date,
                              p_comments            => NULL,
                              p_validate_status     => 'N') ;

       If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                 x_return_status := l_return_status;
                 Raise G_EXCEPTION_HALT_VALIDATION;
       End if;

      ELSE




         oks_bill_rec_pub.pre_terminate_cp
                                   (p_calledfrom                => NULL,
                                    p_cle_id                    => p_cle_id,
                                    p_termination_date          => p_termination_date,
                                    p_terminate_reason          => p_terminate_reason,
                                    p_override_amount           => NULL,
                                    p_con_terminate_amount      => NULL,
                                    p_termination_amount        => NULL,
                                    p_suppress_credit           => p_suppress_credit,
                                    p_full_credit               => p_full_credit,
                                    P_Term_Date_flag            => p_term_flag,
                                    P_Term_Cancel_source        => P_termination_source,
                                    x_return_status             => l_return_status
                                   );

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;
      END IF;
      x_return_status  := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := okc_api.g_ret_sts_error;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END terminate_subline;

   ------------*  function get_line_number *-------------
   -- Function to generate the line numbers for service
   -- line as well as sublines
   -- this function is used in the cursor statement
   ------------------------------------------------------

   FUNCTION get_line_number (
      p_type                              VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN
      IF p_type = 'NEW'
      THEN
         l_lineno_new := 0;
      END IF;

      l_lineno_new := l_lineno_new + 1;

      RETURN (l_lineno_new);
   END get_line_number ;


   ------------*  function get_line_number *-------------
   -- Function to generate the line numbers for service
   -- line as well as sublines
   -- this function is used in the cursor statement
   ------------------------------------------------------

   FUNCTION get_Topline_number (
      p_type                              VARCHAR2
   )
      RETURN NUMBER
   IS
   BEGIN


      IF p_type = 'NEW'
      THEN

         l_Tlineno_new := 0;
      END IF;

      l_Tlineno_new := l_Tlineno_new + 1;


      RETURN (l_Tlineno_new);
   END get_Topline_number ;
   ------------*  function get_seq_number *-------------
   -- Function to generate the header and line sequenec
   -- this function is used in the cursor statement
   ------------------------------------------------------

   FUNCTION get_seq_no (
      p_type                              VARCHAR2,
      p_var                               VARCHAR2,
      p_end_date                          DATE
   )
      RETURN NUMBER
   IS
      CURSOR l_seq_csr
      IS
         SELECT okc_k_headers_b_s.NEXTVAL
           FROM DUAL;
   BEGIN

      IF trunc(p_end_date) < trunc(SYSDATE)
      THEN
         RETURN (Null);
      END IF;

      IF p_type = 'H'
      THEN

         IF p_var = 'NEW'
         THEN
            OPEN l_seq_csr;
            FETCH l_seq_csr INTO l_hdr_id;
            CLOSE l_seq_csr;

            RETURN (l_hdr_id);
         ELSE
            RETURN (l_hdr_id);
         END IF;
      ELSIF p_type = 'L'
      THEN

         IF p_var = 'NEW'
         THEN
            l_line_id := okc_p_util.raw_to_number (SYS_GUID ());
            RETURN (l_line_id);
         ELSE
            RETURN (l_line_id);
         END IF;
      ELSE
            RETURN (okc_p_util.raw_to_number (SYS_GUID ()));
      END IF;
   END get_seq_no;

   -----------*  function get_object_line_id *-----------
   -- Function to get the object line id for renewed
   -- contracts
   ------------------------------------------------------

   PROCEDURE get_object_line_id (
      p_line_id                  IN       NUMBER,
      x_object_cle_id            OUT NOCOPY     NUMBER,
      x_object_chr_id            OUT NOCOPY     NUMBER
   )

   IS
      CURSOR get_object_line_csr
      IS
         SELECT object_cle_id, OBJECT_CHR_ID
           FROM okc_operation_instances op,
                okc_operation_lines ol,
                okc_class_operations cls,
                 okc_subclasses_b sl
          WHERE ol.oie_id = op.ID
            AND cls.cls_code = sl.cls_code
           And  sl.code = 'SERVICE'
           And  op.cop_id = cls.id
           And  cls.opn_code in ('RENEWAL','REN_CON')
           AND ol.subject_cle_id = p_line_id;

      CURSOR get_transfer_link_csr (
         p_line_id                           NUMBER
      )
      IS
         SELECT ol.subject_cle_id, ol.subject_chr_id
           FROM okc_operation_instances op,
                okc_operation_lines ol,
                okc_class_operations cls,
                 okc_subclasses_b sl
          WHERE ol.oie_id = op.ID
            AND cls.cls_code = sl.cls_code
           And  sl.code = 'SERVICE'
           And  op.cop_id = cls.id
           And  cls.opn_code in ('TRANSFER')
            AND ol.object_cle_id = p_line_id;

      l_renew_object_id   NUMBER := NULL;
      l_renew_chr_id   NUMBER := NULL;
      l_trf_subject_id    NUMBER := NULL;
      l_trf_subj_chrid  Number := Null;
   BEGIN

      OPEN get_object_line_csr;
      FETCH get_object_line_csr  INTO l_renew_object_id, l_renew_chr_id;

      IF get_object_line_csr%FOUND
      THEN

         OPEN get_transfer_link_csr (l_renew_object_id);
         FETCH get_transfer_link_csr  INTO l_trf_subject_id,l_trf_subj_chrid;
         IF get_transfer_link_csr%FOUND THEN
              x_object_cle_id := l_trf_subject_id;
              x_object_chr_id := l_trf_subj_chrid;
         ELSE
              x_object_cle_id := l_renew_object_id;
              x_object_chr_id := l_renew_chr_id;
         END IF;
         CLOSE get_transfer_link_csr;
      ELSE
          x_object_cle_id := NULL;
          x_object_chr_id := NULL;
      END IF;
      CLOSE get_object_line_csr;

   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line(fnd_file.log,' Error while getting the object line id: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END get_object_line_id;

   -------------*  function get_end_date *---------------
   -- Function to get the end date for installation date
   -- change
   ------------------------------------------------------

   FUNCTION get_end_date (
      p_sdate                    IN       DATE,
      p_edate                    IN       DATE,
      p_ins_date                 IN       DATE
   )
      RETURN DATE
   IS
      l_duration        NUMBER;
      l_timeunits       VARCHAR2 (240);
      l_new_edt         DATE;
      l_return_status   VARCHAR2 (1)   := 'S';
   BEGIN
      okc_time_util_pub.get_duration (p_start_date         => trunc(p_sdate),
                                      p_end_date           => trunc(p_edate),
                                      x_duration           => l_duration,
                                      x_timeunit           => l_timeunits,
                                      x_return_status      => l_return_status
                                     );

      IF NOT l_return_status = 'S'
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      l_new_edt := okc_time_util_pub.get_enddate (p_start_date      => trunc(p_ins_date),
                                                  p_duration        => l_duration,
                                                  p_timeunit        => l_timeunits
                                                 );
      RETURN (l_new_edt);
   END get_end_date;

   FUNCTION get_status (
      p_start_date                        VARCHAR2,
      p_end_date                          VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_ste_code   VARCHAR2 (30);
      l_sts_code   VARCHAR2 (30);
   BEGIN
      IF (p_start_date) > (SYSDATE)
      THEN
         get_sts_code ('SIGNED',
                        NULL,
                        l_ste_code,
                        l_sts_code
                       );
      ELSIF     (p_start_date) <= (SYSDATE)
            AND (p_end_date) >= (SYSDATE)
      THEN
         get_sts_code ('ACTIVE',
                        NULL,
                        l_ste_code,
                        l_sts_code
                       );
      ELSIF (p_end_date) < (SYSDATE)
      THEN
         get_sts_code ('EXPIRED',
                        NULL,
                        l_ste_code,
                        l_sts_code
                       );
      END IF;

      RETURN (l_sts_code);
   END;

   ------------*  function check_relation *-------------
   -- Function to check the relation between transfer
   -- parties
   ------------------------------------------------------

   FUNCTION check_relation (
      p_old_customer             IN       VARCHAR2,
      p_new_customer             IN       VARCHAR2,
      p_transfer_date            IN       DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR l_cust_rel_csr (
         l_old_customer                      VARCHAR2,
         l_new_customer                      VARCHAR2,
         l_relation                          VARCHAR2
      )
      IS
         SELECT DISTINCT relationship_type
                    FROM hz_relationships
                   WHERE (   (    object_id = l_new_customer
                              AND subject_id = l_old_customer
                             )
                          OR (    object_id = l_old_customer
                              AND subject_id = l_new_customer
                             )
                         )
                     AND relationship_type = l_relation
                     AND status = 'A'
                     AND TRUNC (p_transfer_date) BETWEEN TRUNC (start_date)
                                                     AND TRUNC (end_date);

      l_old_party_id        NUMBER;
      l_new_party_id        NUMBER;
      l_relationship_type   VARCHAR2 (40);
      l_relationship        VARCHAR2 (40);
      l_date                DATE;
   BEGIN
      l_relationship_type := fnd_profile.VALUE ('OKS_TRF_PARTY_REL');
      get_party_id (p_new_customer, l_new_party_id);
      get_party_id (p_old_customer, l_old_party_id);

      OPEN l_cust_rel_csr (l_old_party_id,
                           l_new_party_id,
                           l_relationship_type
                          );

      FETCH l_cust_rel_csr
       INTO l_relationship;

      IF l_cust_rel_csr%FOUND
      THEN
         RETURN ('Y');
      ELSE
         RETURN ('N');
      END IF;

      CLOSE l_cust_rel_csr;
   END;

   ------------*  Procedure create_contract *-------------
   -- procedure to create contract
   -- which creates header, lines and sublines
   ------------------------------------------------------

   PROCEDURE create_contract (
      p_api_version              IN       NUMBER,
      p_batch_rules              IN       batch_rules_rec_type,
      p_transfer_date            IN       DATE,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER
   )
   IS
      l_return_status   VARCHAR2 (1) := 'S';
   BEGIN
      create_contract_header (p_api_version        => 1.0,
                              p_batch_rules        => p_batch_rules,
                              p_transfer_date      => p_transfer_date,
                              x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data

                             );

      fnd_file.put_line(fnd_file.log,'(OKS) -> Create contract header, status = ( '
                         || l_return_status || ' )');

      IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         x_return_status := l_return_status;
         RAISE g_exception_halt_validation;
      END IF;

      create_contract_line (p_api_version        => 1.0,
                            p_batch_rules        => p_batch_rules,
                            p_transfer_date      => p_transfer_date,
                            x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data
                           );

      fnd_file.put_line(fnd_file.log,'(OKS) -> Create contract Line, status = ( '
                         || l_return_status || ' )');

      IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         x_return_status := l_return_status;
         RAISE g_exception_halt_validation;
      END IF;

      create_contract_subline (p_api_version        => 1.0,
                               p_batch_rules        => p_batch_rules,
                               p_transfer_date      => p_transfer_date,
                               x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data
                              );

      fnd_file.put_line(fnd_file.log,'(OKS) -> Create contract subline, status = ( '
                         || l_return_status || ' )');

      IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         x_return_status := l_return_status;
         RAISE g_exception_halt_validation;
      END IF;

     fnd_file.put_line(fnd_file.log,'(OKS) -> Create billing Schedule for biling profile id = ( '
                         || p_batch_rules.billing_profile_id ||' )');
     --call to create coverages and billing schedule
     -- Terminate Cancel top lines and Header
     CREATE_COV_BILLSCHD
     (
     P_contract_status => P_batch_rules.contract_status,
     p_billing_profile_id => p_batch_rules.billing_profile_id,
     Termination_reason   => p_batch_rules.termination_reason_code,
     x_msg_count => x_msg_count,
     x_msg_data =>  x_msg_data,
     x_return_status => l_return_status,
     P_batch_id    => p_batch_rules.batch_id,
     P_transfer_Attachments  => p_batch_rules.transfer_attachments_flag,
     P_transfer_notes  => p_batch_rules.transfer_notes_flag
     );



     fnd_file.put_line(fnd_file.log,'(OKS) -> CREATE_COV_BILLSCHD, status = ( '
                         || l_return_status || ' )');
     IF NOT l_return_status = okc_api.g_ret_sts_success
      THEN
         x_return_status := l_return_status;
         RAISE g_exception_halt_validation;
      END IF;

      x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN

         fnd_file.put_line(fnd_file.log,' Error while creating the contract : '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while creating the contract : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

Procedure Terminate_cancel
  (p_termination_reason  Varchar2,
   P_termcancel_source   VARCHAR2,
   P_cancel_reason       VARCHAR2,
   X_return_status      OUT NOCOPY Varchar2,
   X_msg_count          OUT NOCOPY Number,
   X_msg_data           OUT NOCOPY Varchar2)
   Is

    CURSOR get_srv_details_csr(p_contract_id Number)  IS
        Select Distinct temp.topline_id
              ,St.ste_code
              ,line.start_date
        From   Oks_instance_k_dtls_temp temp
             , okc_k_lines_b line
             , Okc_statuses_b St
        Where  line.id = temp.Topline_id
        And    temp.contract_id = p_contract_id
        And    St.code = line.sts_code;

   Cursor get_contract_csr Is
        Select distinct temp.contract_id
               , kh.authoring_org_id
               , kh.inv_organization_id
               , St.ste_code
               , Kh.start_date
        From   OKs_instance_k_dtls_temp temp
             , Okc_k_headers_all_b Kh
             , Okc_statuses_b St
        Where Kh.Id = temp.contract_id
        And   St.code = Kh.sts_code;
       contract_id               okc_datatypes.numbertabtyp;
       org_id                    okc_datatypes.numbertabtyp;
       organization_id           okc_datatypes.numbertabtyp;
       topline_id                okc_datatypes.numbertabtyp;
       hdr_sts                   okc_datatypes.var30tabtyp;
       topline_sts               okc_datatypes.var30tabtyp;
       l_return_status           Varchar2(1);
       line_start_date           okc_datatypes.datetabtyp;
       hdr_start_date            okc_datatypes.datetabtyp;


Begin


      -- Update all the toplines and headers for termination/Cancellation


        contract_id.delete;
        org_id.delete;
        organization_id.delete;
        hdr_sts.delete;
        hdr_start_date.delete;

        OPEN get_contract_csr;
        FETCH get_contract_csr
        BULK COLLECT INTO
        contract_id,
        org_id,
        organization_id,
        hdr_sts,
        hdr_start_date;
        Close get_contract_csr;
        If contract_id.count > 0 Then

           For i in contract_id.first..contract_id.last
           Loop
                topline_id.delete;
                topline_sts.delete;
                line_start_date.delete;


                okc_context.set_okc_org_context(org_id(i),organization_id(i));
                OPEN get_srv_details_csr(contract_id(i));
                FETCH get_srv_details_csr
                BULK COLLECT INTO
                  topline_id,
                  topline_sts,
                  line_start_date;

                CLOSE get_srv_details_csr;

                FOR j IN topline_id.first..topline_id.last LOOP
                           --Terminate Cancel Top lines if all the sublines are Terminated/Cancelled
                   Teminate_Cancel_Topline
                   (
                     line_status => topline_sts(j),
                     Service_line_id  => topline_id(j),
                     contract_id      => contract_id(i),
                     line_start_date  => line_start_date(j),
                     Term_cancel_source => P_termcancel_source, --'IBTERMINATE',
                     Termination_reason => P_termination_reason,
                     Cancel_reason => p_cancel_reason, --'TERMINATED',
                     x_msg_count   => x_msg_count,
                     x_msg_data   => x_msg_data,
                     x_return_status => l_return_status
                  );

                   IF NOT l_return_status = 'S'
                   THEN

                        RAISE g_exception_halt_validation;
                   END IF;

                 END LOOP; --For Service Lines

                 --Terminate Cancel Header if all the Toplines are Terminated/Cancelled

                   Teminate_Cancel_Header
                   (
                     P_Contract_status    => hdr_sts(i),
                     contract_id        => contract_id(i),
                     hdr_start_date     => hdr_start_date(i),
                     Term_cancel_source => P_termcancel_source, --'IBTERMINATE',
                     Termination_reason => P_termination_reason,
                     Cancel_reason      => p_cancel_reason, --'TERMINATED',
                      x_msg_count   => x_msg_count,
                     x_msg_data   => x_msg_data,
                     x_return_status => l_return_status
                   );

                   IF NOT l_return_status = 'S'
                   THEN

                        RAISE g_exception_halt_validation;
                    END IF;



            End Loop; -- Contracts
         End If;
            x_return_status := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN

         fnd_file.put_line(fnd_file.log,' Error while terminating/Canceling line/hdr: '
         || SQLCODE||':'|| SQLERRM );
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while terminating/Canceling line/hdr: '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   ------------*  Procedure update_contract *-------------
   -- procedure to terminate/cancel the impacted contracts
   -- and create new contract for the new party.
   -- creates transaction source, copy attachments, copy
   -- notes ,copy csi notes, run qa check, Roll up the
   -- amounts to header and lines.
   ------------------------------------------------------

   PROCEDURE update_contracts (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_batch_type               IN       VARCHAR2,
      p_batch_id                 IN       NUMBER,
      p_new_acct_id              IN       NUMBER,
      p_old_acct_id              IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR get_k_for_transfer_csr (
         p_transfer_rule                     VARCHAR2,
         l_relationship                      VARCHAR2,
         p_party_id                          NUMBER,
         P_credit_option                     Varchar2
      )
      IS
         SELECT ki.dnz_chr_id  contract_id,
                kh.start_date  k_sdate,
                kh.end_date    k_edate,
                kh.sts_code    k_sts_code,
                Hst.ste_code   Hdr_ste,
                kh.contract_number,
                kh.contract_number_modifier,
                kl.cle_id      topline_id,
                kl2.start_date l_sdate,
                kl2.end_date   l_edate,
                ki.cle_id      subline_id,
                kl.start_date  sl_sdate,
                TRUNC(CASE
                    WHEN trunc(tmp.transfer_date) < trunc(kl.start_date)
                       THEN trunc(kl.start_date)
                    ELSE tmp.transfer_date
                 END
                ) subline_sdate,
                kl.end_date subline_edate,
                (decode(row_number() over (partition by kl.dnz_chr_id order by kl.cle_id), 1,
                     oks_mass_update_pvt.get_seq_no ('H', 'NEW',kh.end_date)
                    , oks_mass_update_pvt.get_seq_no ('H', 'OLD', kh.end_date))

                ) newcontractid,
               (decode(row_number() over (partition by kl.dnz_chr_id, kl.cle_id order by kl.rowid), 1
                        , oks_mass_update_pvt.get_seq_no ('L', 'NEW',kl.end_date)
                        , oks_mass_update_pvt.get_seq_no ('L', 'OLD',kl.end_date))
               ) newlineid,
                oks_mass_update_pvt.get_seq_no ('SL', 'NEW',kl.end_date) newsublineid,
                st.ste_code subline_status,
                tmp.transfer_date transfer_date,
                tmp.old_customer_product_id custprod_id,
                kl.price_negotiated,
                kl.price_unit,
                ki.number_of_items,
                DECODE (kl2.lse_id ,14,'WARRANTY','OTHERS'),
                tmp.transaction_date,
                Party.object1_id1,
                Kh.authoring_org_id,
                NVL(P_credit_option
                    ,OKS_IB_UTIL_PVT.get_credit_option(party.object1_id1,kh.authoring_org_id,tmp.transaction_date)),
                Kh.inv_organization_id
           FROM okc_k_items ki,
                okc_k_headers_all_b kh,
                oks_k_headers_b ks,
                okc_k_lines_b kl,
                okc_statuses_b st,
                okc_statuses_b Hst,
                oks_k_lines_b ks1,
                oks_k_lines_b ks2,
                okc_k_lines_b kl2,
                oks_instance_temp tmp,
                okc_k_party_roles_b party
          WHERE ki.object1_id1 = to_char(tmp.old_customer_product_id)
            AND tmp.trf = 'Y'
            AND ki.jtot_object1_code = 'OKX_CUSTPROD'
            AND ki.dnz_chr_id = kh.ID
            AND kh.scs_code IN ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
            And Kh.sts_code = Hst.code
            AND ki.cle_id = kl.ID
            AND kl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED')
            AND kl.date_terminated IS NULL
            AND kh.template_yn = 'N'
            --AND kl.cle_id = kl1.cle_id
            --AND ks1.cle_id = kl1.ID
            --AND kl1.lse_id IN (2, 20, 15)
            AND kl2.ID = kl.cle_id
            AND kl2.cle_id IS NULL
            AND kl2.id = ks1.cle_id              -- Added for coverage
            and ks1.coverage_id = ks2.cle_id(+)  -- Added for coverage
            AND party.dnz_chr_id = kh.ID
            AND party.chr_id IS NOT NULL
            AND party.cle_id IS NULL
            AND party.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
            AND party.jtot_object1_code = 'OKX_PARTY'
            AND party.object1_id1 <> p_party_id
            AND kh.ID = ks.chr_id(+)
            AND (   (    TRUNC (tmp.transfer_date) <= TRUNC (kl.end_date)
                     AND TRUNC (tmp.transfer_date) >= TRUNC (kl.start_date)
                    )
                 OR (TRUNC (tmp.transfer_date) <= TRUNC (kl.start_date))
                 OR (    TRUNC (kl.end_date) < TRUNC (tmp.transfer_date)
                     AND kl.Date_renewed is Null and kl.lse_id <> 18
                    )
                )
            AND (   ('TRANSFER' = p_transfer_rule)
                 OR (    'COVERAGE' = p_transfer_rule
                     AND (   ks2.transfer_option = 'TRANS'
                          OR (    ks2.transfer_option = 'TRANS_NO_REL'
                              AND NVL (l_relationship, 'Y') = 'Y'
                             )
                         )
                    )
                )
                ;


      CURSOR get_k_for_trfterm_csr (
         p_transfer_rule                     VARCHAR2,
         l_relationship                      VARCHAR2,
         p_party_id                          NUMBER,
         P_credit_option                     Varchar2

      )
      IS

         SELECT ki.dnz_chr_id     contract_id,
                ki.cle_id         subline_id,
                sl.start_date     subline_sdate,
                sl.end_date       subline_edate,
                st.ste_code       subline_sts,
                kh.start_date     hdr_sdt,
                kh.end_date       hdr_edt,
                kh.sts_code       hdr_sts,
                Hst.ste_code      hdr_ste,
                kh.contract_number,
                kh.contract_number_modifier,
                Tl.id             top_line_id,
                Tl.start_date     top_line_sdt,
                Tl.end_date       Top_line_edt,
                party.object1_id1 party_id,
                tmp.transfer_date,
                tmp.old_customer_product_id custprod_id,
                sl.price_negotiated,
                sl.price_unit,
                ki.number_of_items,
                tmp.transaction_date,
                Kh.authoring_org_id,
                NVL(P_credit_option
                    ,OKS_IB_UTIL_PVT.get_credit_option(party.object1_id1,kh.authoring_org_id,tmp.transaction_date)),
                Kh.inv_organization_id

           FROM okc_k_items ki,
                okc_k_headers_all_b kh,
                oks_k_headers_b ks,
                okc_k_lines_b sl,
                okc_k_lines_b Tl,
                oks_k_lines_b okl,
                oks_k_lines_b okl1,
                okc_statuses_b st,
                okc_k_party_roles_b party,
                oks_instance_temp tmp,
                okc_statuses_b Hst
          WHERE tmp.trf = 'Y'
            AND ki.object1_id1 = to_char(tmp.old_customer_product_id)
            AND ki.jtot_object1_code = 'OKX_CUSTPROD'
            AND ki.dnz_chr_id = kh.ID
            AND ks.chr_id(+) = kh.ID
            AND kh.scs_code IN ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
            And kh.sts_code = Hst.code
            AND ki.cle_id = sl.ID
            AND sl.cle_id = Tl.id                 -- Added for coverage re-arc
            AND Tl.cle_id IS NULL                 -- Added for coverage re-arc
            AND Tl.id = okl.cle_id                -- Added for coverage re-arc
            AND okl.coverage_id = okl1.cle_id(+)   -- Added for coverage re-arc
            AND sl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED')
            AND sl.date_terminated IS NULL
            AND kh.template_yn = 'N'
            AND party.dnz_chr_id = kh.ID
            AND party.chr_id IS NOT NULL
            AND party.cle_id IS NULL
            AND party.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
            AND party.jtot_object1_code = 'OKX_PARTY'
            AND party.object1_id1 <> p_party_id
            AND (   (    TRUNC (tmp.transfer_date) <= TRUNC (sl.end_date)
                     AND TRUNC (tmp.transfer_date) >= TRUNC (sl.start_date)
                    )
                 OR (TRUNC (tmp.transfer_date) <= TRUNC (sl.start_date))
                 OR (    TRUNC (sl.end_date) < TRUNC (tmp.transfer_date)
                     AND sl.date_renewed is null and sl.lse_id <> 18

                    )
                )
            AND (   ('TERMINATE' = p_transfer_rule)
                 OR (    'COVERAGE' = p_transfer_rule
                     AND (   okl1.transfer_option = 'TERM'
                          OR (    okl1.transfer_option = 'TERM_NO_REL'
                              AND NVL (l_relationship, 'Y') = 'Y'
                             )
                         )
                    )
                )
               ;

      CURSOR get_k_for_trm_csr(P_credit_option Varchar2)
      IS
         SELECT ki.dnz_chr_id AS contract_id,
                kl.cle_id     AS topline_id,
                ki.cle_id     AS subline_id,
                kh.start_date AS hdr_sdt,
                kh.end_date   AS hdr_edt,
                Kh.sts_code   AS hdr_sts,
                HSt.ste_code   AS hdr_ste,
                kh.contract_number,
                kh.contract_number_modifier,
                tl.start_date AS srv_sdt,
                tl.end_date   AS srv_edt,
                Lst.ste_code   AS srv_sts,
                kl.start_date AS prod_sdate,
                kl.end_date   AS prod_edate,
                st.ste_code   AS prod_sts,
                tmp.termination_date        AS term_date,
                tmp.old_customer_product_id AS instance_id,
                tmp.transaction_date        AS transaction_date,
                ki.number_of_items          AS qty,
                kl.price_negotiated         AS price_negotiated,
                party.object1_id1 party_id,
                kh.authoring_org_id,
                NVL(P_credit_option
                    ,OKS_IB_UTIL_PVT.get_credit_option(party.object1_id1,kh.authoring_org_id,tmp.transaction_date)),
                Kh.inv_organization_id
           FROM okc_k_items ki,
                okc_k_headers_all_b kh,
                okc_k_lines_b kl,
                okc_statuses_b st,
                oks_instance_temp tmp,
                okc_k_lines_b tl,
                okc_k_party_roles_b party,
                Okc_statuses_b Hst,
                Okc_statuses_b Lst
          WHERE tmp.trm = 'Y'
            AND ki.object1_id1 = to_char(tmp.old_customer_product_id)
            AND ki.jtot_object1_code = 'OKX_CUSTPROD'
            AND ki.dnz_chr_id = kh.ID
            AND kh.scs_code IN ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
            And Kh.sts_code = Hst.code
            AND ki.cle_id = kl.ID
            AND tl.ID = kl.cle_id
            And tl.sts_code = Lst.code
            AND kl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED')
            AND kl.date_terminated IS NULL
            AND kh.template_yn = 'N'
            AND party.dnz_chr_id = kh.ID
            AND party.chr_id IS NOT NULL
            AND party.cle_id IS NULL
            AND party.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
            AND party.jtot_object1_code = 'OKX_PARTY'
            AND (   (    TRUNC (tmp.Termination_date) <= TRUNC (kl.end_date)
                     AND TRUNC (tmp.Termination_date) >= TRUNC (kl.start_date)
                    )
                 OR (TRUNC (tmp.Termination_date) <= TRUNC (kl.start_date))
                 OR (    TRUNC (kl.end_date) < TRUNC (tmp.Termination_date)
                     AND Kl.date_renewed is null and kl.lse_id <> 18
                    )
                )
         UNION
         SELECT ki.dnz_chr_id AS contract_id,
                kl.cle_id AS topline_id,
                ki.cle_id AS subline_id,
                kh.start_date AS hdr_sdt,
                kh.end_date AS hdr_edt,
                kh.sts_code AS hdr_sts,
                HSt.ste_code   AS hdr_ste,
                kh.contract_number,
                kh.contract_number_modifier,
                tl.start_date AS srv_sdt,
                tl.end_date AS srv_edt,
                Lst.ste_code AS srv_sts,
                kl.start_date AS prod_sdate,
                kl.end_date AS prod_edate,
                st.ste_code AS prod_sts,
                tmp.termination_date AS term_date,
                tmp.old_customer_product_id AS instance_id,
                tmp.transaction_date AS transaction_date,
                ki.number_of_items AS qty,
                kl.price_negotiated AS price_negotiated,
                party.object1_id1 party_id,
                kh.authoring_org_id,
                NVL(P_credit_option
                    ,OKS_IB_UTIL_PVT.get_credit_option(party.object1_id1,kh.authoring_org_id,tmp.transaction_date)),
                Kh.inv_organization_id



           FROM okc_k_items ki,
                okc_k_headers_all_b kh,
                okc_k_lines_b kl,
                okc_k_lines_b tl,
                okc_statuses_b st,
                csi_counter_associations ctrAsc,
                oks_instance_temp tmp,
                okc_k_party_roles_b party,
                okc_statuses_b Hst,
                okc_statuses_b Lst
          WHERE tmp.trm = 'Y'
            AND ki.object1_id1 = to_char(ctrAsc.counter_id)
            AND ctrAsc.source_object_id = tmp.old_customer_product_id
            And ctrAsc.source_object_code = 'CP'
            AND ki.jtot_object1_code = 'OKX_COUNTER'
            AND ki.dnz_chr_id = kh.ID
            AND kh.scs_code IN ('SERVICE', 'SUBSCRIPTION')
            And Kh.sts_code = Hst.code
            AND ki.cle_id = kl.ID
            AND tl.ID = kl.cle_id
            And tl.sts_code = Lst.code
            AND kl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED')
            AND kl.date_terminated IS NULL
            AND kh.template_yn = 'N'
            AND party.dnz_chr_id = kh.ID
            AND party.chr_id IS NOT NULL
            AND party.cle_id IS NULL
            AND party.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
            AND party.jtot_object1_code = 'OKX_PARTY'

            AND (   (    TRUNC (tmp.Termination_date) <= TRUNC (kl.end_date)
                     AND TRUNC (tmp.Termination_date) >= TRUNC (kl.start_date)
                    )
                 OR (TRUNC (tmp.Termination_date) <= TRUNC (kl.start_date))
                 OR (    TRUNC (kl.end_date) < TRUNC (tmp.Termination_date)
                     AND Kl.date_renewed is null and kl.lse_id <> 18
                    )
                );

      CURSOR get_k_for_idc_csr
      IS
           select a.*, cs.creation_date
         from ( SELECT ki.dnz_chr_id AS contract_id,
                kl.cle_id AS topline_id,
                ki.cle_id AS subline_id,
                kh.start_date AS hdr_sdt,
                kh.end_date AS hdr_edt,
                kh.sts_code AS hdr_sts,
                tl.start_date AS srv_sdt,
                tl.end_date AS srv_edt,
                tl.sts_code AS srv_sts,
                kl.start_date AS prod_sdate,
                kl.end_date AS prod_edate,
                kl.sts_code AS prod_sts,
                tmp.installation_date AS idc_date,
                TRUNC (oks_mass_update_pvt.get_end_date (kl.start_date,
                                                     kl.end_date,
                                                     tmp.installation_date
                                                    )
                      ) AS new_edt,
                      ki.number_of_items,
                      tmp.transaction_date,
                      tmp.old_customer_product_id,
                (Kh.COntract_number||' '||Kh.Contract_number_Modifier)COntract_number,
                kl.line_number



           FROM okc_k_items ki,
                okc_k_headers_all_b kh,
                okc_k_lines_b kl,
                okc_statuses_b st,
                oks_instance_temp tmp,
                okc_k_lines_b tl,
                oks_k_lines_v ksl,
                oks_k_lines_b ks11
          WHERE tmp.idc = 'Y'
            AND NVL(tmp.trm, 'N') = 'N'
            AND ki.object1_id1 = to_char(tmp.old_customer_product_id)
            AND ki.jtot_object1_code = 'OKX_CUSTPROD'
            AND ki.dnz_chr_id = kh.ID
            AND kh.scs_code IN ('WARRANTY')
            AND ki.cle_id = kl.ID
            AND tl.ID = kl.cle_id
            AND kl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED', 'HOLD')
            AND kl.date_terminated IS NULL
            AND kh.template_yn = 'N'
            AND kl.lse_id = 18
            And Ksl.cle_id = Tl.id
            And ks11.cle_id = Ksl.coverage_id
            And Nvl(ks11.sync_date_install,'N') = 'Y'
            ) a, cs_incidents_all_b cs
            where cs.customer_product_id(+) = a.old_customer_product_id
            AND cs.contract_service_id(+) = a.topline_ID;

      CURSOR get_batch_rules_trm_csr
      IS
      SELECT credit_option,
             nvl(termination_reason_code,'EXP')
       FROM  oks_batch_rules
      WHERE  batch_id = p_batch_id;

      CURSOR get_batch_rules_csr
      IS
         SELECT b.ID biling_profile_id,
                NVL (b.invoice_object1_id1, -2) invoicing_rule,
                NVL (b.account_object1_id1, 1) accounting_rule,
                a.transaction_date transfer_date,
                a.credit_option,
                nvl(a.termination_reason_code,'TRF') termination_reason_code,
                a.retain_contract_number_flag,
                a.contract_modifier,
                a.contract_status,
                a.transfer_notes_flag,
                a.transfer_attachments_flag,
                a.bill_lines_flag,
                a.transfer_option_code transfer_option,
                a.bill_account_id,
                a.ship_account_id,
                a.bill_address_id,
                a.ship_address_id,
                a.bill_contact_id,
--              a.ship_contact_id,
                NVL(a.new_account_id,p_new_acct_id) new_customer_id,
                c.party_id new_party_id,
                d.party_name party_name,
                a.batch_id batch_id
           FROM oks_batch_rules a,
                oks_billing_profiles_b b,
                hz_cust_accounts c,
                hz_parties d
          WHERE a.batch_id = p_batch_id
            AND b.ID(+) = a.billing_profile_id
            AND c.cust_account_id = NVL(a.new_account_id, p_new_acct_id)
            AND c.party_id = d.party_id;

      CURSOR get_topline_dates_csr

      IS
         SELECT distinct temp.topline_id
         ,line.start_date,
                line.end_date
           FROM okc_k_lines_b line
               , oks_instance_k_dtls_temp temp
          WHERE line.ID = temp.topline_id;

      CURSOR check_renewal_link (
         p_line_id                           NUMBER
      )
      IS
         SELECT subject_cle_id
           FROM okc_operation_instances op,
                okc_operation_lines ol
          WHERE ol.oie_id = op.ID
            AND op.cop_id = 41
            AND ol.subject_cle_id = p_line_id;

      CURSOR get_qclid_csr (
         p_id                                NUMBER
      )
      IS
         SELECT qcl_id
           FROM okc_k_headers_all_b
          WHERE ID = p_id;

      CURSOR check_relation_csr
      IS
         SELECT DISTINCT a.relationship_type
                    FROM hz_relationships a,
                         hz_cust_accounts b1,
                         hz_cust_accounts b2,
                         oks_instance_temp c
                   WHERE (   (    a.object_id = b1.party_id
                              AND a.subject_id = b2.party_id
                             )
                          OR (    a.object_id = b2.party_id
                              AND a.subject_id = b1.party_id
                             )
                         )
                     AND a.relationship_type =
                                       fnd_profile.VALUE ('OKS_TRF_PARTY_REL')
                     AND a.status = 'A'
                     AND TRUNC (c.transfer_date) BETWEEN TRUNC (a.start_date)
                                                     AND TRUNC (a.end_date)
                     AND b1.cust_account_id = c.new_customer_acct_id
                     AND b2.cust_account_id = c.old_customer_acct_id
                     AND ROWNUM < 2;



      CURSOR Check_batch_csr (
         p_batch_id                          NUMBER
      )
      IS
         SELECT 'x'
           FROM oks_batch_rules
          WHERE batch_id = p_batch_id;



      CURSOR get_inst_hist_csr (
         p_batch_id                          NUMBER
      )
      IS
        SELECT b.ID,
               (SELECT start_date
                  FROM okc_k_headers_all_b
                 WHERE ID = new_contract_id),
               (SELECT end_date
                  FROM okc_k_headers_all_b
                 WHERE ID = new_contract_id),
               (SELECT sts_code
                  FROM okc_k_headers_all_b
                 WHERE ID = new_contract_id),
               (SELECT start_date
                  FROM okc_k_lines_b
                 WHERE ID = new_serviceline_id),
               (SELECT end_date
                  FROM okc_k_lines_b
                 WHERE ID = new_serviceline_id),
               (SELECT price_negotiated
                  FROM okc_k_lines_b
                 WHERE ID = new_subline_id)
          FROM oks_instance_k_dtls_temp a,
               oks_instance_history b
         WHERE b.batch_id = p_batch_id
           AND a.instance_id = b.instance_id
           AND b.transaction_type = 'TRF';




      Cursor l_subline_invtext_csr Is
      Select  Kl.Id
            ,(substr(ksl.invoice_text,1,instr(ksl.invoice_text,':',1,3))||kl.start_date||' - '|| kl.end_date)
      From   Okc_k_lines_b Kl
             ,Oks_k_lines_v Ksl
            ,OKs_instance_k_dtls_temp temp
      Where kl.id = temp.subline_id
      And   Ksl.cle_id = Kl.id;

      Cursor L_topline_csr Is
      Select distinct a.Topline_id, a.start_date, a.end_date
      From (select line.cle_id topline_id
            , min(line.start_date) start_date
            , max(line.end_date) end_date
             From  OKs_instance_k_dtls_temp temp
                  , okc_K_lines_b line
             Where line.cle_id = temp.topline_id
             And   line.lse_id = 18
             group by line.cle_id) a;

      Cursor l_invoice_text_csr Is
      Select distinct Kl.Id
            ,(substr(ksl.invoice_text,1,instr(ksl.invoice_text,':',1,1))||kl.start_date||' - '|| kl.end_date)
      From   Okc_k_lines_b Kl
             ,Oks_k_lines_v Ksl
            ,OKs_instance_k_dtls_temp temp
      Where kl.id = temp.topline_id
      And   Ksl.cle_id = Kl.id;

      Cursor L_contract_csr Is
      Select distinct a.Contract_id, a.start_date, a.end_date
      From   (Select line.dnz_chr_id contract_id
                    ,min(line.start_date) start_date
                   , max(line.end_date) end_date
              From  OKs_instance_k_dtls_temp temp
                  , okc_k_lines_b line
              Where line.dnz_chr_id = temp.contract_id
              And   line.lse_id = 14
              group by line.dnz_chr_id) a;


    CURSOR get_srv_details_csr(p_contract_id Number)  IS
        Select Distinct temp.topline_id
              ,St.ste_code
        From   Oks_instance_k_dtls_temp temp
             , okc_k_lines_b line
             , Okc_statuses_b St
        Where  line.id = temp.Topline_id
        And    temp.contract_id = p_contract_id
        And    St.code = line.sts_code;

   Cursor get_contract_csr Is
        Select distinct temp.contract_id
               , kh.authoring_org_id
               , kh.inv_organization_id
               , St.ste_code
        From   OKs_instance_k_dtls_temp temp
             , Okc_k_headers_all_b Kh
             , Okc_statuses_b St
        Where Kh.Id = temp.contract_id
        And   St.code = Kh.sts_code;


      -- Local Variables
      l_renewal_id              NUMBER;
      l_source_line_id          NUMBER;
      l_object_line_id          NUMBER;
      l_object_chr_id           NUMBER;
      l_transfer_id             NUMBER;
      l_qcl_id                  NUMBER;

      j                         NUMBER;
      l_count                   NUMBER                                   := 1;
      l_sts_code                VARCHAR2 (30);
      l_ste_code                VARCHAR2 (30);
      l_relationship            VARCHAR2 (40);
      l_term_date               DATE;
      l_cancel_date             DATE;
      l_ctr                     NUMBER                                   := 1;
      l_found                   BOOLEAN                                  := FALSE;
      l_dummy_var               VARCHAR2(1);
      -- Variables for attachments
      l_entity_name             VARCHAR2 (30);
      l_from_entity_name        VARCHAR2 (30);
      l_to_entity_name          VARCHAR2 (30);
      l_from_version            fnd_attached_documents.pk2_value%TYPE;
      -- Valiables for notes
      l_jtf_note_id             NUMBER;
      l_jtf_note_contexts_tab   jtf_notes_pub.jtf_note_contexts_tbl_type;
      l_note_details            csi_mass_edit_entries_tl.Description%TYPE;
      --Contract Line Table
      l_clev_tbl_in             okc_contract_pub.clev_tbl_type;
      l_clev_tbl_out            okc_contract_pub.clev_tbl_type;
      --Contract Header
      l_chrv_tbl_in             okc_contract_pub.chrv_tbl_type;
      l_chrv_tbl_out            okc_contract_pub.chrv_tbl_type;
      -- workflow variabled
      l_wf_attributes           oks_wf_k_process_pvt.wf_attr_details;
      -- Instance History
      l_inst_dtls_tbl           oks_ihd_pvt.ihdv_tbl_type;
      x_inst_dtls_tbl           oks_ihd_pvt.ihdv_tbl_type;
      l_insthist_rec            oks_ins_pvt.insv_rec_type;
      x_insthist_rec            oks_ins_pvt.insv_rec_type;
      l_warn_return_status       Varchar2(1);
      -- plsql collections for old and new contract ids and other
      -- attributes
      contract_number           okc_datatypes.var120tabtyp;
      contract_number_modifier  okc_datatypes.var120tabtyp;
      contractnumber_modifier   okc_datatypes.var240tabtyp;
      line_number               okc_datatypes.var240tabtyp;
      qa_contract_id            okc_datatypes.numbertabtyp;
      customer_product_tbl      okc_datatypes.numbertabtyp;
      contract_id               okc_datatypes.numbertabtyp;
      old_contract_id           okc_datatypes.numbertabtyp;
      subline_id                okc_datatypes.numbertabtyp;
      topline_id                okc_datatypes.numbertabtyp;
      subline_old_sdate         okc_datatypes.datetabtyp;
      subline_sdate             okc_datatypes.datetabtyp;
      subline_edate             okc_datatypes.datetabtyp;
      subline_sts               okc_datatypes.var30tabtyp;
      hdr_sdt                   okc_datatypes.datetabtyp;
      hdr_edt                   okc_datatypes.datetabtyp;
      hdr_sts                   okc_datatypes.var30tabtyp;
      hdr_ste                   okc_datatypes.var30tabtyp;
      topline_sdate             okc_datatypes.datetabtyp;
      topline_edate             okc_datatypes.datetabtyp;
      topline_sts               okc_datatypes.var30tabtyp;
      sr_date                   okc_datatypes.datetabtyp;
      new_edt                   okc_datatypes.datetabtyp;
      party_id                  okc_datatypes.numbertabtyp;
      term_date                 okc_datatypes.datetabtyp;
      trf_date                  okc_datatypes.datetabtyp;
      idc_date                  okc_datatypes.datetabtyp;
      new_contract_id           okc_datatypes.numbertabtyp;
      new_line_id               okc_datatypes.numbertabtyp;
      new_subline_id            okc_datatypes.numbertabtyp;
      custprod_id               okc_datatypes.numbertabtyp;
      price_unit                okc_datatypes.numbertabtyp;
      price_negotiated          okc_datatypes.numbertabtyp;
      number_of_items           okc_datatypes.numbertabtyp;
      new_k_sdate               okc_datatypes.datetabtyp;
      new_k_edate               okc_datatypes.datetabtyp;
      new_l_sdate               okc_datatypes.datetabtyp;
      new_l_edate               okc_datatypes.datetabtyp;
      new_k_status              okc_datatypes.var30tabtyp;
      new_price_negotiated      okc_datatypes.numbertabtyp;
      ins_id                    okc_datatypes.numbertabtyp;
      header_id                 okc_datatypes.numbertabtyp;
      top_line_id               okc_datatypes.numbertabtyp;
      sub_line_id               okc_datatypes.numbertabtyp;
      Hdr_new_Sdate             okc_datatypes.datetabtyp;
      line_new_sdate            okc_datatypes.datetabtyp;
      Hdr_new_edate             okc_datatypes.datetabtyp;
      line_new_edate            okc_datatypes.datetabtyp;
      transaction_date          okc_datatypes.datetabtyp;
      hdr_warranty              okc_datatypes.var30tabtyp;
      org_id                    okc_datatypes.numbertabtyp;
      organization_id           okc_datatypes.numbertabtyp;
      credit_option             okc_datatypes.var30tabtyp;
      inv_text                  var2000tabtyp;
      invoice_text              var2000tabtyp;
      l_return_status           VARCHAR2 (1)                            := 'S';
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000);
      l_suppress_credit         VARCHAR2 (2)                            := 'N';
      l_full_credit             VARCHAR2 (2)                            := 'N';
      l_trf_dt                  DATE;
      l_trm_dt                  DATE;
      l_idc_dt                  DATE;
      l_top_sdt                 DATE;
      l_top_edt                 DATE;
      l_rnrl_rec_out            oks_renew_util_pvt.rnrl_rec_type;
      batch_rules_rec           batch_rules_rec_type;
      batch_rules_trm_rec       batch_rules_trm_type;
      l_cancel_source           Varchar2(30);
      l_cancel_reason           Varchar2(30);
      l_new_acct_id             Number;
      l_old_acct_id             Number;
      l_instance_history_created Varchar2(1) := 'N';
      l_date_cancel             Date;
      l_term_flag               VARCHAR2(1) := 'N';
      l_termination_source      Varchar2(30);
      l_sr_flag                 varchar2(1);
      l_credit_option           Varchar(30);
      l_termination_reason      Varchar2(240);
      L_line_date_renewed  Date;
      L_hdr_date_renewed   Date;



      FUNCTION check_contract_duplicate (
          p_k_id                     IN       NUMBER
        )
      RETURN BOOLEAN
      IS
      BEGIN
         IF l_gl_dummy = p_k_id
         THEN
            l_gl_dummy := p_k_id;
            RETURN (TRUE);
         ELSE
            l_gl_dummy := p_k_id;
            RETURN (FALSE);
         END IF;
       END;

   -- Begin Update Contracts
   BEGIN
      IF (p_init_msg_list = 'Y') then
          fnd_msg_pub.initialize();
      END IF;

      fnd_file.put_line(fnd_file.log,'(OKS) -> ***********OKS**********Begin*********OKS***********');

      fnd_file.put_line(fnd_file.log,'(OKS) -> Batch Id = ( '|| p_batch_id||' ) New Account Id = ( '||p_new_acct_id ||' )');
      l_return_status := 'S';



      If p_batch_id IS NULL
      THEN
         fnd_file.put_line(fnd_file.log,'(OKS) -> Batch id is not passed to Contracts.');

         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE

         OPEN Check_batch_csr (p_batch_id);
         FETCH Check_batch_csr into l_dummy_var;
         IF Check_batch_csr%NOTFOUND
         THEN
            fnd_file.put_line(fnd_file.log,'(OKS) -> No batch rules defined');

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.Update_contracts',
                         'No Batch rules defined' );
            END IF;

            oks_ibint_pub.create_batch_rules
            (
             P_Api_Version           => 1.0,
             P_init_msg_list         => 'F',
             P_Batch_ID              => p_batch_id,
             p_batch_type            => p_batch_type,
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data	             => l_msg_data );

             fnd_file.put_line(fnd_file.log,'(OKS) -> Forms Batch Rules status = ( '||l_return_status||' )');
             IF l_return_status <> 'S'
             THEN
                 Okc_api.set_message
                (g_app_name,
                'OKS_BATCH_ERROR'
                );

                 RAISE g_exception_halt_validation;
             END IF;

         END IF;
         CLOSE Check_batch_csr;

      END IF;

    IF p_batch_type = 'XFER'
    THEN
      OPEN get_batch_rules_csr;
      FETCH get_batch_rules_csr  INTO batch_rules_rec;

      IF get_batch_rules_csr%NOTFOUND
      THEN

         Okc_api.set_message
                (g_app_name,
                'OKS_NO_BATCH_RULES_EXIST' ,
                 'BATCHID',
                 P_batch_id
                );

         RAISE G_EXCEPTION_HALT_VALIDATION ;

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.Update_contracts',
                         'No Batch rules created' );
         END IF;

      END IF;

      CLOSE get_batch_rules_csr;
    ELSIF p_batch_type = 'TRM' Then
      OPEN get_batch_rules_trm_csr;
      FETCH get_batch_rules_trm_csr  INTO batch_rules_trm_rec;

      IF get_batch_rules_trm_csr%NOTFOUND
      THEN
         Okc_api.set_message
                (g_app_name,
                'OKS_NO_BATCH_RULES_EXIST',
                 'BATCHID',
                 P_batch_id
                );

         RAISE G_EXCEPTION_HALT_VALIDATION ;
         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module_current || 'oks_mass_update.Update_contracts',
                         'No Batch rules created' );
         END IF;
       END IF;
     CLOSE get_batch_rules_trm_csr;
   END IF;

      fnd_file.put_line(fnd_file.log,'(OKS) -> Batch Type = ( ' || p_batch_type
                         || ' ) Batch id = ( ' || p_batch_id || ' ) Transfer Option = ( ' || batch_rules_rec.transfer_option|| ' )');

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
      fnd_log.STRING (fnd_log.level_event,
                     g_module_current || 'oks_mass_update.Update_contracts',
                     'Batch Type = ( '|| p_batch_type || ') Batch id = ( '
                     || p_batch_id || ')' );
      END IF;

      IF p_batch_type = 'XFER' -- 'CSI_MU_TRANSFER_OWNER'
      THEN

         IF P_new_acct_id IS NULL
         THEN
                fnd_file.put_line(fnd_file.log,'(OKS) -> New Account id is not passed to Contracts.');
                okc_api.set_message
                (
                 g_app_name,
                'OKS_NULL_ACCOUNT_ID',
                'BATCHID',
                P_batch_id
                );

                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
         IF UPPER (batch_rules_rec.transfer_option) = 'NOCHANGE'
         THEN
            NULL;
         END IF;

         IF UPPER (batch_rules_rec.transfer_option) = 'COVERAGE'
         THEN
            l_relationship := NULL;

            OPEN check_relation_csr;
            FETCH check_relation_csr  INTO l_relationship;
            CLOSE check_relation_csr;
            fnd_file.put_line(fnd_file.log,'(OKS) -> Relationship = ( '|| l_relationship|| ' )');
         END IF;
         l_termination_source := 'IBTRANSFER';

         IF    batch_rules_rec.transfer_option = 'TERMINATE'
            OR batch_rules_rec.transfer_option = 'COVERAGE'
         THEN
            OPEN get_k_for_trfterm_csr (batch_rules_rec.transfer_option,
                                        l_relationship,
                                        batch_rules_rec.new_party_id,
                                        batch_rules_rec.credit_option
                                       );

            IF get_k_for_trfterm_csr%ISOPEN
            THEN
               FETCH get_k_for_trfterm_csr
               BULK COLLECT INTO contract_id,
                      subline_id,
                      subline_sdate,
                      subline_edate,
                      subline_sts,
                      hdr_sdt,
                      hdr_edt,
                      hdr_sts,
                      hdr_ste,
                      contract_number,
                      contract_number_modifier,
                      topline_id,
                      topline_sdate,
                      topline_edate,
                      party_id,
                      trf_date,
                      custprod_id,
                      price_negotiated,
                      price_unit,
                      number_of_items,
                      transaction_date,
                      Org_id,
                      credit_option,
                      organization_id;
            END IF;

            CLOSE get_k_for_trfterm_csr;

            fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate/Coverage: Number of impacted contracts = ( '
            || contract_id.COUNT || ' )');

            IF contract_id.count>0
            THEN
            FOR i IN 1..subline_sts.COUNT
            LOOP
            IF hdr_ste(i) = 'HOLD'
            THEN
                l_found := TRUE;
                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.oks_mass_update.Update_contracts',
                   ' Contract '||contract_number(i) ||' in QA_HOLD status' );
                END IF;

                OKC_API.SET_MESSAGE(
                g_app_name,
                'OKS_CONTRACT_HOLD',
                'CONTRACTNUMBER',
                CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i)
                );

            END IF;
            END LOOP;

            IF l_found
            THEN
                l_return_status  := OKC_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            FORALL i IN contract_id.FIRST .. contract_id.LAST
               INSERT INTO oks_instance_k_dtls_temp
                           (parent_id,
                            contract_id,
                            topline_id,
                            subline_id,
                            instance_id
                           )
                    VALUES (p_batch_id,
                            contract_id (i),
                            topline_id (i),
                            subline_id (i),
                            custprod_id (i)
                           );
            fnd_file.put_line(fnd_file.log,'(OKS) -> Insert into global temp table Successful');

           fnd_file.put_line(fnd_file.log,'subline_id.count'||subline_id.count);

            IF subline_id.COUNT > 0
            THEN
               FOR i IN subline_id.FIRST .. subline_id.LAST
               LOOP


                  l_trf_dt := trf_date (i);
                  l_date_cancel := trf_date(i);
                  l_term_flag:= 'N';

                  IF (TRUNC (l_date_cancel) <= TRUNC (subline_sdate (i)))
                  Then
                       l_date_cancel := subline_sdate(i);
                  Elsif ( TRUNC (subline_edate (i)) < TRUNC (l_date_cancel) )
                  Then
                       l_date_cancel := subline_edate(i) + 1;
                  End If;

                  IF    (TRUNC (l_trf_dt) <= TRUNC (subline_sdate (i)))
                  THEN
                     l_trf_dt := subline_sdate(i);
                  END IF;
                  IF ( TRUNC (subline_edate (i)) < TRUNC (l_trf_dt) )
                  THEN
                     l_trf_dt := subline_edate(i) + 1;
                     l_suppress_credit := 'Y';
                     l_full_credit := 'N';
                     l_term_flag := 'Y';
                  Else
                     IF UPPER (credit_option(i)) = 'FULL'
                     THEN
                        l_full_credit := 'Y';
                        l_suppress_credit := 'N';

                     ELSIF UPPER (credit_option(i)) = 'NONE'
                     THEN
                        l_suppress_credit := 'Y';
                     ELSIF UPPER (credit_option(i)) = 'CALCULATED'
                     THEN
                        l_suppress_credit := 'N';
                        l_full_credit := 'N';
                     End If;
                  End If;





                  fnd_file.put_line(fnd_file.log,'(OKS) -> For Subline = ( '||subline_id(i)||' ) Status = ( '
                                     ||subline_sts(i) ||' ) Transfer Date is = ( '|| l_trf_dt||' )');

                  fnd_file.put_line(fnd_file.log,'(OKS) -> Credit Option = ( '|| batch_rules_rec.credit_option
                  ||' ) Supress Credit = ( ' || l_suppress_credit || ' ) Full Credit = ( '
                  || l_full_credit || ' )');
                  okc_context.set_okc_org_context(org_id(i),organization_id(i));

                  terminate_subline
                     (p_status                    => subline_sts (i),
                      p_hdr_id                    => contract_id (i),
                      p_end_date                  => subline_edate (i),
                      p_cle_id                    => subline_id (i),
                      p_termination_date          => TRUNC (l_trf_dt),
                      p_cancellation_date         => TRUNC (l_date_cancel),
                      P_term_flag                 => l_term_flag,
                      p_terminate_reason          => batch_rules_rec.termination_reason_code,
                      p_termination_source        => l_termination_source,
                      p_suppress_credit           => l_suppress_credit,
                      p_full_credit               => l_full_credit,
                      x_return_status             => l_return_status
                     );

                  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
                  THEN
                  fnd_log.STRING (fnd_log.level_event,
                                 g_module_current || 'oks_mass_update.Update_contracts',
                                 'Terminate_subline status = ( '|| l_return_status);
                  END IF;

                  fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate_subline status = ( '|| l_return_status|| ' )');

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_ERROR',
                     'CONTRACTNUMBER',
                       CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i)

                     );

                     RAISE g_exception_halt_validation;
                  END IF;

               END LOOP;
            END IF;


          --Terminate/Cancel the TOpl Line/Header if all the sublines/Lines are terminated/Canceled.
          Terminate_cancel
         (p_termination_reason  => batch_rules_rec.termination_reason_code ,
          P_termcancel_source   => 'IBTRANSFER',
          p_cancel_reason       => 'TRANSFER',
          X_return_status       => l_return_status,
          X_msg_count           => x_msg_count,
          X_msg_data            => x_msg_data);


          fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate/cancel Line/Hdr status = ( '|| l_return_status|| ' )');

          IF NOT l_return_status = okc_api.g_ret_sts_success
          THEN
                    x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_CANCEL_ERROR'
                     );
                  RAISE g_exception_halt_validation;
          END IF;
   -- Insert into Instance History and Details

            -- Create instance History
            INSERT INTO oks_instance_history
                        (ID,
                         object_version_number,
                         instance_id,
                         transaction_type,
                         transaction_date,
                         reference_number,
                         PARAMETERS,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login,
                         batch_id
                        )
               (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                       1,
                       b.instance_id,
                       'TRF',
                       a.transaction_date,
                       b.instance_number,
                       NULL,                                      -- parameter
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.login_id,
                       p_batch_id
                  FROM oks_instance_temp a,
                       csi_item_instances b
                 WHERE a.old_customer_product_id = b.instance_id);

         fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Created  ');
         --Set Variable to identify Instance history record is created to avoid duplicates.
          l_instance_history_created := 'Y';
            -- create instance history details


            FORALL i IN subline_id.FIRST .. subline_id.LAST
               INSERT INTO oks_inst_hist_details
                           (ID,
                            ins_id,
                            transaction_date,
                            transaction_type,
                            instance_id_new,
                            instance_qty_old,
                            instance_qty_new,
                            instance_amt_old,
                            instance_amt_new,
                            old_contract_id,
                            old_contact_start_date,
                            old_contract_end_date,
                            new_contract_id,
                            new_contact_start_date,
                            new_contract_end_date,
                            old_service_line_id,
                            old_service_start_date,
                            old_service_end_date,
                            new_service_line_id,
                            new_service_start_date,
                            new_service_end_date,
                            old_subline_id,
                            old_subline_start_date,
                            old_subline_end_date,
                            new_subline_id,
                            new_subline_start_date,
                            new_subline_end_date,
                            old_customer,
                            new_customer,
                            old_k_status,
                            new_k_status,
                            subline_date_terminated,
                            object_version_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            Date_Cancelled,
                            transfer_option

                           )
                           (SELECT
                           okc_p_util.raw_to_number (SYS_GUID ()),
                            ins_hist.id  ,
                            transaction_date(1),
                            'TRF',
                            custprod_id (i),
                            number_of_items (i),
                            number_of_items (i),
                            price_negotiated (i),
                            lines_b.PRICE_NEGOTIATED ,
                            contract_id (i),
                            hdr_sdt (i),
                            hdr_edt (i),
                            contract_id (i),
                            hdr_sdt (i),
                            hdr_edt (i),
                            topline_id(i),
                            topline_sdate (i),
                            topline_edate (i),
                            topline_id (i),
                            topline_sdate(i),
                            topline_edate (i),
                            subline_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            subline_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            p_old_acct_id, --  old_customer,
                            p_old_acct_id, --  new_customer,
                            hdr_sts (i),
                            hdr.sts_code,
                            lines_b.date_terminated,  -- subline_date_terminated,
                            1,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id,
                            lines_b.date_cancelled, --Date cancelled,
                            'TERM'
                            from oks_instance_history ins_hist,
                               Okc_k_lines_b lines_b,
                               okc_k_headers_all_b hdr
                                Where   ins_hist.batch_id = p_batch_id
                             and instance_id = custprod_id(i) and  lines_b.id = subline_id (i)
                             And hdr.id =contract_id (i) )       ;

           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Details created successfully');


            END IF;
         END IF;

         IF    batch_rules_rec.transfer_option = 'TRANSFER'
            OR batch_rules_rec.transfer_option = 'COVERAGE'
         THEN

            OPEN get_k_for_transfer_csr (batch_rules_rec.transfer_option,
                                         l_relationship,
                                         batch_rules_rec.new_party_id,
                                         batch_rules_rec.credit_option
                                        );

            IF get_k_for_transfer_csr%ISOPEN
            THEN
               FETCH get_k_for_transfer_csr
               BULK COLLECT INTO contract_id,
                      hdr_sdt,
                      hdr_edt,
                      hdr_sts,
                      hdr_ste,
                      contract_number,
                      contract_number_modifier,
                      topline_id,
                      topline_sdate,
                      topline_edate,
                      subline_id,
                      subline_old_sdate,
                      subline_sdate,
                      subline_edate,
                      new_contract_id,
                      new_line_id,
                      new_subline_id,
                      subline_sts,
                      trf_date,
                      custprod_id,
                      price_negotiated,
                      price_unit,
                      number_of_items,
                      hdr_warranty,
                      transaction_date,
                      party_id,
                      org_id,
                      credit_option,
                      organization_id;
            END IF;

            CLOSE get_k_for_transfer_csr;

            fnd_file.put_line(fnd_file.log,'(OKS) -> Transfer/Coverage: Number of impacted contracts = ( '
            || contract_id.COUNT || ' )');

            IF contract_id.count > 0
            THEN
            FOR i IN 1..subline_sts.COUNT
            LOOP
            IF hdr_ste(i) = 'HOLD'
            THEN
                l_found := TRUE;
                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.oks_mass_update.Update_contracts',
                   ' Contract '||contract_number(i) ||' in QA_HOLD status' );
                END IF;


                OKC_API.SET_MESSAGE(
                g_app_name,
                'OKS_CONTRACT_HOLD',
                'CONTRACTNUMBER',
                CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i)
                );

            END IF;
            END LOOP;

            IF l_found
            THEN
                l_return_status  := OKC_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            Delete  Oks_Instance_k_dtls_temp where parent_id = p_batch_id;

            FORALL i IN contract_id.FIRST .. contract_id.LAST
               INSERT INTO oks_instance_k_dtls_temp
                           (parent_id,
                            contract_id,
                            topline_id,
                            subline_id,
                            new_contract_id,
                            new_serviceline_id,
                            new_subline_id,
                            instance_id,
                            new_start_date,
                            new_end_date,
                            amount
                           )
                    VALUES (p_batch_id,
                            contract_id (i),
                            topline_id (i),
                            subline_id (i),
                            new_contract_id (i),
                            new_line_id (i),
                            new_subline_id (i),
                            custprod_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            price_negotiated (i)
                           );
            fnd_file.put_line(fnd_file.log,'(OKS) -> Insert into global temp table Successful');

            -- Terminate/Cancel all the eligible lines


            fnd_file.put_line(fnd_file.log,'(OKS) -> **********Terminate All the impacted Sublines ********** ');

            FOR i IN 1 .. subline_id.COUNT
            LOOP
                  l_trf_dt := trf_date (i);
                  l_date_cancel := trf_date(i);
                  l_term_flag   := 'N';
                  IF (TRUNC (l_date_cancel) <= TRUNC (subline_old_sdate (i)))
                  Then
                       l_date_cancel := subline_old_sdate(i);
                  Elsif ( TRUNC (l_date_cancel)  > TRUNC (subline_edate (i))  )
                  Then
                       l_date_cancel := subline_edate(i) + 1;
                  End If;

                  IF    (TRUNC (l_trf_dt) <= TRUNC (subline_old_sdate (i)))
                  THEN
                     l_trf_dt := subline_old_sdate(i);
                  END IF;

                  IF ( TRUNC (subline_edate (i)) < TRUNC (l_trf_dt) )
                  THEN
                     l_trf_dt := subline_edate(i) + 1;
                     l_suppress_credit := 'Y';
                     l_full_credit := 'N';
                     l_term_flag   := 'Y';
                  ELse
                     IF UPPER (credit_option(i)) = 'FULL'
                     THEN
                        l_full_credit := 'Y';
                        l_suppress_credit := 'N';

                     ELSIF UPPER (credit_option(i)) = 'NONE'
                     THEN
                        l_suppress_credit := 'Y';
                     ELSIF UPPER (credit_option(i)) = 'CALCULATED'
                     THEN
                        l_suppress_credit := 'N';
                        l_full_credit := 'N';
                     End If;
                   End If;




               fnd_file.put_line(fnd_file.log,'(OKS) -> For Subline = ( '||subline_id(i)||' ) Status = ( '
                                  ||subline_sts(i) ||' ) Transfer Date is = ( '|| l_trf_dt || ' )');

               fnd_file.put_line(fnd_file.log,'(OKS) -> Credit Option = ( '|| batch_rules_rec.credit_option
               ||' ) Supress Credit = ( ' || l_suppress_credit || ' ) Full Credit = ( '
               || l_full_credit|| ' )');
               okc_context.set_okc_org_context(org_id(i),organization_id(i));

               terminate_subline
                  (p_status                    => subline_sts (i),
                   p_hdr_id                    => contract_id (i),
                   p_end_date                  => subline_edate (i),
                   p_cle_id                    => subline_id (i),
                   p_termination_date          => TRUNC (l_trf_dt),
                   p_cancellation_date          => TRUNC (l_date_cancel),
                   p_term_flag                  => l_term_flag,
                   p_terminate_reason          => batch_rules_rec.termination_reason_code,
                   p_termination_source        => l_termination_source,
                   p_suppress_credit           => l_suppress_credit,
                   p_full_credit               => l_full_credit,
                   x_return_status             => l_return_status
                  );

               fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate_subline status = ( '|| l_return_status|| ' )');

               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
               fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.Update_contracts',
                             'Terminate_subline status = ( '|| l_return_status);
               END IF;

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_ERROR',
                     'CONTRACTNUMBER',
                       CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i),
                     'SUBLINE',
                     subline_id (i)
                     );
                  RAISE g_exception_halt_validation;
               END IF;
            END LOOP;





            fnd_file.put_line(fnd_file.log,'(OKS) -> *****************Create New Contracts****************');

            -- Create new contract
            create_contract (p_api_version        => 1.0,
                             p_batch_rules        => batch_rules_rec,
                             P_transfer_date      => trf_date(1),
                             x_return_status      => l_return_status,
                             x_msg_data           => x_msg_data,
                             x_msg_count          => x_msg_count
                            );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
            fnd_log.STRING (fnd_log.level_event,
                             g_module_current || 'oks_mass_update.Update_contracts',
                             'create_contract status = ( '|| l_return_status || ')');
            END IF;

            fnd_file.put_line(fnd_file.log,'(OKS) -> Create contracts Status = ( '|| l_return_status|| ' )');

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               x_return_status := l_return_status;

               RAISE g_exception_halt_validation;
            END IF;

            -- Update the topline amount
            FORALL i IN 1 .. new_line_id.COUNT
               UPDATE okc_k_lines_b
                  SET price_negotiated =
                         (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                            FROM okc_k_lines_b
                           WHERE cle_id = new_line_id (i)
                             AND lse_id IN (9, 25))
                WHERE ID = new_line_id (i);

            fnd_file.put_line(fnd_file.log,'(OKS) -> Topline amounts updated successfully');

            -- Update the contract amount
            FORALL i IN 1 .. new_contract_id.COUNT
               UPDATE okc_k_headers_all_b
                  SET estimated_amount =
                         (SELECT NVL (SUM (NVL (price_negotiated, 0)), 0)
                            FROM okc_k_lines_b
                           WHERE dnz_chr_id = new_contract_id (i)
                             AND lse_id IN (1, 19))
                WHERE ID = new_contract_id (i);

            fnd_file.put_line(fnd_file.log,'(OKS) -> Header amounts updated successfully');

          --Terminate/Cancel the TOpl Line/Header if all the sublines/Lines are terminated/Canceled.
          Terminate_cancel
         (p_termination_reason  => batch_rules_rec.termination_reason_code,
          P_termcancel_source   => 'IBTRANSFER',
          p_cancel_reason       => 'TRANSFER',
          X_return_status       => l_return_status,
          X_msg_count           => x_msg_count,
          X_msg_data            => x_msg_data);

          fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate/cancel Line/Hdr status = ( '|| l_return_status|| ' )');

          IF NOT l_return_status = okc_api.g_ret_sts_success
          THEN
                    x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_CANCEL_ERROR'
                     );
                  RAISE g_exception_halt_validation;
          END IF;


            l_gl_dummy := 0;

            fnd_file.put_line(fnd_file.log,'(OKS) -> Create transfer Transaction Source');

            -- create 'transfer' transaction source
            FOR i IN 1 .. new_subline_id.COUNT
            LOOP

            IF new_subline_id(i) IS NOT NULL
            THEN
               create_transaction_source
                                      (p_batch_id            => p_batch_id,
                                       p_source_line_id      => subline_id (i),
                                       p_target_line_id      => new_subline_id (i),
                                       p_source_chr_id       => contract_id (i),
                                       p_target_chr_id       => new_contract_id(i),
                                       p_transaction         => 'TRANSFER',
                                       x_return_status       => l_return_status,
                                       x_msg_count           => l_msg_count,
                                       x_msg_data            => l_msg_data
                                      );
               IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
               THEN
               fnd_log.STRING (fnd_log.level_event,
                                 g_module_current || 'oks_mass_update.Update_contracts',
                                 'create_transaction_source(transfer) status = ( '|| l_return_status || ')');
               END IF;

               fnd_file.put_line(fnd_file.log,'(OKS) -> Create transfer transaction source ( '
                                  ||i||' )' || 'status = ( ' || l_return_status ||' )');

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                  RAISE g_exception_halt_validation;
               END IF;
            END IF;

            END LOOP;

            fnd_file.put_line(fnd_file.log,'(OKS) -> Create Renewal Transaction Source');

            -- create 'Renewal'transaction source
            FOR i IN 1 .. new_subline_id.COUNT
            LOOP
            IF new_subline_id(i) IS NOT NULL
            THEN
--             l_object_line_id := get_object_line_id (subline_id (i));

               get_object_line_id(subline_id (i),l_object_line_id,l_object_chr_id);

               IF l_object_line_id IS NOT NULL
               THEN
                  --Oks_Ib_Util_Pub.
                  create_transaction_source
                                      (p_batch_id            => p_batch_id,
                                       p_source_line_id      => l_object_line_id,
                                       p_target_line_id      => new_subline_id (i),
                                       p_source_chr_id       => l_object_chr_id,
                                       p_target_chr_id       => new_contract_id(i),
                                       p_transaction         => 'RENEWAL',
                                       x_return_status       => l_return_status,
                                       x_msg_count           => l_msg_count,
                                       x_msg_data            => l_msg_data
                                      );

                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
                  THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current || 'oks_mass_update.Update_contracts',
                                     'create_transaction_source (Renewal) status = ( '|| l_return_status || ')');
                  END IF;

                  fnd_file.put_line(fnd_file.log,'(OKS) -> Create renewal transaction source ( '
                                     ||i||' )' || 'status = ( '|| l_return_status || ' )');

                  IF NOT l_return_status = okc_api.g_ret_sts_success
                  THEN
                     x_return_status := l_return_status;

                     RAISE g_exception_halt_validation;
                  END IF;
                 Update okc_k_lines_b set date_renewed = trf_date(1)
                  Where id =  l_object_line_id
                  And date_renewed is null;

                  L_line_date_renewed := OKS_IB_UTIL_PVT.Check_renewed_Sublines(l_object_line_id);
                  Update okc_k_lines_b set date_renewed = l_line_date_renewed
                  Where id = (select cle_id from okc_k_lines_b where id = l_object_line_id)
                  And date_renewed Is Null;

                  l_hdr_date_renewed := OKS_IB_UTIL_PVT.Check_renewed_lines(l_object_line_id);
                  Update okc_k_headers_all_b set date_renewed = l_line_date_renewed
                  Where id = (select dnz_chr_id from okc_k_lines_b where id = l_object_line_id)
                  And date_renewed Is Null;




               END IF;
            END IF;
            END LOOP;

           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History created successfully');

               -- Insert into Instance History and Details
            If l_instance_history_created = 'N' Then
            -- Create instance History
            INSERT INTO oks_instance_history
                        (ID,
                         object_version_number,
                         instance_id,
                         transaction_type,
                         transaction_date,
                         reference_number,
                         PARAMETERS,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login,
                         batch_id
                        )
               (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                       1,
                       b.instance_id,
                       'TRF',
                       a.transaction_date,
                       b.instance_number,
                       NULL,                                      -- parameter
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.login_id,
                       p_batch_id
                  FROM oks_instance_temp a,
                       csi_item_instances b
                 WHERE a.old_customer_product_id = b.instance_id);

          End If;
            -- create instance history details
fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History created successfully');

            FORALL i IN subline_id.FIRST .. subline_id.LAST
               INSERT INTO oks_inst_hist_details
                           (ID,
                            ins_id,
                            transaction_date,
                            transaction_type,
                            instance_id_new,
                            instance_qty_old,
                            instance_qty_new,
                            instance_amt_old,
                            instance_amt_new,
                            old_contract_id,
                            old_contact_start_date,
                            old_contract_end_date,
                            new_contract_id,
                            new_contact_start_date,
                            new_contract_end_date,
                            old_service_line_id,
                            old_service_start_date,
                            old_service_end_date,
                            new_service_line_id,
                            new_service_start_date,
                            new_service_end_date,
                            old_subline_id,
                            old_subline_start_date,
                            old_subline_end_date,
                            new_subline_id,
                            new_subline_start_date,
                            new_subline_end_date,
                            old_customer,
                            new_customer,
                            old_k_status,
                            new_k_status,
                            subline_date_terminated,
                            object_version_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            Date_Cancelled
                           )
                          (Select okc_p_util.raw_to_number (SYS_GUID ()),
                            inshist.id ,
                            transaction_date(i),
                            'TRF',
                            custprod_id (i),
                            number_of_items (i),
                            number_of_items (i),
                            price_negotiated (i),
                            Line.PRICE_NEGOTIATED ,
                            contract_id (i),
                            hdr_sdt (i),
                            hdr_edt (i),
                            contract_id (i),
                            hdr_sdt (i),
                            hdr_edt (i),
                            topline_id(i),
                            topline_sdate (i),
                            topline_edate (i),
                            topline_id (i),
                            topline_sdate(i),
                            topline_edate (i),
                            subline_id (i),
                            subline_old_sdate (i),
                            subline_edate (i),
                            subline_id (i),
                            subline_old_sdate (i),
                            subline_edate (i),
                            p_old_acct_id,--  old_customer,
                            p_old_acct_id,  --  new_customer
                            hdr_sts (i),
                            hdr.sts_code,
                            line.date_terminated,  -- subline_date_terminated,
                            1,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id,
                            line.date_cancelled  --Date cancelled
                            from Oks_instance_history inshist, Okc_k_lines_b line
                            ,okc_k_headers_all_b hdr
                            Where inshist.instance_id = custprod_id(i)
                            and batch_id = p_batch_id
                            And line.id = subline_id(i)
                            And hdr.id = contract_id(i)
                           );
           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Details created successfully');
            -- create instance history details
            /*OPEN get_inst_hist_csr (p_batch_id);

            FETCH get_inst_hist_csr
            BULK COLLECT INTO ins_id,
                   new_k_sdate,
                   new_k_edate,
                   new_k_status,
                   new_l_sdate,
                   new_l_edate,
                   new_price_negotiated;
                   --ins_id;

            CLOSE get_inst_hist_csr;
*/
            FORALL i IN new_subline_id.FIRST .. new_subline_id.LAST
               INSERT INTO oks_inst_hist_details
                           (ID,
                            ins_id,
                            transaction_date,
                            transaction_type,
                            instance_id_new,
                            instance_qty_old,
                            instance_qty_new,
                            instance_amt_old,
                            instance_amt_new,
                            old_contract_id,
                            old_contact_start_date,
                            old_contract_end_date,
                            new_contract_id,
                            new_contact_start_date,
                            new_contract_end_date,
                            old_service_line_id,
                            old_service_start_date,
                            old_service_end_date,
                            new_service_line_id,
                            new_service_start_date,
                            new_service_end_date,
                            old_subline_id,
                            old_subline_start_date,
                            old_subline_end_date,
                            new_subline_id,
                            new_subline_start_date,
                            new_subline_end_date,
                            old_customer,
                            new_customer,
                            old_k_status,
                            new_k_status,
                            subline_date_terminated,
                            object_version_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login
                           )
                           (Select okc_p_util.raw_to_number (SYS_GUID ()),
                            inshist.id,
                            transaction_date(i),
                            'TRF',
                            custprod_id (i),
                            number_of_items (i),
                            number_of_items (i),
                            price_negotiated (i),
                            subline.price_negotiated,--new_price_negotiated (i),
                            contract_id (i),
                            hdr_sdt (i),
                            hdr_edt (i),
                            new_contract_id (i),
                            hdr.start_date,--new_k_sdate (i),
                            hdr.end_date,--new_k_edate (i),
                            topline_id (i),
                            topline_sdate (i),
                            topline_edate (i),
                            new_line_id (i),
                            line.start_date,--new_l_sdate (i),
                            line.end_date,--new_l_edate (i),
                            subline_id (i),
                            subline_old_sdate (i),
                            subline_edate (i),
                            new_subline_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            p_old_acct_id,                            --  old_customer,
                            p_new_acct_id,                            --  new_customer,
                            hdr_sts (i),
                            hdr.sts_code,--new_k_status (i),
                            NULL,                  -- subline_date_terminated,
                            1,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id
                            from Oks_instance_history inshist
                               , okc_k_headers_all_b hdr
                               , okc_k_lines_b line
                               , okc_k_lines_b subline
                            Where inshist.instance_id = custprod_id(i)
                            and batch_id = p_batch_id
                            and hdr.id = new_contract_id(i)
                            and line.id = new_line_id(i)
                            and subline.id = new_subline_id(i)

                           );
           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Details created successfully');

         END IF;
         END IF;                                            -- End contract_id.count>0
      END IF;                                               -- End 'Trf' batch

      -- General Batch
      IF p_batch_type in ('GEN','MOVE') --'CSI_MU_GENERAL'
      THEN
         l_return_status := OKC_API.G_RET_STS_SUCCESS;
         fnd_file.put_line(fnd_file.log,'(OKS) -> General Batch Processing');

         OPEN get_k_for_idc_csr;

         IF get_k_for_idc_csr%ISOPEN
         THEN
            FETCH get_k_for_idc_csr
            BULK COLLECT INTO contract_id,
                   topline_id,
                   subline_id,
                   hdr_sdt,
                   hdr_edt,
                   hdr_sts,
                   topline_sdate,
                   topline_edate,
                   topline_sts,
                   subline_sdate,
                   subline_edate,
                   subline_sts,
                   idc_date,
                   new_edt,
                   number_of_items,
                   transaction_date,
                   custprod_id,
                   ContractNumber_modifier,
                   line_number,
                   sr_date

                   ;
         END IF;

         CLOSE get_k_for_idc_csr;

         FORALL i IN contract_id.FIRST .. contract_id.LAST
               INSERT INTO oks_instance_k_dtls_temp
                           (parent_id,
                            contract_id,
                            topline_id,
                            subline_id,
                            new_start_date,
                            new_end_date,
                            instance_id
                           )
                     (Select p_batch_id,
                            contract_id (i),
                            topline_id (i),
                            subline_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            custprod_id (i)
                            from dual
                            Where TRUNC (nvl(sr_date (i),idc_date (i))) >= TRUNC (idc_date (i))
                                    OR TRUNC (nvl(sr_date (i),new_edt (i))) <= TRUNC (new_edt (i))
                           );

     -- Log Warning messages if any
         FOR i IN 1..subline_id.count
         LOOP
              IF idc_date(i) IS NULL
              THEN
                   l_return_status := OKC_API.G_RET_STS_WARNING;
                   IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.IB_INTERFACE',
                        'Installation date changed to null ' );
                   End If;
                   OKC_API.set_message(G_APP_NAME,'OKS_NULL_INSTALLATION_DATE');
                   Raise G_EXCEPTION_HALT_VALIDATION;

              END IF;
              If sr_date(i) Is Not Null Then
                 IF (trunc(sr_date(i)) <= trunc(idc_date(i))
                     OR TRUNC(sr_date(i)) >= TRUNC(new_edt(i)))
                 THEN
                     l_Warn_return_status := OKC_API.G_RET_STS_WARNING;
                     OKC_API.set_message(G_APP_NAME,'OKS_SR_EXISTS_FOR_CONTRACT'
                                        ,'CONTRACTNUMBER',COntractnumber_modifier(i)
                                        ,'CONTRACTLINE',line_number(i)
                                        ,'INSTANCE',custprod_id (i)
                                       );

                     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.UPDATE_CONTRACT_IDC.ERROR',
                       'SR is logged '||',status = ' ||  l_return_status);
                     END IF;


                 END IF;
              End If;

         END LOOP;

         -- Update Subline dates
         FORALL i IN 1 .. subline_id.COUNT
            UPDATE okc_k_lines_b
               SET start_date = idc_date (i),
                   end_date = new_edt (i),
                   sts_code = get_status (idc_date (i), new_edt (i))

             WHERE ID = subline_id(i)
             And (trunc(nvl(sr_date(i),idc_date(i))) >= trunc(idc_date(i))
                 And TRUNC(nvl(sr_date(i),new_edt(i))) <= TRUNC(new_edt(i)));

            Open l_subline_invtext_csr;
            Fetch l_subline_invtext_csr Bulk collect into
                  sub_line_id,
                  inv_text;
            Close l_subline_invtext_csr;

            Forall i in 1..sub_line_id.count
            UPDATE oks_k_lines_v
            SET    invoice_text = inv_text(i)
            WHERE  id = (select id from oks_k_lines_b
            where cle_id = sub_line_id(i));



         -- Update topline dates
            Open l_topline_csr;
            Fetch l_topline_csr Bulk collect into
                  Top_line_id,
                  line_new_Sdate,
                  Line_new_edate;

            Close l_topline_csr;

            Forall i in 1..top_line_id.count
            UPDATE okc_k_lines_b
               SET start_date = line_new_Sdate (i),
                   end_date = line_new_edate (i),
                   sts_code = get_status (line_new_Sdate(i), line_new_edate(i))
                   --invoice_text = inv_text(i)
            WHERE ID = top_line_id(i);

            Top_line_id.delete;

            Open l_invoice_text_csr;
            Fetch l_invoice_text_csr Bulk collect into
                  top_line_id,
                  inv_text;
            Close l_invoice_text_csr;

            Forall i in 1..top_line_id.count
            UPDATE oks_k_lines_tl
            SET    invoice_text = inv_text(i)
            WHERE  id = (select id from oks_k_lines_b
            where cle_id = top_line_id(i));
         -- Update Header dates
            header_id.delete;
            Open l_Contract_csr;
            Fetch l_Contract_csr Bulk collect into
                  Header_id,
                  Hdr_new_Sdate,
                  Hdr_new_edate;
            Close l_Contract_csr;

             FORALL i IN 1 .. header_id.COUNT
            UPDATE okc_k_headers_all_b
               SET start_date = Hdr_new_Sdate(i),
                   end_date = Hdr_new_edate(i),
                   sts_code = get_status (Hdr_new_Sdate(i), Hdr_new_edate(i))
             WHERE ID = header_id(i);


           --Update status in contacts table
           /*cgopinee bugfix for 6882512*/
            FORALL i IN 1 .. header_id.COUNT
             UPDATE okc_contacts
	     SET dnz_ste_code =get_ste_code(get_status (Hdr_new_Sdate(i), Hdr_new_edate(i)))
             WHERE dnz_chr_id=header_id(i);

         -- Create records in version history table OKC_K_VERS_NUMBERS_H

         If header_id.count > 0
         Then
         FORALL i IN header_id.first .. header_id.last
            INSERT INTO OKC_K_VERS_NUMBERS_H (
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
            )
            (
             SELECT max(chr_id ),
                max(major_version) major_version,
                max(minor_version)  minor_version,
                max(object_version_number) object_version_number
                , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.login_id
                FROM OKC_K_VERS_NUMBERS
                WHERE chr_id = header_id(i)
              );
           End If;
         -- Update the minor version and object version numbers
         FORALL i IN 1 .. header_id.COUNT
            UPDATE OKC_K_VERS_NUMBERS
               SET minor_version = minor_version+1,
                   object_version_number = object_version_number+1
             WHERE chr_ID = header_id(i);

         -- Update coverage effectivity
           FOR i in 1..top_line_id.count
            LOOP

               oks_pm_programs_pvt.ADJUST_PM_PROGRAM_SCHEDULE(
                     p_api_version	            => 1.0,
                     p_init_msg_list            => 'F',
                     p_contract_line_id         => top_line_id(i) ,
                     p_new_start_date           => line_new_Sdate(i),
                     p_new_end_date             => line_new_edate(i),
                     x_return_status            => l_return_status,
                     x_msg_count                => x_msg_count,
                     x_msg_data                 => x_msg_data );

              IF NOT l_return_status = 'S' THEN


                    x_return_status := l_return_status;

                    OKC_API.SET_MESSAGE(
                         g_app_name,
                         g_required_value,
                         g_col_name_token,
                         'Adjust PM Program Schedule(SUB LINE)'
                     );

                    RAISE G_EXCEPTION_HALT_VALIDATION;
              End If;

            END LOOP;


         If header_id.COUNT > 0 Then
          -- Create instance History
            INSERT INTO oks_instance_history
                        (ID,
                         object_version_number,
                         instance_id,
                         transaction_type,
                         transaction_date,
                         reference_number,
                         PARAMETERS,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login,
                         batch_id
                        )
               (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                       1,
                       b.instance_id,
                       'IDC',
                       transaction_date (1),
                       b.instance_number,
                       NULL,                                      -- parameter
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.login_id,
                       p_batch_id
                  FROM oks_instance_k_dtls_temp a,
                       csi_item_instances b
                 WHERE a.instance_id = b.instance_id);

           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History created successfully');

            --- create instance history details
            FORALL i IN subline_id.FIRST .. subline_id.LAST
               INSERT INTO oks_inst_hist_details
                           (ID,
                            ins_id,
                            transaction_date,
                            transaction_type,
                            instance_id_new,
                            instance_qty_old,
                            instance_qty_new,
                            instance_amt_old,
                            instance_amt_new,
                            old_contract_id,
                            old_contact_start_date,
                            old_contract_end_date,
                            new_contract_id,
                            new_contact_start_date,
                            new_contract_end_date,
                            old_service_line_id,
                            old_service_start_date,
                            old_service_end_date,
                            new_service_line_id,
                            new_service_start_date,
                            new_service_end_date,
                            old_subline_id,
                            old_subline_start_date,
                            old_subline_end_date,
                            new_subline_id,
                            new_subline_start_date,
                            new_subline_end_date,
                            old_customer,
                            new_customer,
                            old_k_status,
                            new_k_status,
                            subline_date_terminated,
                            object_version_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            date_cancelled
                           )
                  (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                          a.ID,
                          transaction_date (i),
                          'IDC',
                          custprod_id (i),
                          number_of_items (i),
                          number_of_items (i),
                          null,
                          null,
                          contract_id (i),
                          hdr_sdt (i),
                          hdr_edt (i),
                          contract_id (i),
                          hdr.start_date,
                          hdr.end_date,
                          topline_id (i),
                          topline_sdate (i),
                          topline_edate (i),
                          topline_id (i),
                          line.start_date,
                          line.end_date,
                          subline_id (i),
                          subline_sdate (i),
                          subline_edate (i),
                          subline_id (i),
                          subline.start_date,
                          subline.end_date,
                          p_old_acct_id,                        --  old_customer,
                          p_old_acct_id,                        --  new_customer,
                          hdr_sts (i),
                          hdr.sts_code,
                          null,                       -- subline_date_terminated,
                          1,
                          fnd_global.user_id,
                          SYSDATE,
                          fnd_global.user_id,
                          SYSDATE,
                          fnd_global.login_id,
                          null
                     FROM oks_instance_history a, Okc_k_headers_all_b hdr
                          , okc_k_lines_b line
                          , okc_k_lines_b subline
                    WHERE a.batch_id = p_batch_id
                      AND a.transaction_type = 'IDC'
                      AND a.instance_id = custprod_id(i)
                      And hdr.id = contract_id(i)
                      And line.id = topline_id (i)
                      And subline.id = subline_id (i)
                      And TRUNC (nvl(sr_date (i),idc_date (i))) >= TRUNC (idc_date (i))
                                    And TRUNC (nvl(sr_date (i),new_edt (i))) <= TRUNC (new_edt (i))
                      );
           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Details created successfully');
         End If;
      END IF;

      -- Terminate Batch
      IF p_batch_type = 'TRM' --'CSI_MU_TERMINATE'
      THEN
         fnd_file.put_line(fnd_file.log,'in term');
         OPEN get_k_for_trm_csr(batch_rules_trm_rec.credit_option);

         IF get_k_for_trm_csr%ISOPEN
         THEN
            FETCH get_k_for_trm_csr
            BULK COLLECT INTO contract_id,
                   topline_id,
                   subline_id,
                   hdr_sdt,
                   hdr_edt,
                   hdr_sts,
                   hdr_ste,
                   contract_number,
                   contract_number_modifier,
                   topline_sdate,
                   topline_edate,
                   topline_sts,
                   subline_sdate,
                   subline_edate,
                   subline_sts,
                   term_date,
                   custprod_id,
                   transaction_date,
                   number_of_items,
                   price_negotiated,
                   Party_id,
                   Org_Id,
                   Credit_option,
                   organization_id;
         END IF;

         CLOSE get_k_for_trm_csr;
         FORALL i IN contract_id.FIRST .. contract_id.LAST
         INSERT INTO oks_instance_k_dtls_temp
                           (parent_id,
                            contract_id,
                            topline_id,
                            subline_id,
                            new_start_date,
                            new_end_date,
                            instance_id
                            )
                            Values
                           ( p_batch_id,
                            contract_id (i),
                            topline_id (i),
                            subline_id (i),
                            subline_sdate (i),
                            subline_edate (i),
                            custprod_id (i)
                            );

         fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate: Number of impacted contracts = ( '
                            || contract_id.COUNT || ' )');

         -- QA HOLD lines can't be terminated
         FOR i IN 1..subline_sts.COUNT
         LOOP
            IF hdr_ste(i) = 'HOLD'
            THEN
                l_found := TRUE;
                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.oks_mass_update.Update_contracts',
                   ' Contract '||contract_number(i) ||' in QA_HOLD status' );
                END IF;

                OKC_API.SET_MESSAGE(
                       g_app_name,
                       'OKS_CONTRACT_HOLD',
                       'CONTRACTNUMBER',
                       CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i)
                       );

            END IF;
         END LOOP;

         IF l_found
         THEN
                l_return_status  := OKC_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;




         IF subline_id.COUNT > 0
         THEN
            FOR i IN subline_id.FIRST .. subline_id.LAST
            LOOP

                  fnd_file.put_line(fnd_file.log,'(OKS) -> For Subline term_date '||term_date (i)||subline_edate(i)||subline_sdate(i));
                  l_trm_dt := term_date (i);
                  l_date_cancel :=  term_date(i);
                  l_term_flag:= 'N';
                  IF (TRUNC (l_date_cancel) <= TRUNC (subline_sdate (i)))
                  Then
                       l_date_cancel := subline_sdate(i);
                  Elsif ( TRUNC (subline_edate (i)) < TRUNC (l_date_cancel) )
                  Then
                       l_date_cancel := subline_edate(i) + 1;
                  End If;



                  IF    (TRUNC (l_trm_dt) <= TRUNC (subline_sdate (i)))

                  THEN
                     l_trm_dt := subline_sdate(i);
                  END IF;

                  IF ( TRUNC (subline_edate (i))< TRUNC (l_trm_dt) )
                  THEN
                     l_trm_dt := subline_edate(i) + 1;
                     l_suppress_credit := 'Y';
                     l_full_credit := 'N';
                     l_term_flag := 'Y';
                 Else

                     IF UPPER (credit_option(i)) = 'FULL'
                     THEN
                        l_full_credit := 'Y';
                        l_suppress_credit := 'N';

                     ELSIF UPPER (credit_option(i)) = 'NONE'
                     THEN
                        l_suppress_credit := 'Y';
                     ELSIF UPPER (credit_option(i)) = 'CALCULATED'
                     THEN
                        l_suppress_credit := 'N';
                        l_full_credit := 'N';
                     End If;
                   End If;

              fnd_file.put_line(fnd_file.log,'(OKS) -> For Subline = ( '||subline_id (i)||'l_full_credit'||l_full_credit);


               fnd_file.put_line(fnd_file.log,'(OKS) -> For Subline = contract_number ( '||contract_number(i)||':'||contract_number_modifier(i)||' ) l_suppress_credit = ( '
                                  ||l_suppress_credit ||' ) Termination Date is = ( '|| l_trm_dt|| ' )');
               okc_context.set_okc_org_context(org_id(i),organization_id(i));
               terminate_subline
                  (p_status                    => subline_sts (i),
                   p_hdr_id                    => contract_id (i),
                   p_end_date                  => subline_edate (i),
                   p_cle_id                    => subline_id (i),
                   p_termination_date          => TRUNC (l_trm_dt),
                   p_cancellation_date         => trunc(l_date_cancel),
                   p_term_flag                 => l_term_flag,
                   p_terminate_reason          => batch_rules_trm_rec.termination_reason_code,
                   p_termination_source        => 'IBTERMINATE',
                   p_suppress_credit           => l_suppress_credit,
                   p_full_credit               => l_full_credit,
                   x_return_status             => l_return_status
                  );

               fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate_subline status = ( '|| l_return_status|| ' )');

               IF NOT l_return_status = okc_api.g_ret_sts_success
               THEN
                  x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_ERROR',
                     'CONTRACTNUMBER',
                       CONTRACT_NUMBER(i)||' '||CONTRACT_NUMBER_MODIFIER(i),
                     'SUBLINE',
                     subline_id (i)
                     );
                  RAISE g_exception_halt_validation;
               END IF;

            END LOOP;

          --Terminate/Cancel the TOpl Line/Header if all the sublines/Lines are terminated/Canceled.
          Terminate_cancel
         (p_termination_reason  => batch_rules_trm_rec.termination_reason_code ,
          P_termcancel_source   => 'IBTERMINATE',
          p_cancel_reason       => 'TERMINATED',
          X_return_status       => l_return_status,
          X_msg_count           => x_msg_count,
          X_msg_data            => x_msg_data);

          fnd_file.put_line(fnd_file.log,'(OKS) -> Terminate/cancel Line/Hdr status = ( '|| l_return_status|| ' )');

          IF NOT l_return_status = okc_api.g_ret_sts_success
          THEN
                    x_return_status := l_return_status;
                     OKC_API.SET_MESSAGE
                    (
                     g_app_name,
                     'OKS_TERMINATE_CANCEL_ERROR'
                     );
                  RAISE g_exception_halt_validation;
          END IF;

            -- Create instance History
            INSERT INTO oks_instance_history
                        (ID,
                         object_version_number,
                         instance_id,
                         transaction_type,
                         transaction_date,
                         reference_number,
                         PARAMETERS,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login,
                         batch_id
                        )
               (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                       1,
                       b.instance_id,
                       'TRM',
                       transaction_date (1),
                       b.instance_number,
                       NULL,                                      -- parameter
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.login_id,
                       p_batch_id
                  FROM oks_instance_temp a,
                       csi_item_instances b
                 WHERE a.old_customer_product_id = b.instance_id);

           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History created successfully');

            --- create instance history details
            FORALL i IN subline_id.FIRST .. subline_id.LAST
               INSERT INTO oks_inst_hist_details
                           (ID,
                            ins_id,
                            transaction_date,
                            transaction_type,
                            instance_id_new,
                            instance_qty_old,
                            instance_qty_new,
                            instance_amt_old,
                            instance_amt_new,
                            old_contract_id,
                            old_contact_start_date,
                            old_contract_end_date,
                            new_contract_id,
                            new_contact_start_date,
                            new_contract_end_date,
                            old_service_line_id,
                            old_service_start_date,
                            old_service_end_date,
                            new_service_line_id,
                            new_service_start_date,
                            new_service_end_date,
                            old_subline_id,
                            old_subline_start_date,
                            old_subline_end_date,
                            new_subline_id,
                            new_subline_start_date,
                            new_subline_end_date,
                            old_customer,
                            new_customer,
                            old_k_status,
                            new_k_status,
                            subline_date_terminated,
                            object_version_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            date_cancelled
                           )
                  (SELECT okc_p_util.raw_to_number (SYS_GUID ()),
                          a.ID,
                          transaction_date (i),
                          'TRM',
                          custprod_id (i),
                          number_of_items (i),
                          number_of_items (i),
                          price_negotiated (i),
                          price_negotiated (i),
                          contract_id (i),
                          hdr_sdt (i),
                          hdr_edt (i),
                          contract_id (i),
                          hdr_sdt (i),
                          hdr_edt (i),
                          topline_id (i),
                          topline_sdate (i),
                          topline_edate (i),
                          topline_id (i),
                          topline_sdate (i),
                          topline_edate (i),
                          subline_id (i),
                          subline_sdate (i),
                          subline_edate (i),
                          subline_id (i),
                          subline_sdate (i),
                          subline_edate (i),
                          p_old_acct_id,                        --  old_customer,
                          p_old_acct_id,                        --  new_customer,
                          hdr_sts (i),
                          hdr.sts_code,
                          line.date_terminated,                       -- subline_date_terminated,
                          1,
                          fnd_global.user_id,
                          SYSDATE,
                          fnd_global.user_id,
                          SYSDATE,
                          fnd_global.login_id,
                          line.date_cancelled
                     FROM oks_instance_history a,
                          Okc_k_lines_b line,
                          Okc_k_headers_all_b hdr
                    WHERE a.batch_id = p_batch_id
                      AND a.transaction_type = 'TRM'
                      AND a.instance_id = custprod_id(i)
                      AND line.id = subline_id(i)
                      And hdr.id = contract_id(i));
           fnd_file.put_line(fnd_file.log,'(OKS) -> Instance History Details created successfully');

         END IF;





      END IF;


      If l_warn_return_status = 'W' Then
         x_return_status := l_warn_return_status;
      Else

        x_return_status := l_return_status;
      End If;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := okc_api.g_ret_sts_error;
         fnd_file.put_line(fnd_file.log,' Error while updating the contract ' );
         FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);

         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         fnd_file.put_line(fnd_file.log,' Error while updating the contract : '
         || SQLCODE||':'|| SQLERRM );
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
         FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);

   END;-- End Update Contracts
END;


/
