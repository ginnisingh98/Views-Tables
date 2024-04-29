--------------------------------------------------------
--  DDL for Package Body M4U_GET_CIN_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_GET_CIN_EXTN" AS
/* $Header: M4UCINXB.pls 120.0 2006/05/25 12:45:09 bsaratna noship $ */

        g_debug_level           NUMBER;
        g_success_code          VARCHAR2(30);
        g_error_code            VARCHAR2(30);
        g_unexp_err_code        VARCHAR2(30);
        g_err                   VARCHAR2(4000);

        -- Mapping to decode ego_uccnet_event.industry column
        -- F - FMCG
        -- H - HARDLINES
        -- S - SBDH
        -- This needs to be extended to support other industries.
        FUNCTION get_indstry_extn_nam
        (
                a_indstry_code IN VARCHAR2
        ) RETURN VARCHAR2
        AS
                x_indstry_name  VARCHAR2(30);
                l_indstry_code  VARCHAR2(30);
        BEGIN
                l_indstry_code := UPPER(a_indstry_code);

                IF l_indstry_code = 'F' THEN
                        x_indstry_name := 'FMCG';
                ELSIF l_indstry_code = 'H' THEN
                        x_indstry_name := 'HARDLINES';
                ELSIF l_indstry_code = 'S' THEN
                        x_indstry_name := 'SBDH';
                ELSE
                        x_indstry_name := l_indstry_code;
                END IF;
                RETURN x_indstry_name;
        END get_indstry_extn_nam;

        -- Update CLN history with XML generation framework status
        -- error message, status, cln_id are inputs
        -- autonomous transaction since calling ECX activity will rollback
        -- if the xml generation has errors,
        -- commit the cln raise
        -- NOTE: update subscription should be deferrred for this to work
        PROCEDURE update_cln_history
        (
                a_cln_id                IN      NUMBER,
                a_sts                   IN      VARCHAR2,
                a_msg                   IN      VARCHAR2
        ) AS
                PRAGMA AUTONOMOUS_TRANSACTION;
                l_cln_dtl_id            NUMBER;
                l_ret_sts               VARCHAR2(30);
                l_msg_data              VARCHAR2(4000);
                l_dsptn                 VARCHAR2(30);
                l_cln_sts               VARCHAR2(30);
                l_cln_pt                VARCHAR2(30);
                l_doc_sts               VARCHAR2(30);
                l_msg_txt               VARCHAR2(4000);
                l_col_type              VARCHAR2(100);
                l_cln_params            wf_parameter_list_t;
                l_key                   VARCHAR2(100);
        BEGIN
                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Entering m4u_get_cin_extn.update_cln_history',2);
                        cln_debug_pub.add('a_cln_id     - ' || a_cln_id,1);
                        cln_debug_pub.add('a_sts        - ' || a_sts,1);
                        cln_debug_pub.add('a_msg        - ' || a_msg,1);
                END IF;

                -- Actually this api is not called for success
                IF a_sts = g_success_code THEN
                        l_dsptn         := 'PENDING';
                        l_cln_sts       := 'COMPLETED';
                        l_doc_sts       := 'SUCCESS';
                        FND_MESSAGE.SET_NAME('CLN','M4U_CIN_EXTN_SUCCESS');
                        l_msg_txt       := FND_MESSAGE.GET;
                ELSE
                        l_dsptn         := 'REJECTED';
                        l_cln_sts       := 'ERROR';
                        l_doc_sts       := 'ERROR';
                        FND_MESSAGE.SET_NAME('CLN','M4U_CIN_EXTN_FAILURE');
                        FND_MESSAGE.SET_TOKEN('FAILURE_TEXT',a_msg);
                        l_msg_txt       := FND_MESSAGE.GET;
                END IF;

                -- Call CLN history update API
                l_key := 'M4U_EXTN_' || a_cln_id;
                IF g_debug_level <= 1 THEN
                        cln_debug_pub.add('Key - ' || l_key,2);
                END IF;

                l_cln_params   := wf_parameter_list_t();

                wf_event.addparametertolist('DOCUMENT_DIRECTION'        , 'OUT',l_cln_params);
                wf_event.addparametertolist('TRADING_PARTNER_TYPE'      , m4u_ucc_utils.c_party_type,l_cln_params);
                wf_event.addparametertolist('TRADING_PARTNER_ID'        , m4u_ucc_utils.g_party_id,l_cln_params);
                wf_event.addparametertolist('TRADING_PARTNER_SITE'      , m4u_ucc_utils.g_party_site_id,l_cln_params);
                wf_event.addparametertolist('COLLABORATION_ID'          , a_cln_id,l_cln_params);
                wf_event.addparametertolist('DISPOSITION'               , l_dsptn,l_cln_params);
                wf_event.addparametertolist('ROSETTANET_CHECK_REQUIRED' , 'FALSE',l_cln_params);
                wf_event.addparametertolist('DOCUMENT_STATUS'           , l_doc_sts,l_cln_params);
                wf_event.addparametertolist('MESSAGE_TEXT'              , l_msg_txt,l_cln_params);
                wf_event.addparametertolist('APPLICATION_ID'            , m4u_ucc_utils.c_resp_appl_id,l_cln_params);
                wf_event.addparametertolist('COLLABORATION_STATUS'      , l_cln_sts,l_cln_params);

                wf_event.raise( p_event_name =>'oracle.apps.cln.ch.collaboration.update',
                                p_event_key  =>l_key,
                                p_parameters =>l_cln_params);

                commit;

                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_get_cin_extn.update_cln_history - Normal',2);
                END IF;

                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        -- ignore exceptions - log and continue
                        IF g_debug_level <= 6 THEN
                                cln_debug_pub.add('Unexpected error in m4u_get_cin_extn.update_cln_history',6);
                                cln_debug_pub.add(SQLCODE || ':' || substr(SQLERRM,1,255),6);
                                cln_debug_pub.add('Exiting m4u_get_cin_extn.update_cln_history - Exception',6);
                        END IF;
        END;

        -- Add any more validation here
        -- Check if all the required parameters are not null
        -- return error is any mandatory parameter is missing
        -- return values of cln_id, tp_id, industry_list on success
        PROCEDURE read_and_validate_inputs
        (       a_evnt          IN              WF_EVENT_T,
                x_cln_id        OUT NOCOPY      VARCHAR2,
                x_tp_id         OUT NOCOPY      VARCHAR2,
                x_indstry_list  OUT NOCOPY      VARCHAR2,
                x_ret_sts       OUT NOCOPY      VARCHAR2,
                x_ret_msg       OUT NOCOPY      VARCHAR2
        ) AS
                l_param         VARCHAR2(30);
                l_value         VARCHAR2(4000);
                l_param_list    wf_parameter_list_t;
        BEGIN
                l_param := NULL;

                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Entering m4u_get_cin_extn.read_and_validate_inputs',2);
                END IF;


                l_param_list := a_evnt.getParameterList();

                -- make sure all these mandatory parameters are not null
                IF l_param_list IS NULL OR l_param_list.count() = 0 THEN
                        l_param := 'Event parameter-list';
                ELSIF   a_evnt.getValueForParameter('INVENTORY_ITEM_ID')IS NULL THEN
                        l_param         := 'INVENTORY_ITEM_ID';
                ELSIF   a_evnt.getValueForParameter('ORGANIZATION_ID')IS NULL THEN
                        l_param := 'ORGANIZATION_ID';
                ELSIF   a_evnt.getValueForParameter('PARTY_SITE_ID') IS NULL THEN
                        l_param := 'PARTY_SITE_ID';
                ELSIF   a_evnt.getValueForParameter('CLN_ID') IS NULL THEN
                        l_param := 'CLN_ID';
                ELSIF   a_evnt.getValueForParameter('TP_GLN') IS NULL THEN
                        l_param := 'TP_GLN';
                END IF;

                -- if any of the mandatory paramters are not null return error
                IF l_param IS NOT NULL THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                        FND_MESSAGE.SET_TOKEN('PARAM',l_param);
                        FND_MESSAGE.SET_TOKEN('VALUE',NULL);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_error_code;
                END IF;

                -- returning these value sinces they are used as paramters
                -- for calling the map generation routine
                x_indstry_list  := a_evnt.getValueForParameter('INDUSTRY');
                x_cln_id        := a_evnt.getValueForParameter('CLN_ID');
                x_tp_id         := a_evnt.getValueForParameter('PARTY_SITE_ID');
                x_ret_sts       := g_success_code;
                x_ret_msg       := NULL;

                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_get_cin_extn.read_and_validate_inputs - Normal',2);
                END IF;
        END;


        --Support concatednate XML fragments size < 32767
        --API is called from the XGM and matches ECX signature
        --input event parameter contain XGM global variables
        --write XML as output
        --Raise exection on any errors and stop XML generation
        --This api is called from m4u_230_cin_out.xgm extensions/extensionsHookTag
        PROCEDURE get_xml_fragment
        (
                a_evnt  IN              WF_EVENT_T,
                x_xml   OUT NOCOPY      VARCHAR2
        ) AS
                l_param_list    wf_parameter_list_t;
                l_cln_id        NUMBER;
                l_tp_site_id    NUMBER;
                l_indstry_list  VARCHAR2(400);
                l_indstry       VARCHAR2(30);
                l_idx           NUMBER;
                l_ret_sts       VARCHAR2(30);
                l_ret_msg       VARCHAR2(4000);
                l_xml_frgmt     VARCHAR2(32767);
                l_upd_col       BOOLEAN;
                handled_exception exception;
        BEGIN
                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Entering m4u_get_cin_extn.get_xml_fragment',2);
                END IF;

                l_upd_col       := false;
                l_ret_sts       := g_success_code;
                l_ret_msg       := NULL;
                l_xml_frgmt     := NULL;
                l_param_list    := a_evnt.getParameterList();

                -- validate inputs, make sure all mandatory parameters are supplied
                read_and_validate_inputs(a_evnt,l_cln_id,l_tp_site_id,l_indstry_list,l_ret_sts,l_ret_msg);

                IF g_debug_level <= 1 THEN
                        cln_debug_pub.add('l_cln_id       - ' || l_cln_id);
                        cln_debug_pub.add('l_tp_site_id   - ' || l_tp_site_id);
                        cln_debug_pub.add('l_indstry_list - ' || l_indstry_list);
                        cln_debug_pub.add('l_ret_sts      - ' || l_ret_sts);
                        cln_debug_pub.add('l_ret_msg      - ' || l_ret_msg);
                END IF;
                -- validation failed, update CLN and raise exception
                IF l_ret_sts <> g_success_code THEN
                        IF g_debug_level <= 1 THEN
                                cln_debug_pub.add('Update_cln_history with failure',1);
                        END IF;
                        update_cln_history(l_cln_id,l_ret_sts,l_ret_msg);
                        RAISE handled_exception;
                END IF;

                IF trim(l_indstry_list) is null THEN
                        x_xml := NULL;
                        return;
                END IF;

                l_indstry_list := l_indstry_list || ':';

                l_idx := INSTR(l_indstry_list,':');

                IF g_debug_level <= 1 THEN
                        cln_debug_pub.add('l_idx        - ' || l_idx);
                END IF;

                -- loop through industry list
                -- industry1:industry2:industry3:
                WHILE l_idx > 0
                LOOP
                        l_ret_msg       := NULL;
                        l_indstry       := SUBSTR(l_indstry_list,1,l_idx-1);
                        l_indstry_list  := SUBSTR(l_indstry_list,l_idx+1);

                        IF g_debug_level <= 1 THEN
                                cln_debug_pub.add('l_indstry            - ' || l_indstry,1);
                                cln_debug_pub.add('l_indstry_list       - ' || l_indstry_list,1);
                        END IF;

                        l_indstry := get_indstry_extn_nam(l_indstry);

                        IF g_debug_level <= 1 THEN
                                cln_debug_pub.add('decoded l_indstry    - ' || l_indstry,1);
                        END IF;

                        l_ret_sts := g_success_code;

                        IF UPPER(l_indstry) NOT IN ('FMCG','HARDLINES') THEN
                                -- make call to extension API

                                IF g_debug_level <= 1 THEN
                                        cln_debug_pub.add('Calling  where  collaboration_id := a_cln_id',1);
                                END IF;

                                l_upd_col := true;
                                -- for industry code "XYZ" map-name = "M4U_EXTN_XYZ"
                                l_indstry := 'M4U_EXTN_' || l_indstry;
                                l_xml_frgmt := NULL;

                                -- generate XML fragement
                                m4u_xml_extn.generate_xml_fragment
                                (       a_extn_name             => l_indstry,
                                        a_tp_id                 => l_tp_site_id,
                                        a_tp_dflt               => true,
                                        a_param_lst             => l_param_list,
                                        a_log_lvl               => g_debug_level,
                                        a_remove_empty_elmt     => true,
                                        a_remove_empty_attr     => true,
                                        x_ret_sts               => l_ret_sts,
                                        x_ret_msg               => l_ret_msg,
                                        x_xml                   => l_xml_frgmt
                                );



                                IF g_debug_level <= 1 THEN
                                        cln_debug_pub.add('m4u_xml_extn.generate_xml_fragment Success',1);
                                        cln_debug_pub.add('l_ret_sts   - ' || l_ret_sts,1);
                                        cln_debug_pub.add('l_ret_msf   - ' || l_ret_msg,1);
                                        cln_debug_pub.add('XML Size    - ' || length(l_xml_frgmt),1);
                                        cln_debug_pub.add('Out-xml size- ' || length(x_xml),1);
                                END IF;

                                -- if sucess append XML and process next industry
                                IF l_ret_sts = g_success_code THEN
                                        x_xml := x_xml || l_xml_frgmt;
                                        IF g_debug_level <= 1 THEN
                                                cln_debug_pub.add('Concat successful ',1);
                                        END IF;
                                ELSE
                                        -- bail-out
                                        IF g_debug_level <= 1 THEN
                                                cln_debug_pub.add('Exiting loop',1);
                                        END IF;
                                        EXIT;
                                END IF;
                        END IF;

                        l_idx := INSTR(l_indstry_list,':');

                END LOOP;


                -- This is required since above loop can produce multiple segments
                -- Well-formed XML requires a single root node
                -- "OracleM4UExtensionFragment" is used in XSLT m4uoutcin.xsl
                IF l_ret_sts = g_success_code  THEN
                        IF g_debug_level <= 1 THEN
                                cln_debug_pub.add('Adding envelope',1);
                        END IF;
                        x_xml := '<OracleM4UExtensionFragment>' || x_xml;
                        x_xml := x_xml || '</OracleM4UExtensionFragment>';
                ELSE
                        -- update CLN with failure details
                        IF g_debug_level <= 1 THEN
                                cln_debug_pub.add('Update_cln_history with failure',1);
                        END IF;
                        update_cln_history(l_cln_id,l_ret_sts,l_ret_msg);
                        RAISE handled_exception;
                END IF;

                IF g_debug_level <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_get_cin_extn.get_xml_fragment - Normal',2);
                END IF;
                RETURN;
        EXCEPTION
                -- all handled errors reach here
                -- raise exception to stop M4USTD workflow
                WHEN handled_exception THEN
                        IF g_debug_level <= 6 THEN
                                cln_debug_pub.add('Unexpected error in m4u_get_cin_extn.get_xml_fragment',6);
                                cln_debug_pub.add(g_err,6);
                                cln_debug_pub.add('Exiting m4u_get_cin_extn.get_xml_fragment - Exception',6);
                        END IF;
                        RAISE;
                -- all unhandled errors reach here
                -- 1. update cln
                -- 2. raise exception to stop M4USTD workflow
                WHEN OTHERS THEN
                        IF g_debug_level <= 6 THEN
                                cln_debug_pub.add('Unexpected error in m4u_get_cin_extn.get_xml_fragment',6);
                                cln_debug_pub.add(SQLCODE || ':' || SQLERRM,6);
                                cln_debug_pub.add('Exiting m4u_get_cin_extn.get_xml_fragment - Exception',6);
                        END IF;
                        update_cln_history(l_cln_id,g_error_code,SQLCODE || SQLERRM);
                        RAISE;
        END get_xml_fragment;

BEGIN
        -- frequently used package variables
        g_debug_level   := NVL(FND_PROFILE.VALUE('CLN_DEBUG_LEVEL'), 5);
        g_success_code  := FND_API.G_RET_STS_SUCCESS;
        g_error_code    := FND_API.G_RET_STS_ERROR;
        g_unexp_err_code:= FND_API.G_RET_STS_UNEXP_ERROR;
END m4u_get_cin_extn;

/
