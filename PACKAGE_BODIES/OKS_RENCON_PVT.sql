--------------------------------------------------------
--  DDL for Package Body OKS_RENCON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENCON_PVT" AS
/* $Header: OKSRENCB.pls 120.12.12010000.2 2009/04/06 12:48:22 sjanakir ship $*/

l_conc_program VARCHAR2(200);
G_GCD_RENEWAL_TYPE VARCHAR2(30) := 'X';

--Bug#5981381: Cache the class_operation_id instead of deriving everytime;
G_RENCON_CLASS_OPERATION_ID NUMBER;
CURSOR cur_class_operations is
  SELECT ID from OKC_CLASS_OPERATIONS
  WHERE OPN_CODE = 'REN_CON' and CLS_CODE = 'SERVICE';

----------------------------------------------------------------------------------------
---This function is used to Check if the source_line_id has been processed with another
-- target id
----------------------------------------------------------------------------------------
    FUNCTION OBJECT_LINE_PROCESSED_BY_OTHER(target_id IN NUMBER,
                                            source_line_id IN NUMBER) RETURN BOOLEAN
    IS
    CURSOR op_lines IS
        SELECT subject_chr_id
        FROM okc_operation_lines
        WHERE object_cle_id = source_line_id
          AND process_flag = 'P'
          AND active_yn = 'Y';
    x_return BOOLEAN := FALSE;
    BEGIN
        FOR cur_op_lines IN op_lines
            LOOP
            IF cur_op_lines.subject_chr_id <> target_id THEN
                x_return := TRUE;
                EXIT;
            END IF;
        END LOOP;
        RETURN(x_return);
    END OBJECT_LINE_PROCESSED_BY_OTHER;

----------------------------------------------------------------------------------------
--This function is used to find if a source subline is already in operation_lines table
----------------------------------------------------------------------------------------
    FUNCTION ALREADY_IN_OL(p_object_cle_id IN NUMBER,
                           p_subject_chr_id IN NUMBER) RETURN BOOLEAN
    IS
    CURSOR oper_exist IS
        SELECT 'X' x
        FROM okc_operation_lines
        WHERE subject_chr_id = p_subject_chr_id
          AND object_cle_id = p_object_cle_id;
    x_return BOOLEAN := FALSE;
    BEGIN
        FOR cur_oper_exist IN oper_exist LOOP
            x_return := TRUE;
            EXIT;
        END LOOP;
        RETURN(x_return);
    END ALREADY_IN_OL;


    PROCEDURE SET_OL_SELECTED(p_id  IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR parent_cur IS
        SELECT id, select_yn
        FROM okc_operation_lines
        WHERE id = (SELECT parent_ole_id
                    FROM okc_operation_lines
                    WHERE id = p_id);
    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_msg_index_out NUMBER;
    l_olev_tbl_in    OKC_OPER_INST_PUB.olev_tbl_type;
    l_olev_tbl_out   OKC_OPER_INST_PUB.olev_tbl_type;

    PROCEDURE SET_OL_SEL(p_ole_id IN NUMBER) IS
    l_api_name CONSTANT VARCHAR2(30) := 'SET_OL_SEL';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;
    BEGIN
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,' SET_OL_SELECTED p_ole_id = '|| p_ole_id);
        END IF;
        IF p_ole_id IS NULL THEN
            RETURN;
        END IF;
        l_olev_tbl_in(1).id := p_ole_id;
        l_olev_tbl_in(1).select_yn := 'Y';
        OKC_OPER_INST_PUB.Update_Operation_Line(
                                                p_api_version => l_api_version,
                                                p_init_msg_list => l_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_olev_tbl => l_olev_tbl_in,
                                                x_olev_tbl => l_olev_tbl_out );
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Update_Operation_Line l_return_status = ' || l_return_status);
        END IF;
        x_return_status := l_return_status;
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Update_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RETURN;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Update_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RETURN;
        END IF;
    END SET_OL_SEL;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        SET_OL_SEL(p_id);
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        FOR parent_rec IN parent_cur
            LOOP
            SET_OL_SEL(parent_rec.id);
            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            EXIT;
        END LOOP;
    END SET_OL_SELECTED;

----------------------------------------------------------------------------------------
-- This procedure returns the valid source contract lines for a given target
----------------------------------------------------------------------------------------
    PROCEDURE GET_VALID_OPER_LINE_SOURCES (p_target_id     IN  NUMBER,
                                           x_sources_tbl    OUT NOCOPY sources_tbl_type,
                                           x_return_status OUT NOCOPY VARCHAR2,
                                           p_conc_program IN VARCHAR2,
                                           p_select_yn     IN VARCHAR2 DEFAULT 'N')
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_VALID_OPER_LINE_SOURCES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;


-------------------------------------------------------------------
----SOURCE HEADER RULES
-------------------------------------------------------------------
    x_chr_type VARCHAR2(200) := 'CYA';
    x_template_yn VARCHAR2(200) := 'N';
    x_buy_or_sell VARCHAR2(200) := 'S';
    x_issue_or_receive VARCHAR2(200) := 'I';
    x_start_date DATE := NULL;
    x_end_date DATE := NULL;
------------------------------------------------------------------
----TARGET HEADER MATCHING RULES
------------------------------------------------------------------
    x_scs_code VARCHAR2(200) := NULL;
    x_org_id  NUMBER := OKC_API.G_MISS_NUM; --mmadhavi MOAC : changed to org_id
    x_inv_organization_id   NUMBER := OKC_API.G_MISS_NUM;
    x_party_id VARCHAR2(200) := NULL;
    x_currency_code VARCHAR2(200) := NULL;

------------------------------------------------------------------
---IS TARGET VALID
------------------------------------------------------------------
    CURSOR valid_target (p_target_id  IN  NUMBER) IS
        SELECT
          h.scs_code,
          h.start_date,
          h.end_date,
          h.org_id,  --mmadhavi MOAC : changed to org_id
          h.inv_organization_id,
          pr.object1_id1,
          h.currency_code
        FROM  okc_K_Headers_all_b h,  --mmadhavi MOAC - changed to _ALL_B for performance
          okc_k_party_roles_b pr,
          okc_k_party_roles_b pr1,
          okc_statuses_b st
        WHERE  h.id = p_target_id
          AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
          AND pr.rle_code = 'CUSTOMER'
          AND h.id = pr1.dnz_chr_id AND pr1.cle_id IS NULL
          AND pr1.rle_code = 'VENDOR'
          AND h.scs_code IN ('SERVICE', 'WARRANTY')
          AND h.template_yn = x_template_yn
          AND h.buy_or_sell = x_buy_or_sell
          AND h.issue_or_receive = x_issue_or_receive
          AND h.chr_type = x_chr_type
          AND h.sts_code = st.code
          AND st.ste_code = 'ENTERED'
        FOR UPDATE OF h.scs_code NOWAIT;

------------------------------------------------------------------
--- Get operation lines for the target contract sublines only
-- The cursor was changed by MSENGUPT on 11/07 to filter out DNR lines for bug4719668
-- and  terminated lines. Also simplified the fetch for sublines.
------------------------------------------------------------------
    CURSOR operation_lines(p_target_id IN  NUMBER) IS
        SELECT opl.id, oie_id, object_chr_id, object_cle_id, parent_ole_id, select_yn
        FROM okc_operation_lines OPL,
             okc_k_lines_b cle
        WHERE OPL.subject_chr_id = p_target_id
          AND EXISTS (SELECT 'X'
                      FROM okc_operation_instances OPI
                      WHERE OPI.id = OPL.oie_id
                      AND OPI.cop_id = G_RENCON_CLASS_OPERATION_ID -- Bug#5981381: Use cached class_operation_id
/* (SELECT ID
                                        FROM OKC_CLASS_OPERATIONS
                                        WHERE OPN_CODE = 'REN_CON'
                                        AND CLS_CODE = 'SERVICE'
                                        )
*/
                      )
         and cle.id = opl.object_cle_id
         and NVL(line_renewal_type_code,'FUL') not in ('KEP','DNR') -- bug 5078797
         and date_terminated is null
         and cle_id is not null
         AND exists
             (SELECT 1 from okc_k_lines_b cle1
               WHERE cle1.id = cle.cle_id
               AND NVL(cle1.line_renewal_type_code,'FUL') not in ('DNR', 'KEP'))
/*
        MINUS
          (SELECT id, oie_id, object_chr_id, object_cle_id, parent_ole_id, select_yn
           FROM okc_operation_lines
           WHERE subject_chr_id = p_target_id
           AND parent_ole_id IS  NULL
           UNION
           SELECT a.id, a.oie_id, a.object_chr_id, a.object_cle_id, a.parent_ole_id, a.select_yn
           FROM okc_operation_lines a, okc_operation_lines b
           WHERE a.subject_chr_id = p_target_id
           AND b.subject_chr_id = p_target_id
           AND a.id = b.parent_ole_id)
*/
-- Added following code for bug#5981381 i.e. removed looping of function call of not_processed_by_other
-- and moved the entire code from the cursor to here
      AND NOT EXISTS
          ( SELECT '1' FROM okc_operation_lines
            WHERE object_cle_id = opl.object_cle_id
              AND subject_chr_id <> p_target_id
              AND process_flag = 'P'
              AND active_yn = 'Y')
        ORDER BY parent_ole_id;



  -- Added for bug # 2870380
    CURSOR get_correct_status(l_source_chr_id IN  NUMBER, l_source_subline_id IN  NUMBER) IS
        SELECT h.id
    FROM  okc_K_Headers_all_b h,  --mmadhavi MOAC - changed to _ALL_B for performance
          okc_k_party_roles_b pr,
          okc_statuses_b st
          , okc_k_lines_b s
    WHERE h.id = l_source_chr_id
    AND h.scs_code IN ('WARRANTY', x_scs_code)
      AND h.chr_type = x_chr_type
      AND h.template_yn = x_template_yn
      AND h.buy_or_sell = x_buy_or_sell
      AND h.issue_or_receive = x_issue_or_receive
      AND h.end_date BETWEEN x_start_date AND x_end_date
      AND h.inv_organization_id = x_inv_organization_id
      AND h.org_id = x_org_id
      AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
      AND pr.rle_code = 'CUSTOMER'
      AND pr.object1_id1 = x_party_id
    --and h.currency_code = x_currency_code
      AND (
           (x_currency_code <> 'EUR' AND x_currency_code = h.currency_code)
           OR
           (x_currency_code = 'EUR' AND (h.currency_code = 'EUR' OR
                                         OKC_CURRENCY_API.IS_EURO_CONVERSION_NEEDED(h.currency_code) = 'Y' )
            )
           )
    --and h.date_renewed is NULL
      AND h.sts_code = st.code
      AND st.ste_code IN ('ACTIVE', 'EXPIRED', 'SIGNED')
      AND s.dnz_chr_id = h.id
      AND s.id = l_source_subline_id
      AND s.end_date BETWEEN x_start_date AND x_end_date
      AND s.cle_id IS NOT NULL
    --AND s.date_renewed is NULL
      AND s.lse_id  IN (35, 7, 8, 9, 10, 11, 25);

--------------------------------------------------------------------

--------------------------------------------------------------------
---PROGRAM VARIABLES
--------------------------------------------------------------------
    i NUMBER := 0;
    x_oie_id NUMBER ;
    x_program_status VARCHAR2(200) := G_TARGET_VALID;
  ---------------------------------------------------------------------------------
--- Function to check operation lines for the target contract sublines which are not terminated
--- added for bug#3354678
---------------------------------------------------------------------------------
    FUNCTION opl_terminated(p_opl_id IN NUMBER) RETURN BOOLEAN IS

    CURSOR get_terminated_opl(cp_opl_id IN  NUMBER) IS
        SELECT 1
        FROM okc_operation_lines OPL,
             okc_k_lines_b       KLN
        WHERE OPL.id = cp_opl_id
        AND   OPL.object_cle_id = KLN.id
        AND   KLN.date_terminated IS NOT NULL;

    l_dummy NUMBER;

    BEGIN
        OPEN get_terminated_opl(p_opl_id);
        FETCH get_terminated_opl INTO l_dummy;
        IF get_terminated_opl%FOUND THEN
            CLOSE get_terminated_opl;
            RETURN TRUE;
        END IF;
        CLOSE get_terminated_opl;

        RETURN FALSE;

    END;

-----------------------------------------------------------------------------
---PROGRAM STARTS HERE
-----------------------------------------------------------------------------
    BEGIN
        l_conc_program := p_conc_program;
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'l_conc_program = ' || l_conc_program);
        END IF;

-----------------------------------------------------------------------------
---Check for validity of target
-----------------------------------------------------------------------------
        BEGIN
            OPEN  Valid_target(p_target_id) ;
            FETCH valid_target INTO
            x_scs_code,
            x_start_date,
            x_end_date,
            x_org_id,
            x_inv_organization_id,
            x_party_id,
            x_currency_code;
            CLOSE valid_target;
            x_start_date := x_start_date - 1;
            x_end_date := x_end_date - 1;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                OKC_API.set_message(p_app_name => 'OKS',
                                    p_msg_name => 'OKS_INVALID_TARGET',
                                    p_token1 => NULL,
                                    p_token1_value => NULL);
--       Bug#5981381: Performance avoid calling log messages if not called from UI
         if p_conc_program IS NOT NULL THEN
           LOG_MESSAGES('TARGET IS INVALID');
         end if;
                x_program_status := G_TARGET_INVALID;
                x_return_status := OKC_API.G_RET_STS_ERROR;
        END;
------------------------------------------------------------------------------
---Check Operation Lines to see if there are operations already in that table
------------------------------------------------------------------------------
--  Bug#5981381: Performance avoid calling log messages if not called from UI
  if p_conc_program IS NOT NULL THEN
     LOG_MESSAGES('IS_TARGET_VALID x_program_status := ' || x_program_status );
  end if;
        BEGIN
            i := 1;
            IF x_program_status <> G_TARGET_INVALID THEN

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'FROM Operation Lines');
                END IF;

                FOR cur_operation_lines IN operation_lines(p_target_id)
                    LOOP
                    -- IF NOT opl_terminated(cur_operation_lines.id) THEN
-- Added following code for bug#5981381 i.e. removed looping of function call of not_processed_by_other
                      --  IF object_line_processed_by_other(target_id => p_target_id,
                       --                                   source_line_id => cur_operation_lines.object_cle_id) = FALSE THEN
            -- Added for bug # 2870380
                            FOR get_correct_sts IN get_correct_status(cur_operation_lines.object_chr_id, cur_operation_lines.object_cle_id)
                                LOOP
                                x_program_status := 'S';
                                x_sources_tbl(i).operation_lines_id := cur_operation_lines.id;
                                x_sources_tbl(i).contract_id := get_correct_sts.id; --cur_operation_lines.object_chr_id;
                                x_sources_tbl(i).line_id := get_parent_line_id(cur_operation_lines.parent_ole_id);
                                x_sources_tbl(i).subline_id := cur_operation_lines.object_cle_id;
                                x_sources_tbl(i).parent_ole_id := cur_operation_lines.parent_ole_id;
                                x_sources_tbl(i).oie_id := cur_operation_lines.oie_id;
                                x_sources_tbl(i).select_yn := cur_operation_lines.select_yn;
                                x_sources_tbl(i).ol_status := find_ol_status(p_object_cle_id => cur_operation_lines.object_cle_id);
                                IF p_select_yn = 'Y' AND NVL(cur_operation_lines.select_yn, 'N') = 'N' THEN
                                    set_ol_selected(p_id => cur_operation_lines.id,
                                                    x_return_status => x_return_status);

                                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'set_ol_selected l_return_status: '|| x_return_status);
                                    END IF;

                                    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                                        x_sources_tbl(i).select_yn := 'Y';
                                    ELSE

                                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Unable to set select_yn to Y ');
                                        END IF;

                                        x_return_status := OKC_API.G_RET_STS_ERROR;
                                        RETURN;
                                    END IF;
                                END IF;

                                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'i = ' || i ||'Contract ID = ' || x_sources_tbl(i).contract_id || ' Line ID = ' || x_sources_tbl(i).line_id || ' Subline ID = ' || x_sources_tbl(i).subline_id);
                                END IF;

                                i := i + 1;
                            END LOOP; -- get_correct_sts
                    --    END IF; -- if object_line_processed_by_other
                    -- END IF; -- not terminated
                END LOOP; -- cur_operation_lines
            END IF;
        END;
    END GET_VALID_OPER_LINE_SOURCES;

----------------------------------------------------------------------------------------
-- This procedure returns the valid source contract lines for a given target
----------------------------------------------------------------------------------------
    PROCEDURE GET_VALID_LINE_SOURCES (p_target_id     IN  NUMBER,
                                      x_sources_tbl    OUT NOCOPY sources_tbl_type,
                                      x_return_status  OUT NOCOPY VARCHAR2,
                                      p_conc_program IN VARCHAR2,
                                      p_select_yn     IN VARCHAR2 DEFAULT 'N')
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_VALID_LINE_SOURCES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

-------------------------------------------------------------------
----SOURCE HEADER RULES
-------------------------------------------------------------------
    x_chr_type VARCHAR2(200) := 'CYA';
    x_template_yn VARCHAR2(200) := 'N';
    x_buy_or_sell VARCHAR2(200) := 'S';
    x_issue_or_receive VARCHAR2(200) := 'I';
    x_start_date DATE := NULL;
    x_end_date DATE := NULL;

------------------------------------------------------------------
----TARGET HEADER MATCHING RULES
------------------------------------------------------------------
    x_scs_code VARCHAR2(200) := NULL;
    x_org_id  NUMBER := OKC_API.G_MISS_NUM; --mmadhavi MOAC : changed to org_id
    x_inv_organization_id   NUMBER := OKC_API.G_MISS_NUM;
    x_party_id VARCHAR2(200) := NULL;
    x_currency_code VARCHAR2(200) := NULL;

------------------------------------------------------------------
---IS TARGET VALID
------------------------------------------------------------------
    CURSOR valid_target (p_target_id  IN  NUMBER) IS
        SELECT
        h.scs_code,
        h.start_date,
        h.end_date,
        h.org_id,  --mmadhavi MOAC : changed to org_id
        h.inv_organization_id,
        pr.object1_id1,
        h.currency_code
        FROM  okc_K_Headers_all_b h,  --mmadhavi MOAC - changed to _ALL_B for performance
              okc_k_party_roles_b pr,
              okc_k_party_roles_b pr1,
              okc_statuses_b st
        WHERE  h.id = p_target_id
         AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
         AND pr.rle_code = 'CUSTOMER'
         AND h.id = pr1.dnz_chr_id AND pr1.cle_id IS NULL
         AND pr1.rle_code = 'VENDOR'
         AND h.scs_code IN ('SERVICE', 'WARRANTY')
         AND h.template_yn = x_template_yn
         AND h.buy_or_sell = x_buy_or_sell
         AND h.issue_or_receive = x_issue_or_receive
         AND h.chr_type = x_chr_type
         AND h.sts_code = st.code
         AND st.ste_code = 'ENTERED'
         FOR UPDATE OF h.scs_code NOWAIT;

------------------------------------------------------------------
---Get the valid Source Header Contracts
------------------------------------------------------------------

    CURSOR valid_header_sources(p_target_id IN  NUMBER) IS
        SELECT
         h.id
        FROM  okc_K_Headers_all_b h,  --mmadhavi MOAC - changed to _ALL_B for performance
              okc_k_party_roles_b pr,
              okc_statuses_b st
        WHERE h.scs_code IN ('WARRANTY', x_scs_code)
          AND h.chr_type = x_chr_type
          AND h.template_yn = x_template_yn
          AND h.buy_or_sell = x_buy_or_sell
          AND h.issue_or_receive = x_issue_or_receive
          AND h.end_date BETWEEN x_start_date AND x_end_date
          AND h.inv_organization_id = x_inv_organization_id
          AND h.org_id = x_org_id --mmadhavi MOAC : changed to org_id
          AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
          AND pr.rle_code = 'CUSTOMER'
          AND pr.object1_id1 = x_party_id
          AND h.currency_code = x_currency_code
    --and h.date_renewed is NULL
          AND h.sts_code = st.code
          AND st.ste_code IN ('ACTIVE', 'EXPIRED', 'SIGNED');

-- Use this cursor only if the target contract currency is EUR
    CURSOR valid_header_sources_eur(p_target_id IN  NUMBER) IS
        SELECT
         h.id
        FROM  okc_K_Headers_all_b h,  --mmadhavi MOAC - changed to _ALL_B for performance
              okc_k_party_roles_b pr,
              okc_statuses_b st
        WHERE h.scs_code IN ('WARRANTY', x_scs_code)
          AND h.chr_type = x_chr_type
          AND h.template_yn = x_template_yn
          AND h.buy_or_sell = x_buy_or_sell
          AND h.issue_or_receive = x_issue_or_receive
          AND h.end_date BETWEEN x_start_date AND x_end_date
          AND h.inv_organization_id = x_inv_organization_id
          AND h.org_id = x_org_id --mmadhavi MOAC : changed to org_id
          AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
          AND pr.rle_code = 'CUSTOMER'
          AND pr.object1_id1 = x_party_id
          AND (h.currency_code = 'EUR' OR
               OKC_CURRENCY_API.IS_EURO_CONVERSION_NEEDED(h.currency_code) = 'Y' )
    --and h.date_renewed is NULL
          AND h.sts_code = st.code
          AND st.ste_code IN ('ACTIVE', 'EXPIRED', 'SIGNED');

------------------------------------------------------------------
---Get the Valid Sub lines given the contract id
-- LLC, modified the cursor by adding date_cancelled is NULL
-- condition to supress the cancelled sublines
------------------------------------------------------------------
-- The cursor was changed by MSENGUPT on 11/07 to filter out DNR lines for bug4719668
-- and  terminated lines.

    CURSOR valid_subline_sources(p_chr_id IN NUMBER , p_target_chr_id IN NUMBER) IS
        SELECT s.id,
                  s.cle_id
        FROM okc_k_lines_b s
        WHERE s.dnz_chr_id = p_chr_id
             AND s.end_date BETWEEN x_start_date AND x_end_date
             --AND s.date_renewed is NULL
             AND s.date_terminated IS NULL
             AND s.date_cancelled IS NULL
             AND s.lse_id  IN (35, 7, 8, 9, 10, 11, 25)
             AND NVL(s.line_renewal_type_code,'FUL') not in ('DNR', 'KEP') -- Added by MKS
             AND exists
             (SELECT 1 from okc_k_lines_b cle
               WHERE cle.id = s.cle_id
               AND NVL(cle.line_renewal_type_code,'FUL') not in ('DNR', 'KEP')) -- Added by MKS
-- Added following code for bug#5981381 i.e. removed looping of function call of is_laready_in_ol
-- and moved the entire code from that function to here
          AND NOT EXISTS
          ( SELECT '1' FROM okc_operation_lines
            WHERE subject_chr_id = p_target_chr_id
            AND object_cle_id = s.id) ;

------------------------------------------------------------------
---Get the Operation Instance id
------------------------------------------------------------------

    CURSOR oper_inst(p_target_id IN NUMBER) IS
        SELECT id FROM okc_operation_instances
         WHERE target_chr_id = p_target_id
           AND cop_id = G_RENCON_CLASS_OPERATION_ID; -- Bug#5981381: Use cached class_operation_id
/*(SELECT ID FROM OKC_CLASS_OPERATIONS
                         WHERE OPN_CODE = 'REN_CON' AND CLS_CODE = 'SERVICE');
*/

--------------------------------------------------------------------
---PROGRAM VARIABLES
--------------------------------------------------------------------
    i NUMBER := 0;
    x_oie_id NUMBER ;
    x_program_status VARCHAR2(200) := G_TARGET_VALID;
-----------------------------------------------------------------------------
---PROGRAM STARTS HERE
-----------------------------------------------------------------------------
    BEGIN
        l_conc_program := p_conc_program;
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'l_conc_program = ' || l_conc_program);
        END IF;

-----------------------------------------------------------------------------
---Check for validity of target
-----------------------------------------------------------------------------
        BEGIN
            OPEN  Valid_target(p_target_id) ;
            FETCH valid_target INTO
            x_scs_code,
            x_start_date,
            x_end_date,
            x_org_id,
            x_inv_organization_id,
            x_party_id,
            x_currency_code;
            CLOSE valid_target;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                OKC_API.set_message(p_app_name => 'OKS',
                                    p_msg_name => 'OKS_INVALID_TARGET',
                                    p_token1 => NULL,
                                    p_token1_value => NULL);
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'TARGET IS INVALID');
                END IF;
                x_program_status := G_TARGET_INVALID;
                x_return_status := OKC_API.G_RET_STS_ERROR;
        END;
        i := 0;

        x_start_date := x_start_date - 1;
        x_end_date := x_end_date - 1;
----------------------------------------------------------------------------
---Find the valid contract header sources for the above valid target and
---populate a PLSQL table contract_id||line_id||subline_id
----------------------------------------------------------------------------
        IF (x_program_status = G_TARGET_VALID) THEN

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'NEW TARGET NOTHING FOUND IN OPERATION LINES  x_program_status := ' || x_program_status || ' p_target_id = ' || p_target_id);
            END IF;

            BEGIN
                i := 0;
-----------------------------------------------------------------------------------------
---The following block of code is written for target contract currency 'EUR'
---and others separately. Both codes are identical except two differenct cursors are used
---The IF and ELSE sections of the following codes must be modified consistently.
-----------------------------------------------------------------------------------------
                IF x_currency_code = 'EUR' THEN

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'EURO Target');
                    END IF;

                    FOR valid_header_sources_rec IN valid_header_sources_eur(p_target_id)
                        LOOP

                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'SELECTING ELIGIBLE SUBLINES valid_header_sources_rec.id = ' || valid_header_sources_rec.id);
                        END IF;

                        FOR valid_subline_sources_rec IN valid_subline_sources(valid_header_sources_rec.id, p_target_id)
                            LOOP
--               bug#5981381 i.e. removed looping of function call of is_laready_in_ol
                            -- IF already_in_ol(valid_subline_sources_rec.id, p_target_id) = FALSE THEN
                -----------------------------------------------------------------------------
                ---Check the LRT Rule - Top Line LRT rule and subline LRT rule should be FULL
                -----------------------------------------------------------------------------
                                -- IF NOT ((OKS_RENCON_PVT.GET_LRT_RULE(valid_subline_sources_rec.id) IN ('DNR', 'KEP'))
                                --         OR (OKS_RENCON_PVT.GET_LRT_RULE(valid_subline_sources_rec.cle_id) IN ('DNR', 'KEP')))THEN
                                    x_sources_tbl(i).contract_id := valid_header_sources_rec.id;
                                    x_sources_tbl(i).line_id := valid_subline_sources_rec.cle_id;
                                    x_sources_tbl(i).subline_id := valid_subline_sources_rec.id;
                                    x_sources_tbl(i).select_yn := p_select_yn;
                                    x_sources_tbl(i).ol_status := 'A';

                                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Contract ID = ' || x_sources_tbl(i).contract_id || ' Line ID = ' || x_sources_tbl(i).line_id || ' Subline ID = ' || x_sources_tbl(i).subline_id);
                                    END IF;
                                    i := i + 1;
                                -- END IF;
                            -- END IF;
                        END LOOP;
                    END LOOP;
                ELSE

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Non-EURO Target');
                    END IF;

                    FOR valid_header_sources_rec IN valid_header_sources(p_target_id)
                        LOOP

                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'SELECTING ELIGIBLE SUBLINES valid_header_sources_rec.id = ' || valid_header_sources_rec.id);
                        END IF;

                        FOR valid_subline_sources_rec IN valid_subline_sources(valid_header_sources_rec.id, p_target_id)
                            LOOP
--               bug#5981381 i.e. removed looping of function call of is_laready_in_ol
                            -- IF already_in_ol(valid_subline_sources_rec.id, p_target_id) = FALSE THEN
                -----------------------------------------------------------------------------
                ---Check the LRT Rule - Top Line LRT rule and subline LRT rule should be FULL
                -----------------------------------------------------------------------------
                              --  IF NOT ((OKS_RENCON_PVT.GET_LRT_RULE(valid_subline_sources_rec.id) IN ('DNR', 'KEP'))
                              --          OR (OKS_RENCON_PVT.GET_LRT_RULE(valid_subline_sources_rec.cle_id) IN ('DNR', 'KEP')))THEN
                                    x_sources_tbl(i).contract_id := valid_header_sources_rec.id;
                                    x_sources_tbl(i).line_id := valid_subline_sources_rec.cle_id;
                                    x_sources_tbl(i).subline_id := valid_subline_sources_rec.id;
                                    x_sources_tbl(i).select_yn := p_select_yn;
                                    x_sources_tbl(i).ol_status := 'A';

                                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Contract ID = ' || x_sources_tbl(i).contract_id || ' Line ID = ' || x_sources_tbl(i).line_id || ' Subline ID = ' || x_sources_tbl(i).subline_id);
                                    END IF;
                                    i := i + 1;
                               -- END IF;
                            --END IF;
                        END LOOP;
                    END LOOP;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'NO CONTRACT SOURCES FOUND');
                    END IF;
                    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'valid_header_sources');
            END;
----------------------------------------------------------------------------
---Create one record in OKC_OPERATION_INSTANCES_V if x_sources_tbl is not empty
----------------------------------------------------------------------------
            BEGIN
                IF x_sources_tbl.COUNT > 0 THEN
                    DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');
                    BEGIN
                        OPEN oper_inst(p_target_id);
                        FETCH oper_inst INTO x_oie_id;
                        IF oper_inst%NOTFOUND THEN
                            OKS_RENCON_PVT.CREATE_OPERATION_INSTANCES (p_target_chr_id => p_target_id,
                                                                       p_oie_id => x_oie_id);
                        END IF;
                        CLOSE oper_inst;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.CREATE_OPERATION_INSTANCES NO_DATA_FOUND');
                            END IF;
                            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CREATE_OPERATION_INSTANCES');
                            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                        WHEN OTHERS THEN
                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.CREATE_OPERATION_INSTANCES OTHERS ');
                            END IF;
                            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                                                G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                    END;
----------------------------------------------------------------------------
---Create  OKC_OPERATIONS_LINES and update the PLSQL table with the oper_lines_id
----------------------------------------------------------------------------

                    BEGIN
                        OKS_RENCON_PVT.CREATE_OPERATION_LINES(p_target_chr_id => p_target_id,
                                                              p_oie_id => x_oie_id,
                                                              p_sources_tbl_type => x_sources_tbl) ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.CREATE_OPERATION_LINES NO_DATA_FOUND');
                            END IF;
                            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CREATE_OPERATION_LINES');
                            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                        WHEN OTHERS THEN
                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.CREATE_OPERATION_LINES OTHERS ');
                            END IF;
                            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                                                G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                    END;
                END IF;
            END;

            x_sources_tbl.DELETE;
            GET_VALID_OPER_LINE_SOURCES (p_target_id => p_target_id,
                                         x_sources_tbl => x_sources_tbl,
                                         x_return_status => x_return_status,
                                         p_conc_program => p_conc_program,
                                         p_select_yn => p_select_yn);
        END IF;
    END GET_VALID_LINE_SOURCES;

----------------------------------------------------------------------------
---Create  OKC_OPERATION_INSTANCES_V
----------------------------------------------------------------------------

    PROCEDURE CREATE_OPERATION_INSTANCES (p_target_chr_id IN NUMBER,
                                          p_oie_id OUT NOCOPY NUMBER) IS
------------------------------------------------------------------
---TAPI variables
------------------------------------------------------------------
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_OPERATION_INSTANCES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);

    l_msg_index_out      NUMBER;

    l_oiev_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE
    l_oiev_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE
--------------------------------------------------------------------
---Program Variables
--------------------------------------------------------------------
    p_class_operation_id NUMBER := 0;
-------------------------------------------------------------------------
---Find the Class Operation ID to be used
--------------------------------------------------------------------------
    CURSOR class_operations IS
        SELECT ID FROM OKC_CLASS_OPERATIONS
        WHERE OPN_CODE = 'REN_CON' AND CLS_CODE = 'SERVICE';

    BEGIN
-- Bug#5981381: Use cached class_operation_id
/*
        FOR cur_class_operations IN class_operations LOOP
            p_class_operation_id := cur_class_operations.id;
            EXIT;
        END LOOP;
*/

        l_oiev_tbl_in(1).name := OKC_API.G_MISS_CHAR;
       -- l_oiev_tbl_in(1).cop_id := p_class_operation_id;
        l_oiev_tbl_in(1).cop_id   := G_RENCON_CLASS_OPERATION_ID;
        l_oiev_tbl_in(1).status_code := G_OI_STATUS_CODE;
        l_oiev_tbl_in(1).target_chr_id := p_target_chr_id;
        l_oiev_tbl_in(1).object_version_number := OKC_API.G_MISS_NUM;
        l_oiev_tbl_in(1).created_by := OKC_API.G_MISS_NUM;
        l_oiev_tbl_in(1).creation_date := SYSDATE;
        l_oiev_tbl_in(1).last_updated_by := OKC_API.G_MISS_NUM;
        l_oiev_tbl_in(1).last_update_date := SYSDATE;
        l_oiev_tbl_in(1).last_update_login := OKC_API.G_MISS_NUM;

        OKC_OPER_INST_PUB.Create_Operation_Instance(
                                                    p_api_version => l_api_version,
                                                    p_init_msg_list => l_init_msg_list,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => l_msg_count,
                                                    x_msg_data => l_msg_data,
                                                    p_oiev_tbl => l_oiev_tbl_in,
                                                    x_oiev_tbl => l_oiev_tbl_out
                                                    );
        p_oie_id := l_oiev_tbl_out(1).id;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Instance l_return_status = ' || l_return_status);
        END IF;

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Instance l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Instance l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END CREATE_OPERATION_INSTANCES;


----------------------------------------------------------------------------
---Create  OKC_OPERATIONS_LINES
----------------------------------------------------------------------------

    PROCEDURE CREATE_OPERATION_LINES (p_target_chr_id IN NUMBER,
                                      p_oie_id IN NUMBER,
                                      p_sources_tbl_type IN OUT NOCOPY OKS_RENCON_PVT.sources_tbl_type,
                                      p_select_yn IN VARCHAR2 DEFAULT 'N') IS
----------------------------------------------------------------------------
---TAPI variables
----------------------------------------------------------------------------
    l_api_version  CONSTANT NUMBER := 1.0;
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_OPERATION_LINES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);

    l_msg_index_out      NUMBER;

    l_olev_tbl_in          OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES
    l_olev_tbl_out         OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES


------------------------------------------------------------------
---PROGRAM variables
------------------------------------------------------------------
    i NUMBER := 0;
    j NUMBER := 0;

    TYPE t_id_table IS TABLE OF OKS_RENCON_PVT.sources_rec_type
    INDEX BY BINARY_INTEGER;

    v_id_list OKS_RENCON_PVT.sources_tbl_type;
    v_id_list_k OKS_RENCON_PVT.sources_tbl_type;
    v_ole_id NUMBER;

    FUNCTION IS_K_PRESENT(p_contract_id IN NUMBER, p_operation_lines_id OUT NOCOPY NUMBER, p_id_list IN OKS_RENCON_PVT.sources_tbl_type) RETURN VARCHAR2 IS
    x_return VARCHAR2(200) := 'N';
    v_index BINARY_INTEGER;
    BEGIN

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'p_id_list.COUNT = ' || p_id_list.COUNT);
        END IF;

        IF p_id_list.COUNT > 0 THEN
            v_index := p_id_list.FIRST;
            LOOP

                IF  p_id_list(v_index).contract_id = p_contract_id THEN
                    p_operation_lines_id := p_id_list(v_index).operation_lines_id;
                    x_return := 'Y';
                   -- Bug#5981381: Added following statement to avoid unnecessary looping once contract found.
                    exit;
                END IF;
                EXIT WHEN v_index = p_id_list.LAST;
                v_index := p_id_list.NEXT(v_index);

            END LOOP;
        END IF;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'IS_K_PRESENT p_contract_id = '|| p_contract_id || 'p_operation_lines_id = ' || p_operation_lines_id || ' x_return = ' || x_return);
        END IF;

        RETURN(x_return);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.IS_K_PRESENT NO_DATA_FOUND');
            END IF;
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'IS_PRESENT');
            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
        WHEN OTHERS THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.IS_K_PRESENT OTHERS ');
            END IF;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                                G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    END IS_K_PRESENT;


    FUNCTION IS_PRESENT(p_line_id IN NUMBER, p_operation_lines_id OUT NOCOPY NUMBER, p_id_list IN OKS_RENCON_PVT.sources_tbl_type) RETURN VARCHAR2 IS
    x_return VARCHAR2(200) := 'N';
    v_index BINARY_INTEGER;
    BEGIN
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'p_id_list.COUNT = ' || p_id_list.COUNT);
        END IF;
        IF p_id_list.COUNT > 0 THEN
            v_index := p_id_list.FIRST;
            LOOP

                IF  p_id_list(v_index).line_id = p_line_id THEN
                    p_operation_lines_id := p_id_list(v_index).operation_lines_id;
                    x_return := 'Y';
                    -- Bug#5981381: Added following statement to avoid unnecessary looping once contract found.
                    exit;
                END IF;
                EXIT WHEN v_index = p_id_list.LAST;
                v_index := p_id_list.NEXT(v_index);

            END LOOP;
        END IF;

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'IS_PRESENT p_line_id = '|| p_line_id || 'p_operation_lines_id = ' || p_operation_lines_id || ' x_return = ' || x_return);
        END IF;

        RETURN(x_return);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.IS_PRESENT NO_DATA_FOUND');
            END IF;
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'IS_PRESENT');
            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
        WHEN OTHERS THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKS_RENCON_PVT.IS_PRESENT OTHERS ');
            END IF;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                                G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    END IS_PRESENT;

    FUNCTION GET_HDR_OLE_ID(p_header_id IN NUMBER) RETURN NUMBER IS
    CURSOR header_op_line IS
        SELECT id FROM OKC_OPERATION_LINES
        WHERE oie_id = p_oie_id
          AND object_chr_id = p_header_id
          AND object_cle_id IS NULL;
    x_ret_id NUMBER  ;
    BEGIN
        OPEN header_op_line;
        FETCH header_op_line INTO x_ret_id;
        IF header_op_line%NOTFOUND THEN
            x_ret_id := 0;
        END IF;
        CLOSE header_op_line;
        RETURN(x_ret_id);
    END GET_HDR_OLE_ID;

    FUNCTION GET_TOPLINE_OLE_ID(p_topline_id IN NUMBER) RETURN NUMBER IS
    CURSOR topline_op_line IS
        SELECT id FROM OKC_OPERATION_LINES
        WHERE oie_id = p_oie_id
          AND object_cle_id = p_topline_id;
    x_ret_id NUMBER  ;
    BEGIN
        OPEN topline_op_line;
        FETCH topline_op_line INTO x_ret_id;
        IF topline_op_line%NOTFOUND THEN
            x_ret_id := 0;
        END IF;
        CLOSE topline_op_line;
        RETURN(x_ret_id);
    END GET_TOPLINE_OLE_ID;

------------------------------------------------------------------------
---PROGRAM BEGINS HERE
------------------------------------------------------------------------
    BEGIN
 -----------------------------------------------------------------------
 ----EXTRACTING HEADER CONTRACT IDS FROM THE PLSQL TABLE
 -----------------------------------------------------------------------
        i := 0;
        j := 0;
        WHILE p_sources_tbl_type.EXISTS(j) LOOP
            IF IS_K_PRESENT(p_sources_tbl_type(j).contract_id, v_ole_id, v_id_list_k) = 'N' THEN
                v_id_list_k(i).contract_id := p_sources_tbl_type(j).contract_id;
                v_id_list_k(i).subline_id := NULL;
                v_id_list_k(i).operation_lines_id := GET_HDR_OLE_ID(v_id_list_k(i).contract_id);
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

        i := 0;
        j := 0;
 -----------------------------------------------------------------------
 ----CREATE the header source CONTRACT HEADER  in operation_lines
 -----------------------------------------------------------------------
        WHILE v_id_list_k.EXISTS(j) LOOP
            IF v_id_list_k(j).operation_lines_id = 0 THEN
                l_olev_tbl_in(i).select_yn := p_select_yn;
                l_olev_tbl_in(i).active_yn := 'Y';
                l_olev_tbl_in(i).process_flag := 'A';
                l_olev_tbl_in(i).oie_id := p_oie_id;
                l_olev_tbl_in(i).subject_chr_id := p_target_chr_id;
                l_olev_tbl_in(i).object_chr_id := v_id_list_k(j).contract_id;
                l_olev_tbl_in(i).subject_cle_id := NULL;
                l_olev_tbl_in(i).parent_ole_id := NULL;
                l_olev_tbl_in(i).object_cle_id := NULL;
                l_olev_tbl_in(i).object_version_number := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).created_by := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).creation_date := SYSDATE;
                l_olev_tbl_in(i).last_updated_by := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).last_update_date := SYSDATE;
                l_olev_tbl_in(i).last_update_login := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
                l_olev_tbl_in(i).program_application_id := FND_GLOBAL.PROG_APPL_ID;
                l_olev_tbl_in(i).program_id := FND_GLOBAL.CONC_PROGRAM_ID;
                l_olev_tbl_in(i).program_update_date := OKC_API.G_MISS_DATE;
                l_olev_tbl_in(i).message_code := OKC_API.G_MISS_CHAR;
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

        OKC_OPER_INST_PUB.Create_Operation_Line(
                                                p_api_version => l_api_version,
                                                p_init_msg_list => l_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_olev_tbl => l_olev_tbl_in,
                                                x_olev_tbl => l_olev_tbl_out
                                                );

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'FOR CONTRACT HEADER OKC_OPER_INST_PUB.Create_Operation_Line l_return_status = ' || l_return_status);
        END IF;
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
------------------------------------------------------------------------------------
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Update the v_id_list_k with the operation_lines_id');
        END IF;
------------------------------------------------------------------------------------
        i := 0;
        j := 0;
        WHILE v_id_list_k.EXISTS(j) LOOP
            IF v_id_list_k(j).operation_lines_id = 0 THEN
                v_id_list_k(j).operation_lines_id := l_olev_tbl_out(i).id;
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'TOP CONTRACT HEADER LINE l_olev_tbl_out('|| i ||').id = ' || l_olev_tbl_out(i).id);
                END IF;
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

 -----------------------------------------------------------------------
 -----------------------------------------------------------------------
 ----EXTRACT TOP lines FROM PLSQL TABLE
 -----------------------------------------------------------------------
        i := 0;
        j := 0;
        WHILE p_sources_tbl_type.EXISTS(j) LOOP
            IF IS_PRESENT(p_sources_tbl_type(j).line_id, v_ole_id, v_id_list) = 'N' THEN
                v_id_list(i).line_id := p_sources_tbl_type(j).line_id;
                v_id_list(i).contract_id := p_sources_tbl_type(j).contract_id;
                v_id_list(i).subline_id := NULL;
                v_id_list(i).operation_lines_id := GET_TOPLINE_OLE_ID(v_id_list(i).line_id);
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

        i := 0;
        j := 0;
 -----------------------------------------------------------------------
 ----CREATE the header source TOP lines in operation_lines
 -----------------------------------------------------------------------
        WHILE v_id_list.EXISTS(j) LOOP
            IF v_id_list(j).operation_lines_id = 0 THEN
                l_olev_tbl_in(i).select_yn := p_select_yn;
                l_olev_tbl_in(i).active_yn := 'Y';
                l_olev_tbl_in(i).process_flag := 'A';
                l_olev_tbl_in(i).oie_id := p_oie_id;
                l_olev_tbl_in(i).subject_chr_id := p_target_chr_id;
                l_olev_tbl_in(i).object_chr_id := v_id_list(j).contract_id;
                l_olev_tbl_in(i).subject_cle_id := OKC_API.G_MISS_NUM;
                IF IS_K_PRESENT(v_id_list(j).contract_id, v_ole_id, v_id_list_k) = 'Y' THEN
                    l_olev_tbl_in(i).parent_ole_id := v_ole_id;
                END IF;
                l_olev_tbl_in(i).object_cle_id := v_id_list(j).line_id;
                l_olev_tbl_in(i).object_version_number := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).created_by := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).creation_date := SYSDATE;
                l_olev_tbl_in(i).last_updated_by := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).last_update_date := SYSDATE;
                l_olev_tbl_in(i).last_update_login := OKC_API.G_MISS_NUM;
                l_olev_tbl_in(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
                l_olev_tbl_in(i).program_application_id := FND_GLOBAL.PROG_APPL_ID;
                l_olev_tbl_in(i).program_id := FND_GLOBAL.CONC_PROGRAM_ID;
                l_olev_tbl_in(i).program_update_date := OKC_API.G_MISS_DATE;
                l_olev_tbl_in(i).message_code := OKC_API.G_MISS_CHAR;
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

        OKC_OPER_INST_PUB.Create_Operation_Line(
                                                p_api_version => l_api_version,
                                                p_init_msg_list => l_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_olev_tbl => l_olev_tbl_in,
                                                x_olev_tbl => l_olev_tbl_out
                                                );

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'FOR TOP LINES OKC_OPER_INST_PUB.Create_Operation_Line l_return_status = ' || l_return_status);
        END IF;

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
------------------------------------------------------------------------------------
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'Update the v_id_list with the operation_lines_id');
        END IF;
------------------------------------------------------------------------------------
        i := 0;
        j := 0;
        WHILE v_id_list.EXISTS(j) LOOP
            IF v_id_list(j).operation_lines_id = 0 THEN
                v_id_list(j).operation_lines_id := l_olev_tbl_out(i).id;
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'TOP LINE l_olev_tbl_out('|| i ||').id = ' || l_olev_tbl_out(i).id);
                END IF;
                i := i + 1;
            END IF;
            j := j + 1;
        END LOOP;

-----------------------------------------------------------------------
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'CREATE the header source sublines in operation_lines');
        END IF;
-----------------------------------------------------------------------
        i := 0;
        j := 0;
        l_olev_tbl_in.DELETE;
        WHILE p_sources_tbl_type.EXISTS(j) LOOP
            l_olev_tbl_in(i).select_yn := p_select_yn;
            l_olev_tbl_in(i).active_yn := 'Y';
            l_olev_tbl_in(i).process_flag := 'A';
            l_olev_tbl_in(i).oie_id := p_oie_id;
            l_olev_tbl_in(i).subject_chr_id := p_target_chr_id;
            l_olev_tbl_in(i).object_chr_id := p_sources_tbl_type(j).contract_id;
            l_olev_tbl_in(i).subject_cle_id := OKC_API.G_MISS_NUM;
            IF IS_PRESENT(p_sources_tbl_type(j).line_id, v_ole_id, v_id_list) = 'Y' THEN
                l_olev_tbl_in(i).parent_ole_id := v_ole_id;
            END IF;
            l_olev_tbl_in(i).object_cle_id := p_sources_tbl_type(j).subline_id;
            l_olev_tbl_in(i).object_version_number := OKC_API.G_MISS_NUM;
            l_olev_tbl_in(i).created_by := OKC_API.G_MISS_NUM;
            l_olev_tbl_in(i).creation_date := SYSDATE;
            l_olev_tbl_in(i).last_updated_by := OKC_API.G_MISS_NUM;
            l_olev_tbl_in(i).last_update_date := SYSDATE;
            l_olev_tbl_in(i).last_update_login := OKC_API.G_MISS_NUM;
            l_olev_tbl_in(i).request_id := FND_GLOBAL.CONC_REQUEST_ID;
            l_olev_tbl_in(i).program_application_id := FND_GLOBAL.PROG_APPL_ID;
            l_olev_tbl_in(i).program_id := FND_GLOBAL.CONC_PROGRAM_ID;
            l_olev_tbl_in(i).program_update_date := OKC_API.G_MISS_DATE;
            l_olev_tbl_in(i).message_code := OKC_API.G_MISS_CHAR;
            i := i + 1;
            j := j + 1;
        END LOOP;

        OKC_OPER_INST_PUB.Create_Operation_Line(
                                                p_api_version => l_api_version,
                                                p_init_msg_list => l_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_olev_tbl => l_olev_tbl_in,
                                                x_olev_tbl => l_olev_tbl_out
                                                );

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'FOR SUBLINES OKC_OPER_INST_PUB.Create_Operation_Line l_return_status = ' || l_return_status);
        END IF;
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'OKC_OPER_INST_PUB.Create_Operation_Line l_msg_data = ' || l_msg_data);
            END IF;
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
------------------------------------------------------------------------------------
--Update the p_sources_tbl_type with the operation_lines_id
------------------------------------------------------------------------------------
        i := 0;
        j := 0;
        WHILE p_sources_tbl_type.EXISTS(i) LOOP
            p_sources_tbl_type(i).operation_lines_id := l_olev_tbl_out(i).id;
            p_sources_tbl_type(i).parent_ole_id := l_olev_tbl_out(i).parent_ole_id;
            p_sources_tbl_type(i).oie_id := l_olev_tbl_out(i).oie_id;
            i := i + 1;
        END LOOP;

    END CREATE_OPERATION_LINES;

----------------------------------------------------------------------------------------
--This function is used to find if a source subline is eligible for consolidation
----------------------------------------------------------------------------------------
    FUNCTION FIND_OL_STATUS(p_object_cle_id IN NUMBER) RETURN VARCHAR2
    IS
    CURSOR process_flag IS
        SELECT process_flag
        FROM okc_operation_lines
        WHERE object_cle_id = p_object_cle_id
          AND active_yn = 'Y';

    x_return VARCHAR2(200) := 'A';

    BEGIN
        FOR cur_process_flag IN process_flag LOOP
            x_return := cur_process_flag.process_flag;
            IF x_return = 'P' THEN
                EXIT;
            END IF;
        END LOOP;
        RETURN(x_return);
    END FIND_OL_STATUS;

----------------------------------------------------------------------------------------
---This function is used to Check the Validity of target
----------------------------------------------------------------------------------------
    FUNCTION IS_VALID_TARGET(p_target_id IN NUMBER) RETURN BOOLEAN
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'IS_VALID_TARGET';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    CURSOR valid_target (p_target_id  IN  NUMBER) IS
        SELECT
         'X'
        FROM okc_K_Headers_all_b h,
             okc_k_party_roles_b pr,
             okc_k_party_roles_b pr1,
             okc_statuses_b st
        WHERE  h.id = p_target_id
          AND h.id = pr.dnz_chr_id AND pr.cle_id IS NULL
          AND pr.rle_code = 'CUSTOMER'
          AND h.id = pr1.dnz_chr_id AND pr1.cle_id IS NULL
          AND pr1.rle_code = 'VENDOR'
          AND h.scs_code IN ('SERVICE', 'WARRANTY')
          AND h.template_yn = 'N'
          AND h.buy_or_sell = 'S'
          AND h.issue_or_receive = 'I'
          AND h.chr_type = 'CYA'
          AND h.sts_code = st.code
          AND st.ste_code = 'ENTERED';

--x_return VARCHAR2(200) := G_TARGET_INVALID;
    x_return BOOLEAN := FALSE;
    BEGIN
        BEGIN
            FOR cur_valid_target IN Valid_target(p_target_id) LOOP
          --x_return := G_TARGET_VALID;
                x_return := TRUE;
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'TARGET IS INVALID');
                END IF;
         --x_return := G_TARGET_INVALID;
                x_return := FALSE;
        END;
        IF x_return = FALSE THEN
            OKC_API.set_message(p_app_name => 'OKS',
                                p_msg_name => 'OKS_INVALID_TARGET',
                                p_token1 => NULL,
                                p_token1_value => NULL);
        END IF;
        RETURN(x_return);

    END IS_VALID_TARGET;


    FUNCTION GET_PARENT_LINE_ID(p_parent_ole_id IN NUMBER) RETURN NUMBER IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_PARENT_LINE_ID';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    CURSOR get_top_line IS
        SELECT object_cle_id
        FROM okc_operation_lines
        WHERE p_parent_ole_id = id;
    x_return NUMBER;
    BEGIN
        BEGIN
            FOR cur_get_top_line IN get_top_line LOOP
                x_return := cur_get_top_line.object_cle_id;
                exit; -- Added for bug#5981381
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'GET_PARENT_LINE_ID INVALID');
                END IF;
                OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'GET_PARENT_LINE_ID');
                x_return := NULL;
        END;
        RETURN(x_return);
    END GET_PARENT_LINE_ID;


    FUNCTION GET_LRT_RULE(p_line_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR GET_RULE IS
        SELECT NVL(LINE_RENEWAL_TYPE_CODE,'FUL') LINE_RENEWAL_TYPE_CODE
        FROM  OKC_K_LINES_B
        WHERE ID = p_line_id;
    x_return VARCHAR2(200) := 'NOLRTRULE';
    BEGIN
        FOR cur_get_rule IN get_rule LOOP
            x_return := cur_get_rule.LINE_RENEWAL_TYPE_CODE;
        END LOOP;
        RETURN(x_return);
    END GET_LRT_RULE;


    PROCEDURE GET_LINE_DETAILS(p_line_id IN NUMBER,
                               x_line_details OUT NOCOPY OKS_RENCON_PVT.merge_rec_type) IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_LINE_DETAILS';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    CURSOR get_inv_and_organization_id IS
        SELECT object1_id1, object1_id2
        FROM okc_k_items
        WHERE cle_id = p_line_id;

    CURSOR get_lrt_bto IS
        SELECT NVL(LINE_RENEWAL_TYPE_CODE,'FUL') LINE_RENEWAL_TYPE_CODE, BILL_TO_SITE_USE_ID, START_DATE, END_DATE
        FROM OKC_K_LINES_B
        WHERE ID = p_line_id;


    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_line_id='|| p_line_id);
        END IF;

        x_line_details.line_id := p_line_id;

        FOR cur_get_inv_organization IN get_inv_and_organization_id LOOP
            x_line_details.inventory_item_id := cur_get_inv_organization.object1_id1;
            x_line_details.inv_organization_id := cur_get_inv_organization.object1_id2;
        END LOOP;

        FOR cur_get_lrt_bto IN get_lrt_bto LOOP
            x_line_details.lrt_rule := cur_get_lrt_bto.LINE_RENEWAL_TYPE_CODE;
            x_line_details.bto_id := cur_get_lrt_bto.BILL_TO_SITE_USE_ID;
            x_line_details.start_date := cur_get_lrt_bto.start_date;
            x_line_details.end_date := cur_get_lrt_bto.end_date;
        END LOOP;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_line_details.lrt_rule='|| x_line_details.lrt_rule);
        END IF;

    END  GET_LINE_DETAILS;

------------------------------------------------------------------------------------

    FUNCTION MERGE_ELIGIBLE_YN(p_source_line_details IN  OKS_RENCON_PVT.merge_rec_type,
                               p_target_line_details IN  OKS_RENCON_PVT.merge_rec_type)
    RETURN VARCHAR2 IS

    l_api_name CONSTANT VARCHAR2(30) := 'MERGE_ELIGIBLE_YN';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    x_return VARCHAR2(200) := 'N';
    x_continue VARCHAR2(200) := 'Y';
    l_target_duration        NUMBER;
    l_target_timeunit        VARCHAR2(200);
    l_source_duration        NUMBER;
    l_source_timeunit        VARCHAR2(200);
    l_return_status   VARCHAR2(1);
    l_source_start_date DATE;
    l_source_end_date DATE;

    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_coverage_match  VARCHAR2(1);
    l_index          NUMBER;
    i                NUMBER;

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN

            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'begin');

            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.input_details', 'src_line_dtls line_id='||p_source_line_details.line_id||' ,inventory_item_id='||p_source_line_details.inventory_item_id||
            ' ,inv_organization_id='||p_source_line_details.inv_organization_id||' ,lrt_rule='||p_source_line_details.lrt_rule||' ,bto_id='||p_source_line_details.bto_id||
            ' ,start_date='||p_source_line_details.start_date||' ,end_date='||p_source_line_details.end_date);

            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.input_details', 'trg_line_dtls line_id='||p_target_line_details.line_id||' ,inventory_item_id='||p_target_line_details.inventory_item_id||
            ' ,inv_organization_id='||p_target_line_details.inv_organization_id||' ,lrt_rule='||p_target_line_details.lrt_rule||' ,bto_id='||p_target_line_details.bto_id||
            ' ,start_date='||p_target_line_details.start_date||' ,end_date='||p_target_line_details.end_date);

        END IF;

        --check if item id and inv org id are same
        IF x_continue = 'Y' THEN
            IF NOT (p_target_line_details.inventory_item_id = p_source_line_details.inventory_item_id
                    AND p_target_line_details.inv_organization_id = p_source_line_details.inv_organization_id
                    -- bug 3981824
                    -- AND NVL(p_target_line_details.lrt_rule,'1') = NVL(p_source_line_details.lrt_rule,'1')
                    -- end of bug 3981824
                    -- AND NVL(p_target_line_details.bto_id,'1') = NVL(p_source_line_details.bto_id,'1')
                    ) THEN
                x_continue := 'N';
            END IF;
        END IF;

        --check if lrt, dates and coverages match
        IF (x_continue = 'Y') THEN

            IF (p_source_line_details.lrt_rule = 'KEP') AND (p_target_line_details.lrt_rule = 'KEP') THEN

                OKC_TIME_UTIL_PUB.get_duration (
                    p_start_date => p_target_line_details.start_date,
                    p_end_date => p_target_line_details.end_date,
                    x_duration => l_target_duration,
                    x_timeunit => l_target_timeunit,
                    x_return_status => l_return_status);

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.lrt_KEP', 'l_target_duration='||l_target_duration||' ,l_target_timeunit='||l_target_timeunit);
                END IF;

                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    OKC_TIME_UTIL_PUB.get_duration (
                        p_start_date => p_source_line_details.start_date,
                        p_end_date => p_source_line_details.end_date,
                        x_duration => l_source_duration,
                        x_timeunit => l_source_timeunit,
                        x_return_status => l_return_status);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.lrt_KEP', 'l_source_duration='||l_source_duration||' ,l_source_timeunit='||l_source_timeunit);
                    END IF;

                END IF;

                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN

                    l_source_start_date := p_source_line_details.end_date + 1;

                    l_source_end_date := OKC_TIME_UTIL_PUB.get_enddate(
                                            p_start_date => l_source_start_date,
                                            p_duration => l_source_duration,
                                            p_timeunit => l_source_timeunit);

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.lrt_KEP', 'l_source_start_date='||l_source_start_date||' ,l_source_end_date='||l_source_end_date);
                    END IF;

                    IF (l_source_start_date = p_target_line_details.start_date)
                        AND  (l_source_end_date = p_target_line_details.end_date) THEN
                        x_return := 'Y';
                    END IF;

                END IF;

            END IF; --of if  src.lrt_rule=trg.lrt_rule=KEP


            IF (p_source_line_details.lrt_rule = 'FUL') AND (p_target_line_details.lrt_rule = 'FUL') THEN

                l_source_start_date := p_source_line_details.end_date + 1;
                IF l_source_start_date >= p_target_line_details.start_date THEN
                    x_return := 'Y';
                END IF;
            END IF;

            -- bug 3981824
            -- default renewal type to FUL if null
            --IF (p_source_line_details.lrt_rule IS NULL) AND (p_target_line_details.lrt_rule IS NULL) THEN
            IF ( nvl(p_source_line_details.lrt_rule, 'FUL') = 'FUL') AND
                ( nvl(p_target_line_details.lrt_rule, 'FUL') = 'FUL') THEN
                l_source_start_date := p_source_line_details.end_date + 1;
                IF l_source_start_date >= p_target_line_details.start_date THEN
                    x_return := 'Y';
                END IF;
            END IF;

            IF  (x_return = 'Y' AND
                FND_PROFILE.VALUE('OKS_CHECK_COV_MATCH') = 'Y')  THEN

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cov_match', 'profile OKS_CHECK_COV_MATCH=Y, calling OKS_COVERAGES_PUB.check_coverage_match');
                END IF;

                OKS_COVERAGES_PUB.check_coverage_match(
                                                       p_api_version => l_api_version,
                                                       p_init_msg_list => l_init_msg_list,
                                                       x_return_status => l_return_status,
                                                       x_msg_count => l_msg_count,
                                                       x_msg_data => l_msg_data,
                                                       P_Source_contract_Line_Id => p_source_line_details.line_id,
                                                       P_Target_contract_Line_Id => p_target_line_details.line_id,
                                                       x_coverage_match => l_coverage_match);

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cov_match', 'after call to OKS_COVERAGES_PUB.check_coverage_match, l_return_status='||l_return_status||' ,l_coverage_match='||l_coverage_match);
                END IF;

                IF l_coverage_match <> 'Y' THEN
                    x_return := 'N' ;
                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cov_match','Coverage Mismatch occured');
                    END IF;
                END IF;

            END IF;

        END IF;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return = ' || x_return);
        END IF;

        RETURN(x_return);
    END MERGE_ELIGIBLE_YN;

----------------------------------------------------------------------------------
--- THIS PROCEDURE has 2 inputs. The output is used to decide whether to merge or
--- to create a new TOP line
----------------------------------------------------------------------------------
    PROCEDURE MERGE(p_source_line_id IN NUMBER,
                    p_target_contract_id IN NUMBER,
                    x_target_line_id OUT NOCOPY NUMBER) IS

    l_api_name CONSTANT VARCHAR2(30) := 'MERGE';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;

    CURSOR target_line_id IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_target_contract_id
        AND cle_id IS NULL
        AND lse_id IN (1, 12, 14, 19);

    p_target_line_details OKS_RENCON_PVT.merge_rec_type;
    p_source_line_details OKS_RENCON_PVT.merge_rec_type;

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'p_source_line_id=' || p_source_line_id ||' .p_target_contract_id=' || p_target_contract_id);
        END IF;

        x_target_line_id := NULL;

        get_line_details(p_line_id => p_source_line_id,
                         x_line_details => p_source_line_details);

        FOR cur_target_line_id IN target_line_id LOOP

            get_line_details(p_line_id => cur_target_line_id.id,
                             x_line_details => p_target_line_details);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.check_merge', 'Calling merge_eligible_yn with details of source top line id='||p_source_line_id||' and target top line id='||cur_target_line_id.id);
            END IF;

            IF merge_eligible_yn(p_source_line_details, p_target_line_details) = 'Y' THEN
                x_target_line_id := cur_target_line_id.id;
                EXIT;
            END IF;

        END LOOP;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_target_line_id='|| x_target_line_id );
        END IF;
    END MERGE;


    FUNCTION GET_CURRENCY(p_chr_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR source_currency IS
        SELECT currency_code
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;
    x_return VARCHAR2(15);
    BEGIN
        FOR source_currency_rec IN source_currency
            LOOP
            x_return := source_currency_rec.currency_code;
        END LOOP;
        RETURN(x_return);
    END GET_CURRENCY;

--------------------------------------------------------------------------
  -- A source top line can only be copied to a target contract if it has
  -- at least one unprocessed, selected sub line.
  --
  -- This procedure goes theough the operation sub lines to find at least one
  -- unprocessed, selected sub line.
--------------------------------------------------------------------------
    FUNCTION can_copy_topline(p_ole_id IN NUMBER) RETURN VARCHAR2 IS

    l_can_copy VARCHAR2(1) := 'N';
    l_api_name CONSTANT VARCHAR2(30) := 'CAN_COPY_TOPLINE';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;


    CURSOR get_oper_sub_lines(p_id IN NUMBER) IS
    SELECT object_cle_id FROM okc_operation_lines ol, okc_k_lines_b cle
    WHERE ol.parent_ole_id = p_id
    and ol.process_flag IN ('A','E')
    and ol.select_yn = 'Y'
    and cle.id = ol.object_cle_id
    and cle.date_terminated is null
    and NVL(cle.line_renewal_type_code,'FUL') not in ('DNR', 'KEP'); -- bug 5078797
/*
        SELECT * FROM okc_operation_lines
        WHERE parent_ole_id = p_id
        AND process_flag IN ('A', 'E')
        AND select_yn = 'Y';
*/

    BEGIN
        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'p_ole_id='||p_ole_id);
        END IF;

        FOR cur_get_oper_sub_lines IN get_oper_sub_lines(p_ole_id)
            LOOP
            IF find_ol_status(cur_get_oper_sub_lines.object_cle_id) <> 'P' THEN
                l_can_copy := 'Y';
            END IF;
        END LOOP;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end', 'l_can_copy='||l_can_copy);
        END IF;

        RETURN l_can_copy;
    END can_copy_topline;

-----------------------------------------------------------------------------------------
--CALL THIS FUNCTION IF U WANT TO SUBMIT CONC REQ FROM THE FORM
-----------------------------------------------------------------------------------------

    FUNCTION SUBMIT_FORM_CONC(p_oie_id IN NUMBER) RETURN NUMBER IS

    --added for MOAC changes
    CURSOR c_org_id(cp_oie_id IN NUMBER) IS
        SELECT org_id FROM okc_k_headers_all_b WHERE
        id = (SELECT target_chr_id FROM okc_operation_instances WHERE id = cp_oie_id);

    req_id NUMBER;
    l_mode BOOLEAN;
    l_org_id NUMBER;

    BEGIN

        OPEN c_org_id(p_oie_id);
        FETCH c_org_id INTO l_org_id;
        CLOSE c_org_id;

        --CP OKSRENCO is marked as single, therefore need to set the org_id
        FND_REQUEST.set_org_id(l_org_id);

        l_mode := FND_REQUEST.SET_MODE(TRUE);
        req_id := FND_REQUEST.submit_request('OKS', 'OKSRENCO', NULL, SYSDATE, FALSE,
                                             p_oie_id);
        RETURN(req_id);

    END SUBMIT_FORM_CONC;

-----------------------------------------------------------------------------------------
--SUBMIT CONC PROGRAM
-----------------------------------------------------------------------------------------
    PROCEDURE SUBMIT_CONC(ERRBUF                         OUT NOCOPY VARCHAR2,
                          RETCODE                        OUT NOCOPY NUMBER,
                          p_oie_id                       IN NUMBER) IS
    l_errbuf VARCHAR2(200);
    l_retcode NUMBER;
    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := FND_API.G_TRUE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);

    l_msg_index_out NUMBER;
    l_msg_index  NUMBER;

    l_cle_id NUMBER;

    BEGIN

        OKS_RENCON_PVT.SUBMIT(
            errbuf => l_errbuf,
            retcode => l_retcode,
            p_api_version => l_api_version,
            p_init_msg_list => l_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_conc_program => 'Y',
            p_oie_id => p_oie_id);

    END  SUBMIT_CONC;

-----------------------------------------------------------------------------------------
--SUBMIT
-----------------------------------------------------------------------------------------
    PROCEDURE SUBMIT(ERRBUF                         OUT NOCOPY VARCHAR2,
                     RETCODE                        OUT NOCOPY NUMBER,
                     p_api_version                  IN NUMBER,
                     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
                     p_conc_program                 IN VARCHAR2,
                     p_oie_id                       IN NUMBER) IS

    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE chr_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

    l_api_version  CONSTANT NUMBER := 1.0;
    l_api_name CONSTANT VARCHAR2(30) := 'SUBMIT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;


/*
    CURSOR get_oper_top_lines IS
        SELECT b. * FROM okc_operation_lines a, okc_operation_lines b
        WHERE a.oie_id = p_oie_id
        AND b.oie_id = p_oie_id
        AND a.id = b.parent_ole_id
        AND a.parent_ole_id IS NULL
        AND b.process_flag IN ('A', 'E')
        AND b.select_yn = 'Y';
*/
CURSOR get_oper_top_lines IS
SELECT b.*,
       chr.inv_organization_id,
       chr.authoring_org_id,
       chr.currency_code
FROM okc_operation_lines b,
     okc_k_lines_b cle,
     okc_k_headers_all_b chr,
     okc_statuses_b st
WHERE b.oie_id = p_oie_id
and cle.id = b.object_cle_id
and cle.cle_id is null
and b.process_flag IN ('A','E')
and b.select_yn = 'Y'
and cle.date_terminated is NULL
and NVL(cle.line_renewal_type_code,'FUL') not in ('DNR', 'KEP') -- bug 5078797
and chr.id = cle.dnz_chr_id
and chr.sts_code = st.code
and st.ste_code in ('ACTIVE','EXPIRED','SIGNED')
and nvl(renewal_type_code, G_GCD_RENEWAL_TYPE) <> 'DNR';

/*
    CURSOR get_oper_sub_lines(p_id IN NUMBER) IS
        SELECT * FROM okc_operation_lines
        WHERE parent_ole_id = p_id
        AND process_flag IN ('A', 'E')
        AND select_yn = 'Y';
*/
CURSOR get_oper_sub_lines(p_id IN NUMBER) IS
SELECT ol.*, lse_id, start_date, end_date FROM okc_operation_lines ol,
okc_k_lines_b cle
WHERE parent_ole_id = p_id
and process_flag IN ('A','E')
and select_yn = 'Y'
and cle.id = ol.object_cle_id
and cle.date_terminated is NULL
and NVL(cle.line_renewal_type_code,'FUL') not in ('DNR', 'KEP') -- bug 5078797
and NOT EXISTS
(         SELECT 'x'
        FROM okc_operation_lines
        WHERE object_cle_id =  ol.object_cle_id
          AND subject_chr_id <> ol.subject_chr_id
          AND process_flag = 'P'
          AND active_yn = 'Y'
); -- bug 5085556


    CURSOR set_org(p_header_id IN NUMBER) IS
        SELECT inv_organization_id, org_id, currency_code --mmadhavi changed to Org_id for MOAC
        FROM okc_k_headers_all_b
        WHERE id = p_header_id;

-- MSENGUPT 11/07 the following cursor is not needed as it is taken care of in get subline  csr as we have to join to okc_k_lines
-- anyway

CURSOR get_subline_details(p_subline_id in NUMBER) IS
select lse_id,start_date,end_date
from okc_k_lines_b
where id =p_subline_id;

-- The following cursor was added by MSENGUPT 11/07
-- Need to check that target is valid as by the time the CP picks this up the target contract may not be in valid status

CURSOR valid_target (p_oie_id  IN  NUMBER) IS
  SELECT
  h.start_date,
  h.authoring_org_id,
  h.inv_organization_id,
  pr.object1_id1,
  h.currency_code
  FROM  okc_K_Headers_all_b h,
        okc_k_party_roles_b pr,
        okc_statuses_b st
  WHERE
        h.id=pr.dnz_chr_id and pr.cle_id is null
   and pr.rle_code = 'CUSTOMER'
   and h.scs_code IN ('SERVICE','WARRANTY')
   and h.template_yn = 'N'
   and h.sts_code = st.code
   and st.ste_code = 'ENTERED'
   and h.id in
     (select target_chr_id from okc_operation_instances where id = p_oie_id);


    l_target_header_id          NUMBER;
    l_source_header_id          NUMBER;
    lt_source_header_id         NUMBER := 0;
    l_target_line_id            NUMBER;
    l_cle_id                    NUMBER := NULL;
    s_cle_id                    NUMBER := NULL;
    i                           NUMBER := 0;
    l_conc_status               BOOLEAN := TRUE;

    l_init_msg_list             VARCHAR2(2000) := OKC_API.G_FALSE;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(4000);

    l_target_curr               VARCHAR2(15);
    l_source_curr               VARCHAR2(15);

    l_start_date                DATE;
    l_authoring_org_id          NUMBER;
    l_inv_organization_id       NUMBER;
    l_party_id                  NUMBER;
    l_currency_code             VARCHAR2(30);
    l_msg_index_out             NUMBER;

    l_subject_sub_line_tbl      OKS_REPRICE_PVT.sub_line_tbl_type;
    l_need_conversion           VARCHAR2(1); -- Currency conversion required? (Y/N)
    l_can_copy                  VARCHAR2(1) := 'Y';

    l_opl_id_tbl                num_tbl_type;
    l_opl_sub_cle_id_tbl        num_tbl_type;
    l_opl_status_tbl            chr_tbl_type;
    l_src_sub_line_id_tbl       num_tbl_type;
    l_date_renewed              DATE;

    l_update_date               DATE;
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_request_id                NUMBER;
    l_prog_appl_id              NUMBER;
    l_prog_id                   NUMBER;
    l_warnings                  BOOLEAN := FALSE;
    l_errors                    BOOLEAN := FALSE;
    l_dummy                     BOOLEAN;

l_rnrl_rec_in                    OKS_RENEW_UTIL_PVT.RNRL_REC_TYPE;
l_rnrl_rec_out                   OKS_RENEW_UTIL_PVT.RNRL_REC_TYPE;


    BEGIN

        log_messages('Renewal Consolidation conurrent program - BEGIN, p_oie_id='|| p_oie_id);
        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin','l_conc_program = ' || l_conc_program ||' p_oie_id='|| p_oie_id);
        END IF;

        --standard api initilization and checks
        SAVEPOINT submit_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

-- Added by MSENGUPT 11/07
-- Need to check that target is valid as by the time the CP picks this up the target contract may not be in valid status
-- For renewal consolidation, there can be only one target_contract_id for the oie_id
  retcode := 0;
  OPEN  Valid_target(p_oie_id) ;
  FETCH valid_target INTO
                    l_start_date,
                    l_authoring_org_id,
                    l_inv_organization_id,
                    l_party_id,
                    l_currency_code;
  IF valid_target%NOTFOUND THEN
       LOG_MESSAGES('The target contract is not found - maybe invalid status');
-- this is a log message only for debugging.
       retcode := 2;
  END IF;
  CLOSE valid_target;
  IF retcode = 2 then
      return;
  END IF;

  l_start_date := l_start_date - 1;

      -- Since the renewal consolidation process ensures common customer/party/operating unit, we will cache the GCDrenewal type
      -- based on the target contracts info.
      -- This value will be used in the cursors NVL of header renewal type

  LOG_MESSAGES('Calling OKS_RENEW_UTIL_PUB.GET_RENEW_RULES');
  LOG_MESSAGES('******  Parameters *********');
  LOG_MESSAGES('l_party_id : '||l_party_id);
  LOG_MESSAGES('l_authoring_org_id : '||l_authoring_org_id);
  LOG_MESSAGES('l_start_date : '||to_char(l_start_date,'DD-MON-YYYY'));
  LOG_MESSAGES(' ');
  OKS_RENEW_UTIL_PUB.GET_RENEW_RULES (
                                          p_api_version      =>    1.0,
                                          p_init_msg_list    => OKC_API.G_FALSE,
                                          x_return_status    => l_return_status,
                                          x_msg_count        =>    l_msg_count,
                                          x_msg_data         =>    l_msg_data,
                                          P_Chr_Id           =>    NULL,
                                          P_PARTY_ID         =>    l_party_id,
                                          P_ORG_ID           => l_authoring_org_id,
                                          P_Date             =>    l_start_date,
                                          P_RNRL_Rec         => l_rnrl_rec_in,
                                          X_RNRL_Rec         => l_rnrl_rec_out
                                         );
   IF l_return_status <> 'S' THEN
       LOG_MESSAGES('Error from getting gcd renewal type: '); -- this is a log message only for debugging.
       errbuf := substr(x_msg_data,1,200);
       LOG_MESSAGES(errbuf);
       retcode := 2;
       return;
   ELSE
         G_GCD_RENEWAL_TYPE := nvl(l_rnrl_rec_out.renewal_type, 'X');
   END IF;
   i:=0;
       LOG_MESSAGES('After Calling OKS_RENEW_UTIL_PUB.GET_RENEW_RULES');
       log_messages('Renewal Type derived from GCD is :'||G_GCD_RENEWAL_TYPE);
       LOG_MESSAGES(' ');

-- End of Added by MSENGUPT 11/07

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_return_status := FND_API.G_RET_STS_SUCCESS;
        retcode := 0; --0 for success, 1 for warning, 2 for error
        errbuf := NULL;
        l_conc_program := p_conc_program;

        l_subject_sub_line_tbl.delete;

        FOR cur_get_oper_top_lines IN get_oper_top_lines LOOP


            l_target_header_id := cur_get_oper_top_lines.subject_chr_id;
            l_target_curr := get_currency(l_target_header_id);
            l_source_curr := get_currency(cur_get_oper_top_lines.object_chr_id);

 log_messages('Target Header Id: '||l_target_header_id);
 log_messages('Source Currency: '||l_source_curr);
 log_messages('Target Currency: '||l_target_curr);
 LOG_MESSAGES(' ');

            IF l_target_curr <> l_source_curr THEN
                l_need_conversion := 'Y';
            ELSE
                l_need_conversion := 'N';
            END IF;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.check_curr','Source Currency='|| l_source_curr ||' ,Source hdr id='|| cur_get_oper_top_lines.object_chr_id
                               ||' ,Target Currency='|| l_target_curr || ' ,Target hdr id='|| l_target_header_id ||' ,l_need_conversion='|| l_need_conversion);
            END IF;

            FOR cur_set_org IN set_org(l_target_header_id) LOOP

                OKC_CONTEXT.set_okc_org_context(cur_set_org.org_id, cur_set_org.inv_organization_id); --mmadhavi using org_id for MOAC

  Log_Messages('Authoring Org: '||cur_set_org.org_id);
  Log_Messages('Inventory Org: '||cur_set_org.inv_organization_id);
  LOG_MESSAGES(' ');


                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name ||'.set_context','Authoring Org='|| cur_set_org.org_id ||' Inventory Org='|| cur_set_org.inv_organization_id);
                END IF;

            END LOOP;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.check_topline_merge','Calling merge, p_source_line_id='|| cur_get_oper_top_lines.object_cle_id
                               ||' ,p_target_contract_id='|| cur_get_oper_top_lines.subject_chr_id);
            END IF;

            l_target_line_id := NULL;
            MERGE(p_source_line_id => cur_get_oper_top_lines.object_cle_id,
                  p_target_contract_id => cur_get_oper_top_lines.subject_chr_id,
                  x_target_line_id => l_target_line_id);

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.check_topline_merge','After call to merge, l_target_line_id='|| l_target_line_id);
            END IF;


            IF l_target_line_id IS NULL THEN
                -- Before copying top line to target, make sure top line has at least one
                -- unprocessed sub line.
                LOG_MESSAGES('Merge line NOT found');
                l_can_copy := can_copy_topline(cur_get_oper_top_lines.id);
            ELSE
                LOG_MESSAGES('Merge line found:'|| l_target_line_id);
                l_can_copy := 'N';
            END IF;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'l_can_copy=' || l_can_copy);
            END IF;

            log_messages('Source Topline id='|| cur_get_oper_top_lines.object_cle_id );
            log_messages('Target Header id='|| cur_get_oper_top_lines.subject_chr_id );
            log_messages('Target Topline id='|| l_target_line_id );
            log_messages('l_can_copy='|| l_can_copy);
            LOG_MESSAGES(' ');

            IF l_can_copy = 'Y' THEN
                ------------------------------------------------------------
                ---COPY the TOP LINE FROM SOURCE TO TARGET
                ------------------------------------------------------------

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.top_line_copy','Calling OKS_RENCPY_PVT.copy_contract_line p_from_cle_id='||cur_get_oper_top_lines.object_cle_id||
                    ' ,p_from_chr_id='||cur_get_oper_top_lines.object_chr_id||' ,p_to_cle_id=NULL ,p_to_chr_id='||cur_get_oper_top_lines.subject_chr_id ||' ,p_need_conversion='|| l_need_conversion);
                END IF;

    LOG_MESSAGES('Calling OKS_RENCPY_PVT.COPY_CONTRACT_LINES 1: p_need_conversion = '|| l_need_conversion);
    LOG_MESSAGES(' ');

                OKS_RENCPY_PVT.copy_contract_line(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data,
                    p_from_cle_id => cur_get_oper_top_lines.object_cle_id,
                    p_from_chr_id => cur_get_oper_top_lines.object_chr_id,
                    p_to_cle_id => NULL,
                    p_to_chr_id => cur_get_oper_top_lines.subject_chr_id,
                    p_lse_id => NULL,
                    p_to_template_yn => 'N',
                    p_copy_reference => 'COPY',
                    p_copy_line_party_yn => 'Y',
                    p_renew_ref_yn => 'N',
                    p_need_conversion => l_need_conversion, -- currency code conversion needed for top lines
                    x_cle_id => l_cle_id);

  LOG_MESSAGES('COPY the TOP LINE FROM SOURCE TO TARGET l_return_status = ' || l_return_status);
  LOG_MESSAGES('x_cle_id = ' || l_cle_id);
  LOG_MESSAGES(' ');


                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.top_line_copy','After call to OKS_RENCPY_PVT.copy_contract_line l_return_status='|| l_return_status ||' ,x_cle_id='|| l_cle_id);
                END IF;

                --for U:unexpected error stop, for E:regular error, try next line
                --for W:warnings or S:Success continue
                IF (l_return_status = FND_API.g_ret_sts_success) THEN
                    NULL; --continue
                ELSIF(l_return_status = OKC_API.g_ret_sts_warning) THEN
                    l_warnings := TRUE;
                ELSIF (l_return_status = FND_API.g_ret_sts_error) THEN
                    l_errors := TRUE;
                ELSE --all others treated as unexpected
                    x_return_status := l_return_status;
                    RAISE FND_API.g_exc_unexpected_error;
                END IF;

                ------------------------------------------------------------------------------
                ----DEPENDING on the return status u update the operation lines process flag
                ------------------------------------------------------------------------------
                l_opl_id_tbl(l_opl_id_tbl.count +1) := cur_get_oper_top_lines.id;

                IF (l_return_status = FND_API.g_ret_sts_error) THEN

                    log_messages('Topline id='|| cur_get_oper_top_lines.object_cle_id ||' did not get copied');

                    l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := NULL;
                    l_opl_status_tbl(l_opl_id_tbl.count) := 'E';
                ELSE
                    --only come here if l_return_status in (S,W)
                    log_messages('Topline id='|| cur_get_oper_top_lines.object_cle_id ||' copied to id='|| l_cle_id);

                    l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := l_cle_id;
                    l_opl_status_tbl(l_opl_id_tbl.count) := 'P';

                    ------------------------------------------------------------------------------
                    ----If Copy is successful Delete the SLH and SLL rules that were copied
                    ------------------------------------------------------------------------------
                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.top_line_billing','Calling  OKS_BILL_UTIL_PUB.delete_slh_rule, p_cle_id='|| l_cle_id);
                    END IF;

                    LOG_MESSAGES('Calling OKS_BILL_UTIL_PUB.delete_slh_rule');

                    OKS_BILL_UTIL_PUB.delete_slh_rule(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_cle_id => l_cle_id,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

                    LOG_MESSAGES('After Calling OKS_BILL_UTIL_PUB.delete_slh_rule l_return_status : '||l_return_status);
                    LOG_MESSAGES(' ');

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.top_line_billing','After call to OKS_BILL_UTIL_PUB.delete_slh_rule, l_return_status='|| l_return_status);
                    END IF;

                    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                    s_cle_id := NULL;
                    l_subject_sub_line_tbl.delete;
                    i := 0;

                    ---------------------------------------------------------------------------
                    ---COPY all sublines in operation lines under target top line created above
                    ---------------------------------------------------------------------------
                    FOR cur_get_oper_sub_lines IN get_oper_sub_lines(cur_get_oper_top_lines.id)
                        LOOP
                        IF find_ol_status(cur_get_oper_sub_lines.object_cle_id) <> 'P' THEN

                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_copy','Calling OKS_RENCPY_PVT.copy_contract_line  p_need_conversion = '|| l_need_conversion ||
                                ' ,p_from_cle_id='|| cur_get_oper_sub_lines.object_cle_id ||' ,p_from_chr_id='|| cur_get_oper_sub_lines.object_chr_id||' ,p_to_cle_id='|| l_cle_id ||
                                ' ,p_to_chr_id='|| cur_get_oper_sub_lines.subject_chr_id);
                            END IF;


                            LOG_MESSAGES('Calling OKS_RENCPY_PVT.copy_contract_line');
                            LOG_MESSAGES('p_from_cle_id : '||cur_get_oper_sub_lines.object_cle_id);

                            OKS_RENCPY_PVT.copy_contract_line(
                                p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                p_from_cle_id => cur_get_oper_sub_lines.object_cle_id,
                                p_from_chr_id => cur_get_oper_sub_lines.object_chr_id,
                                p_to_cle_id => l_cle_id,
                                p_to_chr_id => cur_get_oper_sub_lines.subject_chr_id,
                                p_lse_id => NULL,
                                p_to_template_yn => 'N',
                                p_copy_reference => 'COPY',
                                p_copy_line_party_yn => 'Y',
                                p_renew_ref_yn => 'N',
                                p_need_conversion => l_need_conversion,
                                x_cle_id => s_cle_id);

                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_copy','After call to OKS_RENCPY_PVT.copy_contract_line, l_return_status=' || l_return_status ||' ,x_cle_id=' || s_cle_id);
                            END IF;

                            LOG_MESSAGES('After Calling OKS_RENCPY_PVT.copy_contract_line, l_return_status : '||l_return_status);
                            LOG_MESSAGES(' ');
                            IF (l_return_status = FND_API.g_ret_sts_success) THEN
                                NULL;
                            ELSIF(l_return_status = OKC_API.g_ret_sts_warning) THEN
                                l_warnings := TRUE;
                            ELSIF (l_return_status = FND_API.g_ret_sts_error) THEN
                                l_errors := TRUE;
                            ELSE
                                x_return_status := l_return_status;
                                RAISE FND_API.g_exc_unexpected_error;
                            END IF;


                            l_opl_id_tbl(l_opl_id_tbl.count +1) := cur_get_oper_sub_lines.id;
                            --------------------------------------------------------------------------
                            --DEPENDING on the return status u update the operation lines process flag
                            --------------------------------------------------------------------------
                            IF (l_return_status = FND_API.g_ret_sts_error) THEN
                                log_messages('    Subline id='|| cur_get_oper_sub_lines.object_cle_id ||' did not get copied');

                                l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := NULL;
                                l_opl_status_tbl(l_opl_id_tbl.count) := 'E';

                            ELSE
                                --only come here if l_return_status in (S,W)
                                log_messages('    Subline id='|| cur_get_oper_sub_lines.object_cle_id ||' copied to id='|| s_cle_id);

                                l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := s_cle_id;
                                l_opl_status_tbl(l_opl_id_tbl.count) := 'P';

                                l_subject_sub_line_tbl(i) := s_cle_id;

                                --------------------------------------------------------------------------
                                ----If Copy is successful Delete the SLH and SLL rules that were copied
                                --------------------------------------------------------------------------
                                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_billing','Calling  OKS_BILL_UTIL_PUB.delete_slh_rule, p_cle_id='|| s_cle_id);
                                END IF;


                                LOG_MESSAGES('Calling OKS_BILL_UTIL_PUB.delete_slh_rule');

                                OKS_BILL_UTIL_PUB.delete_slh_rule(
                                    p_api_version => 1.0,
                                    p_init_msg_list => FND_API.G_FALSE,
                                    p_cle_id => s_cle_id,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data);

                                LOG_MESSAGES('After Calling OKS_BILL_UTIL_PUB.delete_slh_rule, l_return_status: '||l_return_status);
                                LOG_MESSAGES(' ');

                                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_billing','After call to OKS_BILL_UTIL_PUB.delete_slh_rule, l_return_status='|| l_return_status);
                                END IF;

                                IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                    RAISE FND_API.g_exc_unexpected_error;
                                ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                                    RAISE FND_API.g_exc_error;
                                END IF;

                                --------------------------------------------------------------------------
                                ---- Update the source subline with the renewal date
                                --------------------------------------------------------------------------
                                l_src_sub_line_id_tbl(l_src_sub_line_id_tbl.count +1) := cur_get_oper_sub_lines.object_cle_id;

                                i := i + 1;
                            END IF;
                        END IF;
                    END LOOP; --subline loop

                    -------------------------------------------------------------------------------
                    ---CALL OKS_REPRICE_PVT.Call_Pricing_Api To adjust the price for those sublines
                    -------------------------------------------------------------------------------
                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_repricing','Calling OKS_REPRICE_PVT.call_pricing_api p_subject_chr_id='||l_target_header_id||
                        ' ,p_subject_top_line_id='||l_cle_id||' ,p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.count);
                    END IF;

                    LOG_MESSAGES('Calling OKS_REPRICE_PVT.call_pricing_api');
                    LOG_MESSAGES('p_subject_chr_id='||l_target_header_id);
                    LOG_MESSAGES('p_subject_top_line_id='||l_cle_id);
                    LOG_MESSAGES('p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.count);

/*
 * Bug 6114024 Call moved after update to operation lines
                    OKS_REPRICE_PVT.call_pricing_api(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        p_subject_chr_id => l_target_header_id,
                        p_subject_top_line_id => l_cle_id,
                        p_subject_sub_line_tbl => l_subject_sub_line_tbl );
*/

                    LOG_MESSAGES('After Calling OKS_REPRICE_PVT.call_pricing_api l_return_status: '||l_return_status);
                    LOG_MESSAGES(' ');

                    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_repricing','After call to OKS_REPRICE_PVT.call_pricing_api l_return_status='|| l_return_status);
                    END IF;

                    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                    log_messages('Top line id='||l_cle_id||' repriced');
                    LOG_MESSAGES(' ');

                END IF; --of if topline successfully copied

            ELSE

                -----------------------------------------------------------------------------
                ---COPY all sublines in operation lines under merge top line l_target_line_id
                -----------------------------------------------------------------------------

                s_cle_id := NULL;
                l_subject_sub_line_tbl.delete;
                i := 0;

                FOR cur_get_oper_sub_lines IN get_oper_sub_lines(cur_get_oper_top_lines.id) LOOP
                    IF find_ol_status(cur_get_oper_sub_lines.object_cle_id) <> 'P' THEN


                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_copy','Calling OKS_RENCPY_PVT.copy_contract_line  p_need_conversion = '|| l_need_conversion ||
                            ' ,p_from_cle_id='|| cur_get_oper_sub_lines.object_cle_id ||' ,p_to_cle_id='|| l_target_line_id ||' ,p_to_chr_id='|| cur_get_oper_sub_lines.subject_chr_id);
                        END IF;

                        LOG_MESSAGES('---COPY all sublines in operation lines under merge top line l_target_line_id----');
                        LOG_MESSAGES('Calling OKS_RENCPY_PVT.copy_contract_line p_from_cle_id : '||cur_get_oper_sub_lines.object_cle_id);
                        LOG_MESSAGES('p_need_conversion = '|| l_need_conversion);
                        LOG_MESSAGES('p_from_cle_id='|| cur_get_oper_sub_lines.object_cle_id);
                        LOG_MESSAGES('p_to_cle_id='|| l_target_line_id);
                        LOG_MESSAGES('p_to_chr_id='|| cur_get_oper_sub_lines.subject_chr_id);
                        LOG_MESSAGES(' ');

                        OKS_RENCPY_PVT.copy_contract_line(
                            p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_FALSE,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            p_from_cle_id => cur_get_oper_sub_lines.object_cle_id,
                            p_from_chr_id => cur_get_oper_sub_lines.object_chr_id,
                            p_to_cle_id => l_target_line_id,
                            p_to_chr_id => cur_get_oper_sub_lines.subject_chr_id,
                            p_lse_id => NULL,
                            p_to_template_yn => 'N',
                            p_copy_reference => 'COPY',
                            p_copy_line_party_yn => 'Y',
                            p_renew_ref_yn => 'N',
                            p_need_conversion => l_need_conversion,
                            x_cle_id => s_cle_id);

                        LOG_MESSAGES('After Calling OKS_RENCPY_PVT.copy_contract_line l_return_status : '||l_return_status);
                        LOG_MESSAGES(' ');

                        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_copy','After call to OKS_RENCPY_PVT.copy_contract_line, l_return_status=' || l_return_status ||' ,x_cle_id=' || s_cle_id);
                        END IF;

                        IF (l_return_status = FND_API.g_ret_sts_success) THEN
                            NULL;
                        ELSIF(l_return_status = OKC_API.g_ret_sts_warning) THEN
                            l_warnings := TRUE;
                        ELSIF (l_return_status = FND_API.g_ret_sts_error) THEN
                            l_errors := TRUE;
                        ELSE
                            x_return_status := l_return_status;
                            RAISE FND_API.g_exc_unexpected_error;
                        END IF;


                        l_opl_id_tbl(l_opl_id_tbl.count +1) := cur_get_oper_sub_lines.id;
                        ------------------------------------------------------------------------------
                        ----DEPENDING on the return status u update the operation lines process flag
                        ------------------------------------------------------------------------------
                        IF (l_return_status = FND_API.g_ret_sts_error) THEN
                            log_messages('    Subline id='|| cur_get_oper_sub_lines.object_cle_id ||' did not get copied');

                            l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := NULL;
                            l_opl_status_tbl(l_opl_id_tbl.count) := 'E';
                        ELSE
                            --only come here if l_return_status in (S,W)
                            log_messages('    Subline id='|| cur_get_oper_sub_lines.object_cle_id ||' copied to id='|| s_cle_id);

                            l_opl_sub_cle_id_tbl(l_opl_id_tbl.count) := s_cle_id;
                            l_opl_status_tbl(l_opl_id_tbl.count) := 'P';

                            l_subject_sub_line_tbl(i) := s_cle_id;

                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_billing','Calling  OKS_BILL_UTIL_PUB.delete_slh_rule, p_cle_id='|| s_cle_id);
                            END IF;

                            ------------------------------------------------------------------------------
                            ----If Copy is successful Delete the SLH and SLL rules that were copied
                            ------------------------------------------------------------------------------
                           LOG_MESSAGES('Calling OKS_BILL_UTIL_PUB.delete_slh_rule');

                            OKS_BILL_UTIL_PUB.delete_slh_rule(
                                p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_cle_id => s_cle_id,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data);

                           LOG_MESSAGES('After Calling OKS_BILL_UTIL_PUB.delete_slh_rule,l_return_status: '||l_return_status);
                           LOG_MESSAGES(' ');

                            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sub_line_billing','After call to OKS_BILL_UTIL_PUB.delete_slh_rule, l_return_status='|| l_return_status);
                            END IF;

                            IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                RAISE FND_API.g_exc_unexpected_error;
                            ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                                RAISE FND_API.g_exc_error;
                            END IF;

                            l_src_sub_line_id_tbl(l_src_sub_line_id_tbl.count +1) := cur_get_oper_sub_lines.object_cle_id;

                            i := i + 1;

                        END IF;
                    END IF;
                END LOOP; --subline loop

                -------------------------------------------------------------------------------
                ---CALL OKS_REPRICE_PVT.Call_Pricing_Api To adjust the price for those sublines
                -------------------------------------------------------------------------------

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_repricing','Calling OKS_REPRICE_PVT.call_pricing_api p_subject_chr_id='||l_target_header_id||
                    ' ,p_subject_top_line_id='||l_target_line_id||' ,p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.count);
                END IF;

               LOG_MESSAGES('Calling OKS_REPRICE_PVT.call_pricing_api');
               LOG_MESSAGES('p_subject_chr_id='||l_target_header_id);
               LOG_MESSAGES('p_subject_top_line_id='||l_target_line_id);
               LOG_MESSAGES('p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.COUNT);

 /*
 * Bug 6114024 Call moved after update to operation lines
                OKS_REPRICE_PVT.call_pricing_api(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data,
                    p_subject_chr_id => l_target_header_id,
                    p_subject_top_line_id => l_target_line_id,
                    p_subject_sub_line_tbl => l_subject_sub_line_tbl);
 */
               LOG_MESSAGES('After Calling OKS_REPRICE_PVT.call_pricing_api l_return_status: '||l_return_status);
               LOG_MESSAGES(' ');

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_repricing','After call to OKS_REPRICE_PVT.call_pricing_api l_return_status='|| l_return_status);
                END IF;

                IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                log_messages('Top line id='||l_target_line_id||' repriced');

            END IF;
        END LOOP;

        l_update_date := sysdate;
        l_user_id := FND_GLOBAL.USER_ID;
        l_login_id := FND_GLOBAL.LOGIN_ID;
        l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
        l_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
        l_prog_id := FND_GLOBAL.CONC_PROGRAM_ID;

       log_messages('***** Number of Source Top Lines/Sublines processed : ***** '||l_opl_id_tbl.COUNT);
       LOG_MESSAGES(' ');

        --update process status and subject cle id in okc_operation_lines for all
        --source toplines and sublines that where successfully copied to the target
        IF (l_opl_id_tbl.COUNT > 0 ) THEN

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_opn_lines','updating okc_operation_lines l_opl_id_tbl.COUNT='||l_opl_id_tbl.COUNT);
            END IF;

            FORALL i IN l_opl_id_tbl.FIRST..l_opl_id_tbl.LAST
                UPDATE okc_operation_lines SET
                    subject_cle_id = l_opl_sub_cle_id_tbl(i),
                    process_flag = l_opl_status_tbl(i),
                    object_version_number = object_version_number + 1,
                    last_updated_by = l_user_id,
                    last_update_date = l_update_date,
                    last_update_login = l_login_id,
                    request_id = l_request_id,
                    program_application_id = l_prog_appl_id,
                    program_id = l_prog_id,
                    program_update_date = l_update_date
                    WHERE id = l_opl_id_tbl(i);
        END IF;

       log_messages('***** Number of Source Sublines processed : ***** '||l_src_sub_line_id_tbl.COUNT);
       LOG_MESSAGES(' ');

-- bug 6114024
-- Call Pricing API after the update to okc_operation_lines
   IF (l_opl_id_tbl.COUNT > 0 ) THEN
      IF l_can_copy = 'Y' THEN
           LOG_MESSAGES('l_can_copy = Y ');
           LOG_MESSAGES('Calling OKS_REPRICE_PVT.call_pricing_api');
           LOG_MESSAGES('p_subject_chr_id='||l_target_header_id);
           LOG_MESSAGES('p_subject_top_line_id='||l_cle_id);
           LOG_MESSAGES('p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.count);

                    OKS_REPRICE_PVT.call_pricing_api(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        p_subject_chr_id => l_target_header_id,
                        p_subject_top_line_id => l_cle_id,
                        p_subject_sub_line_tbl => l_subject_sub_line_tbl );

          LOG_MESSAGES('After Calling OKS_REPRICE_PVT.call_pricing_api l_return_status: '||l_return_status);
          LOG_MESSAGES(' ');
      ELSE
           LOG_MESSAGES('l_can_copy = N ');
           LOG_MESSAGES('Calling OKS_REPRICE_PVT.call_pricing_api');
           LOG_MESSAGES('p_subject_chr_id='||l_target_header_id);
           LOG_MESSAGES('p_subject_top_line_id='||l_target_line_id);
           LOG_MESSAGES('p_subject_sub_line_tbl.count='||l_subject_sub_line_tbl.COUNT);

                OKS_REPRICE_PVT.call_pricing_api(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data,
                    p_subject_chr_id => l_target_header_id,
                    p_subject_top_line_id => l_target_line_id,
                    p_subject_sub_line_tbl => l_subject_sub_line_tbl);

          LOG_MESSAGES('After Calling OKS_REPRICE_PVT.call_pricing_api l_return_status: '||l_return_status);
          LOG_MESSAGES(' ');
      END IF;
   END IF; -- l_opl_id_tbl.COUNT > 0

-- end added Bug 6114024

        --update date_renewed for all the source sublines that where successfully copied
        IF (l_src_sub_line_id_tbl.COUNT > 0) THEN

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_sub_lines','updating date_renewed for source sublines l_src_sub_line_id_tbl.COUNT='||l_src_sub_line_id_tbl.COUNT);
            END IF;

            l_date_renewed := sysdate;
            FORALL i IN l_src_sub_line_id_tbl.FIRST..l_src_sub_line_id_tbl.LAST
                UPDATE okc_k_lines_b SET
                    date_renewed = l_date_renewed,
                    object_version_number = object_version_number + 1,
                    last_updated_by = l_user_id,
                    last_update_date = l_update_date,
                    last_update_login = l_login_id,
                    request_id = l_request_id,
                    program_application_id = l_prog_appl_id,
                    program_id = l_prog_id,
                    program_update_date = l_update_date
                    WHERE id = l_src_sub_line_id_tbl(i);

            --update date_renewed for all the source toplines if all sublines under them have been renewed
            --if any sublines under a topline are terminated or cancelled they are ignored
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_top_lines','updating date_renewed for source toplines');
            END IF;

            UPDATE okc_k_lines_b tl SET
                tl.date_renewed = l_date_renewed,
                tl.object_version_number = tl.object_version_number + 1,
                tl.last_updated_by = l_user_id,
                tl.last_update_date = l_update_date,
                tl.last_update_login = l_login_id,
                tl.request_id = l_request_id,
                tl.program_application_id = l_prog_appl_id,
                tl.program_id = l_prog_id,
                tl.program_update_date = l_update_date
                WHERE tl.id IN
                (SELECT b.object_cle_id FROM okc_operation_lines a, okc_operation_lines b
                WHERE a.oie_id = p_oie_id
                AND b.oie_id = p_oie_id
                AND a.id = b.parent_ole_id
                AND a.parent_ole_id IS NULL
                AND b.select_yn = 'Y')
                AND NOT EXISTS
                    (SELECT 1 FROM okc_k_lines_b sl
                    WHERE sl.cle_id = tl.id
                    AND sl.date_terminated IS NULL
                    AND sl.date_cancelled IS NULL
                    AND sl.date_renewed IS NULL);

            --update date_renewed for all the source headers if all toplines under them have been renewed
            --if any toplines are terminated or cancelled they are ignored
            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_headers','updating date_renewed for source headers');
            END IF;

            UPDATE okc_k_headers_all_b h SET
                h.date_renewed = l_date_renewed,
                h.object_version_number = h.object_version_number + 1,
                h.last_updated_by = l_user_id,
                h.last_update_date = l_update_date,
                h.last_update_login = l_login_id,
                h.request_id = l_request_id,
                h.program_application_id = l_prog_appl_id,
                h.program_id = l_prog_id,
                h.program_update_date = l_update_date
                WHERE h.id IN
                (SELECT a.object_chr_id FROM okc_operation_lines a
                WHERE a.oie_id = p_oie_id
                AND a.object_cle_id IS NULL
                AND a.subject_cle_id IS NULL
                AND a.select_yn = 'Y')
                AND NOT EXISTS
                    (SELECT 1 FROM okc_k_lines_b tl
                    WHERE tl.dnz_chr_id = h.id
                    AND tl.cle_id IS NULL
                    AND tl.lse_id IN (1,12,14,19)
                    AND tl.date_terminated IS NULL
                    AND tl.date_cancelled IS NULL
                    AND tl.date_renewed IS NULL);

        END IF; --of IF (l_src_sub_line_id_tbl.COUNT > 0) THEN

        l_opl_id_tbl.delete;
        l_opl_sub_cle_id_tbl.delete;
        l_opl_status_tbl.delete;
        l_src_sub_line_id_tbl.delete;
        l_subject_sub_line_tbl.delete;

        log_messages('Processed selected lines');
        LOG_MESSAGES(' ');


        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_invoice_text','Calling OKS_RENEW_CONTRACT_PVT.update_invoice_text p_chr_id='||l_target_header_id);
        END IF;

       LOG_MESSAGES('Calling OKS_RENEW_CONTRACT_PVT.update_invoice_text');

        OKS_RENEW_CONTRACT_PVT.update_invoice_text(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_chr_id => l_target_header_id);

       LOG_MESSAGES('After Calling OKS_RENEW_CONTRACT_PVT.update_invoice_text, l_return_status: '||l_return_status);
       LOG_MESSAGES(' ');

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_invoice_text','After call to OKS_RENEW_CONTRACT_PVT.update_invoice_text l_return_status='||l_return_status);
        END IF;

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;
        log_messages('Updated invoice text');
        LOG_MESSAGES(' ');LOG_MESSAGES(' ');

        ------------------------------------------------------------------------------
        ---Since all operations are done update the contract amount
        ------------------------------------------------------------------------------
        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_contract_amount','calling update_contract_amount p_header_id='||l_target_header_id);
        END IF;

        UPDATE_CONTRACT_AMOUNT(
            p_header_id => l_target_header_id,
            x_return_status => l_return_status);

        IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.update_contract_amount','after call to update_contract_amount l_return_status='||l_return_status);
        END IF;

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;
        log_messages('Updated contract header and line amounts');
        LOG_MESSAGES(' ');


        --set the x_return_status depending on any warnings or errors during line copy
        IF l_errors THEN
            x_return_status := OKC_API.g_ret_sts_warning;
            l_dummy := FND_CONCURRENT.set_completion_status('WARNING', null);
            log_messages('Some lines where not copied');
        ELSIF l_warnings THEN
            x_return_status := OKC_API.g_ret_sts_warning;
            l_dummy := FND_CONCURRENT.set_completion_status('WARNING', null);
            log_messages('Some lines where copied with warnings');
        ELSE
            x_return_status := FND_API.g_ret_sts_success;
            l_dummy := FND_CONCURRENT.set_completion_status('NORMAL', null);
        END IF;

        --log all the error and warning messages the CP log file
        IF (l_errors OR l_warnings) AND (p_conc_program = 'Y') THEN
            FOR i IN 1..FND_MSG_PUB.count_msg LOOP
                log_messages(FND_MSG_PUB.get(i, 'F'));
            END LOOP;
        END IF;

        COMMIT;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status=' || x_return_status ||' ,retcode='|| retcode);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        log_messages('Renewal Consolidation conurrent program - END');
        LOG_MESSAGES(' ');

    EXCEPTION

        WHEN  FND_API.g_exc_error THEN
            ROLLBACK TO submit_PVT;
            x_return_status := FND_API.g_ret_sts_error ;
            retcode := 2;
            l_dummy := FND_CONCURRENT.set_completion_status('ERROR', null);

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_error', 'x_return_status='||x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF(get_oper_top_lines%isopen) THEN
                CLOSE get_oper_top_lines;
            END IF;
            IF(get_oper_sub_lines%isopen) THEN
                CLOSE get_oper_sub_lines;
            END IF;
            IF(set_org%isopen) THEN
                CLOSE set_org;
            END IF;

            --log all the error messages the CP log file
            IF (p_conc_program = 'Y') THEN
                FOR i IN 1..FND_MSG_PUB.count_msg LOOP
                    log_messages(FND_MSG_PUB.get(i, 'F'));
                END LOOP;
            END IF;
            log_messages('Renewal Consolidation conurrent program - Error');

        WHEN  FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO submit_PVT;
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            retcode := 2;
            l_dummy := FND_CONCURRENT.set_completion_status('ERROR', null);

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status='||x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF(get_oper_top_lines%isopen) THEN
                CLOSE get_oper_top_lines;
            END IF;
            IF(get_oper_sub_lines%isopen) THEN
                CLOSE get_oper_sub_lines;
            END IF;
            IF(set_org%isopen) THEN
                CLOSE set_org;
            END IF;

            --log all the error messages the CP log file
            IF (p_conc_program = 'Y') THEN
                FOR i IN 1..FND_MSG_PUB.count_msg LOOP
                    log_messages(FND_MSG_PUB.get(i, 'F'));
                END LOOP;
            END IF;
            log_messages('Renewal Consolidation conurrent program - Unexpected Error');

        WHEN OTHERS THEN
            ROLLBACK TO submit_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            retcode := 2;
            l_dummy := FND_CONCURRENT.set_completion_status('ERROR', null);
            errbuf := SQLCODE || SQLERRM;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', errbuf);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, errbuf);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF(get_oper_top_lines%isopen) THEN
                CLOSE get_oper_top_lines;
            END IF;
            IF(get_oper_sub_lines%isopen) THEN
                CLOSE get_oper_sub_lines;
            END IF;
            IF(set_org%isopen) THEN
                CLOSE set_org;
            END IF;

            --log all the error messages the CP log file
            IF (p_conc_program = 'Y') THEN
                FOR i IN 1..FND_MSG_PUB.count_msg LOOP
                    log_messages(FND_MSG_PUB.get(i, 'F'));
                END LOOP;
            END IF;
            log_messages('Renewal Consolidation conurrent program - Error - OTHERS '||errbuf);

    END  SUBMIT;


    --anjkumar : procedure rewritten to do direct updates
    --also for R12 need to roll up tax_amount for toplines and header
    PROCEDURE UPDATE_CONTRACT_AMOUNT(p_header_id IN NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS

    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_AMOUNT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PROGRAM_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_top_lines(cp_chr_id IN NUMBER) IS
        SELECT c.cle_id, SUM(nvl(c.price_negotiated, 0)), SUM(nvl(s.tax_amount, 0))
        FROM okc_k_lines_b c, oks_k_lines_b s
        WHERE c.dnz_chr_id = cp_chr_id
        --get only sublines for 1,12,19 (14:no renewal, 46:no sublines)
        AND c.lse_id IN (7, 8, 9, 10, 11, 35, 13, 25)
        AND s.cle_id = c.id
        /* Added by sjanakir for Bug# 8287971 */
        AND c.date_cancelled is NULL
        GROUP BY c.cle_id;

    l_id_tbl        num_tbl_type;
    l_price_tbl     num_tbl_type;
    l_tax_tbl       num_tbl_type;

    l_update_date               DATE;
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_request_id                NUMBER;
    l_prog_appl_id              NUMBER;
    l_prog_id                   NUMBER;

    BEGIN

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_header_id='||p_header_id);
        END IF;

        SAVEPOINT update_contract_amount_PVT;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_header_id IS NOT NULL THEN

            l_update_date := sysdate;
            l_user_id := FND_GLOBAL.USER_ID;
            l_login_id := FND_GLOBAL.LOGIN_ID;
            l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
            l_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
            l_prog_id := FND_GLOBAL.CONC_PROGRAM_ID;

            --update the topline price_negotiated(OKC) and tax_amount(OKS) columns
            --no need for warranty(14 - cannot be renewed) and subscription (46 - no toplines)
            OPEN c_top_lines(p_header_id);
            LOOP
                FETCH c_top_lines BULK COLLECT INTO l_id_tbl, l_price_tbl, l_tax_tbl LIMIT 1000;

                IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_loop','l_id_tbl.count='||l_id_tbl.count);
                END IF;

                EXIT WHEN (l_id_tbl.COUNT = 0);

                FORALL i IN l_id_tbl.first..l_id_tbl.last
                UPDATE okc_k_lines_b
                    SET price_negotiated = l_price_tbl(i),
                    object_version_number = object_version_number + 1,
                    last_updated_by = l_user_id,
                    last_update_date = l_update_date,
                    last_update_login = l_login_id,
                    request_id = l_request_id,
                    program_application_id = l_prog_appl_id,
                    program_id = l_prog_id,
                    program_update_date = l_update_date
                    WHERE id = l_id_tbl(i);

                FORALL i IN l_id_tbl.first..l_id_tbl.last
                UPDATE oks_k_lines_b
                    SET tax_amount = l_tax_tbl(i),
                    object_version_number = object_version_number + 1,
                    last_updated_by = l_user_id,
                    last_update_date = l_update_date,
                    last_update_login = l_login_id,
                    request_id = l_request_id
                    WHERE cle_id = l_id_tbl(i);

            END LOOP;
            CLOSE c_top_lines;

            l_id_tbl.delete;
            l_price_tbl.delete;
            l_tax_tbl.delete;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_lines','top lines price_negotiated and tax_amount updated');
            END IF;

            --update the header
            UPDATE okc_k_headers_all_b h
                SET h.estimated_amount =
                    (SELECT SUM(price_negotiated) FROM okc_k_lines_b tl
                     WHERE tl.dnz_chr_id = p_header_id AND tl.cle_id IS NULL
                     AND tl.lse_id IN (1, 12, 19, 46)
                     /* Added by sjanakir for Bug# 8287971 */
                     AND tl.date_cancelled IS NULL),
                    h.object_version_number = h.object_version_number + 1,
                    h.last_updated_by = l_user_id,
                    h.last_update_date = l_update_date,
                    h.last_update_login = l_login_id,
                    h.request_id = l_request_id,
                    h.program_application_id = l_prog_appl_id,
                    h.program_id = l_prog_id,
                    h.program_update_date = l_update_date
                WHERE h.id = p_header_id;

            UPDATE oks_k_headers_b h
                SET h.tax_amount =
                    (SELECT SUM(stl.tax_amount) FROM okc_k_lines_b ctl, oks_k_lines_b stl
                     WHERE ctl.dnz_chr_id = p_header_id AND ctl.cle_id IS NULL
                     AND ctl.lse_id IN (1, 12, 19, 46) AND stl.cle_id = ctl.id
                     /* Added by sjanakir for Bug# 8287971 */
                     AND ctl.date_cancelled IS NULL),
                    h.object_version_number = h.object_version_number + 1,
                    h.last_updated_by = l_user_id,
                    h.last_update_date = l_update_date,
                    h.last_update_login = l_login_id,
                    h.request_id = l_request_id
                WHERE h.chr_id = p_header_id;

            IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.header','header estimated_amount and tax_amount updated');
            END IF;

        END IF;

        IF(FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level)THEN
           FND_LOG.string(FND_LOG.level_procedure,l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK TO update_contract_amount_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_top_lines%isopen) THEN
                CLOSE c_top_lines;
            END IF;


    END UPDATE_CONTRACT_AMOUNT;


    PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2) IS
    BEGIN
        IF l_conc_program = 'N' THEN
            NULL;
        ELSE
            fnd_file.put_line(FND_FILE.LOG, p_mesg);
        END IF;
    END LOG_MESSAGES;

-- Bug#5981381: Cache the class_operation_id instead of deriving everytime;

  BEGIN
     OPEN cur_class_operations ;
     FETCH cur_class_operations INTO G_RENCON_CLASS_OPERATION_ID;
     CLOSE cur_class_operations ;

END OKS_RENCON_PVT ;


/
