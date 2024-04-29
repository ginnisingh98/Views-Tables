--------------------------------------------------------
--  DDL for Package Body M4U_PARTY_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_PARTY_QUERY" AS
/*$Header: M4UQRPTB.pls 120.2 2005/06/14 12:03:44 appldev  $*/

        G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'm4u_global_regqry';
        l_debug_level           NUMBER;


        -- Name
        --      parse_param_list
        -- Purpose
        --      This procedure is called from the map m4u_230_party_qry_out.xgm
        --      The purpose of this procedure is to parse the parameter list
        --      supplied as input to each individual parameter.
        --      This is used becuase multiple optional parameters to the XGM are passed
        --      as a single Delimitor Separated Value list, since the ECXSTD/GETTPXML
        --      activity used in the workflow does allows us to specify only 5 paramters
        --      to the XGM
        -- Arguments
        --      p_param_list    - List of delimitor separated value
        --      x_org_gln       - Organization_GLN param filter to be used in Query Command
        --      x_duns_code     - Duns code parameter filter
        --      x_post_code     - Postal code parameter filter
        --      x_city          - City parameter filter
        --      x_return_status - return status 'S' on success else 'F'
        --      x_msg_data      - Failure message to be sent back to sysadmin
        -- Notes
        --      None.
        PROCEDURE parse_param_list(
                p_param_list            IN VARCHAR2,
                x_org_gln               OUT NOCOPY VARCHAR2,
                x_duns_code             OUT NOCOPY VARCHAR2,
                x_org_name              OUT NOCOPY VARCHAR2,
                x_post_code             OUT NOCOPY VARCHAR2,
                x_city                  OUT NOCOPY VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_data              OUT NOCOPY VARCHAR2 )
        IS
                l_pos                   NUMBER;
                r_pos                   NUMBER;
        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('=========================================', 2);
                        cln_debug_pub.Add('Entering m4u_party_query.parse_param_list', 2);
                END IF;

                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('p_param_list - ' || p_param_list, 1);
                END IF;

                    l_pos           := 1;
                r_pos           := INSTR(p_param_list,'$',1,1);
                x_org_gln       := SUBSTR(p_param_list,l_pos,r_pos-l_pos);
                    l_pos           := r_pos+1;

                IF x_org_gln IS NULL THEN
                        x_org_gln := '%';
                END IF;

                r_pos           := INSTR(p_param_list,'$',1,2);
                x_org_name      := SUBSTR(p_param_list,l_pos,r_pos-l_pos);
                l_pos           := r_pos+1;
                IF x_org_name IS NULL THEN
                        x_org_name      := '%';
                END IF;

                r_pos           := INSTR(p_param_list,'$',1,3);
                x_duns_code     := SUBSTR(p_param_list,l_pos,r_pos-l_pos);
                l_pos           := r_pos+1;
                IF x_duns_code IS NULL THEN
                        x_duns_code      := '%';
                END IF;


                r_pos           := INSTR(p_param_list,'$',1,4);
                x_post_code     := SUBSTR(p_param_list,l_pos,r_pos-l_pos);
                l_pos           := r_pos+1;
                IF x_post_code IS NULL THEN
                        x_post_code     := '%';
                END IF;

                r_pos           := INSTR(p_param_list,'$',1,5);
                x_city          := SUBSTR(p_param_list,l_pos,r_pos-l_pos);
                l_pos           := r_pos+1;
                IF x_city IS NULL THEN
                        x_city          := '%';
                END IF;


                x_return_status := FND_API.G_RET_STS_SUCCESS;
                x_msg_data      := '';

                IF (l_debug_Level <= 1) THEN
                        cln_debug_pub.Add('x_org_gln       - ' || x_org_gln, 1);
                        cln_debug_pub.Add('x_duns_code     - ' || x_duns_code, 1);
                        cln_debug_pub.Add('x_org_name      - ' || x_org_name, 1);
                        cln_debug_pub.Add('x_post_code     - ' || x_post_code, 1);
                        cln_debug_pub.Add('x_city          - ' || x_city, 1);
                        cln_debug_pub.Add('x_return_status - ' || x_return_status, 1);
                        cln_debug_pub.Add('x_msg_data      - ' || x_msg_data, 1);
                END IF;



                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_party_query.parse_param_list - normal', 2);
                        cln_debug_pub.Add('=================================================', 2);
                END IF;


        EXCEPTION
                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_msg_data      :=' - Unexpected error in m4u_party_query/parse_param_list -'|| SQLCODE ||' : '||SQLERRM;

        END parse_param_list;


        -- Name
        --      raise_partyqry_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The 'oracle.apps.m4u.partyqry.generate' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        -- Notes
        --
        PROCEDURE raise_partyqry_event(
                x_errbuf                OUT NOCOPY VARCHAR2,
                x_retcode               OUT NOCOPY NUMBER,
                p_tp_gln                IN VARCHAR2,
                p_org_gln               IN VARCHAR2,
                p_org_name              IN VARCHAR2,
                p_duns                  IN VARCHAR2,
                p_postal_code           IN VARCHAR2,
                p_city                  IN VARCHAR2,
                p_org_status            IN VARCHAR2,
                p_msg_count             IN NUMBER
          )
        IS
                l_event_parameters      wf_parameter_list_t;
                l_org_status            VARCHAR2(10);
                l_msg_data              VARCHAR2(50);
                l_event_key             VARCHAR2(50);
                l_error_code            VARCHAR2(50);
                l_ret_status            VARCHAR2(50);
                l_ptyqry_arg            VARCHAR2(200);
                l_error_msg             VARCHAR2(500);
                l_msg_count             NUMBER;
        BEGIN

                IF (l_debug_Level <= 2) THEN
                        cln_debug_pub.Add('M4U:----- Entering raise_partyqry_event  ------- ',2);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++ PARAMETERS RECEIVED FROM CONCURRENT PROGRAM ++ ',1);
                        cln_debug_pub.Add('p_tp_gln                     - '||p_tp_gln  ,1);
                        cln_debug_pub.Add('p_org_gln                    - '||p_org_gln,1);
                        cln_debug_pub.Add('p_org_name                   - '||p_org_name,1);
                        cln_debug_pub.Add('p_duns                       - '||p_duns  ,1);
                        cln_debug_pub.Add('p_postal_code                - '||p_postal_code,1);
                        cln_debug_pub.Add('p_city                       - '||p_city,1);
                        cln_debug_pub.Add('p_org_status                 - '||p_org_status,1);
                        cln_debug_pub.Add('p_msg_count                  - '||p_msg_count,1);
                        cln_debug_pub.Add('+++++++++++++++++++++++++++++++++++++++++++++++++++',1);
                END IF;

                l_msg_count := p_msg_count;
                -- Default the count to 10 if invalid value is input
                /*
                IF ((p_msg_count IS NULL) OR (p_msg_Count < 1)) AND (p_org_status IS NULL) THEN
                        l_msg_count := 10;
                END IF;
                */

                -- 1. Validation of the GLN
                IF NOT m4u_ucc_utils.validate_uccnet_attr
                                   (
                                        x_return_status         => l_ret_status,
                                        x_msg_data              => l_msg_data,
                                        p_attr_type             => 'GLN',
                                        p_attr_value            => p_tp_gln
                                   )THEN
                         IF (l_Debug_Level <= 5) THEN
                                 cln_debug_pub.Add('Trading Partner '||l_msg_data,4);
                         END IF;

                         RAISE FND_API.G_EXC_ERROR;
                END IF;


                -- Org gln should either contain a Wildcard/have valid GLN as parameter
                IF NOT(INSTR(p_org_gln,'%')>0 OR p_org_gln IS NULL) THEN
                        IF NOT m4u_ucc_utils.validate_uccnet_attr
                                   (
                                        x_return_status         => l_ret_status,
                                        x_msg_data              => l_msg_data,
                                        p_attr_type             => 'GLN',
                                        p_attr_value            => p_org_gln
                                   )THEN
                                 IF (l_Debug_Level <= 5) THEN
                                         cln_debug_pub.Add('Organization '||l_msg_data,4);
                                 END IF;

                                 RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END IF;

                -- Set the value for the status
                IF (p_org_status IS NOT NULL) THEN
                       IF (p_org_status = 'Active') THEN
                              l_org_status := 'AC';
                       ELSE
                              l_org_status := 'IN';
                       END IF;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Final p_org_status value          - '||l_org_status,1);
                END IF;

                 -- obtain a unique event-id
                SELECT  m4u_wlqid_s.NEXTVAL
                INTO    l_event_key
                FROM    dual;

                l_event_key := 'M4U_QRYPT_' || l_event_key;

                -- pass Concurrent program parameters as event parameters,
                -- to be used in outboud xml generation map              .

                -- passing all optional paramters in a single event attributes as a Delimiter Separated Value string
                l_ptyqry_arg := p_org_gln||'$'||p_org_name||'$'||p_duns||'$'||p_postal_code||'$'||p_city||'$';

                l_event_parameters := wf_parameter_list_t();

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_EVENT_KEY',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_EVENT_KEY                        - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER2',
                                        p_value         => l_msg_count,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER2  - Message Count      - '||p_msg_count,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER3',
                                        p_value         => p_tp_gln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER3  - TP GLN             - '||p_tp_gln,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_PARAMETER5',
                                        p_value         => l_ptyqry_arg,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_PARAMETER5 - Optional Parameters - '|| l_ptyqry_arg,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_TYPE',
                                        p_value         => 'M4U',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_TRANSACTION_TYPE                 - M4U',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_TRANSACTION_SUBTYPE',
                                        p_value         => 'PARTYQRY',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_TRANSACTION_SUBTYPE              - PARTYQRY',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ECX_DOCUMENT_ID',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ECX_DOCUMENT_ID                      - '||l_event_key,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'M4U_CLN_COLL_TYPE',
                                        p_value         => 'M4U_PARTY_QUERY',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_COLL_TYPE                    - M4U_PARTY_QUERY',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_CLN_DOC_TYPE',
                                        p_value         => 'M4U_PARTY_QUERY',
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_CLN_DOC_TYPE                     - M4U_PARTY_QUERY',1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'M4U_DOC_NO',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('M4U_DOC_NO                           - '||l_event_key,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE1',
                                        p_value         => m4u_ucc_utils.g_host_gln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE1                           - '||m4u_ucc_utils.g_host_gln,1);
                END IF;

                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE5',
                                        p_value         => m4u_ucc_utils.g_supp_gln,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE5                           - '||m4u_ucc_utils.g_supp_gln,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE12',
                                        p_value         => l_event_key,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE12                          - '||l_event_key,1);
                END IF;


                wf_event.AddParameterToList(
                                        p_name          => 'ATTRIBUTE14',
                                        p_value         => l_org_status,
                                        p_parameterlist => l_event_parameters   );
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('ATTRIBUTE14                          - '||l_org_status,1);
                END IF;


                -- set event parameters, end

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('--  Raising Event oracle.apps.m4u.outboundwf.generate  -- ',1);
                        cln_debug_pub.Add('p_event_key                          - '||l_event_key ,1);
                END IF;


                -- raise event to trigger outbound wlq generation WF
                wf_event.raise(
                                p_event_name            => 'oracle.apps.m4u.outboundwf.generate',
                                p_event_key             => l_event_key,
                                p_parameters            => l_event_parameters
                              );

                x_retcode  := 0;
                x_errbuf   := 'Successful';


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Event oracle.apps.m4u.outboundwf.generate raised',1);
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting raise_partyqry_event API/normal --------- ',2);
                END IF;


        -- Exception Handling
        EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
                    x_retcode          := 2 ;
                    x_errbuf           := l_msg_data;

                    IF (l_Debug_Level <= 5) THEN
                            cln_debug_pub.Add('Details: '||l_msg_data,4);
                            cln_debug_pub.Add('------- Exiting raise_partyqry_event API  :Error--------- ',2);
                    END IF;

             WHEN OTHERS THEN
                    x_retcode          := 2 ;
                    x_errbuf           := l_msg_data;

                    l_error_code       :=SQLCODE;
                    l_error_msg        :=SQLERRM;
                    FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                    FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                    FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);



                    IF (l_Debug_Level <= 5) THEN
                            cln_debug_pub.Add(x_errbuf, 5);
                            cln_debug_pub.Add('Details - '||FND_MESSAGE.GET , 5);
                            cln_debug_pub.Add('------- Exiting raise_partyqry_event API :Other Error --------- ',2);
                    END IF;

        END raise_partyqry_event;

        -- Name
        --      process_resp_org_data
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry
        --      This procedure recieves the organization info parsed from
        --      the UCCnet party-query command response
        -- Arguments
        --      p_org_gln                       - Party info received in response
        --      p_org_name                      - Party info received in response
        --      p_short_name                    - Party info received in response
        --      p_org_type                      - Party info received in response
        --      p_contact                       - Party info received in response
        --      p_org_status                    - Party info received in response
        --      p_role                          - Party info received in response
        --      p_addr1                         - Party info received in response
        --      p_addr2                         - Party info received in response
        --      p_city                          - Party info received in response
        --      p_state                         - Party info received in response
        --      p_zip                           - Party info received in response
        --      p_country                       - Party info received in response
        --      p_phone                         - Party info received in response
        --      p_fax                           - Party info received in response
        --      p_email                         - Party info received in response
        --      p_party_query_id                - Id of party command
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      None.
        PROCEDURE process_resp_org_data(
                p_org_gln                       IN VARCHAR2,
                p_org_name                      IN VARCHAR2,
                p_short_name                    IN VARCHAR2,
                p_org_type                      IN VARCHAR2,
                p_contact                       IN VARCHAR2,
                p_org_status                    IN VARCHAR2,
                p_role                          IN VARCHAR2,
                p_addr1                         IN VARCHAR2,
                p_addr2                         IN VARCHAR2,
                p_city                          IN VARCHAR2,
                p_state                         IN VARCHAR2,
                p_zip                           IN VARCHAR2,
                p_country_code                  IN VARCHAR2,
                p_phone                         IN VARCHAR2,
                p_fax                           IN VARCHAR2,
                p_email                         IN VARCHAR2,
                p_party_links                   IN VARCHAR2,
                p_party_query_id                IN VARCHAR2,
                p_ucc_doc_unique_id             IN VARCHAR2,
                p_xmlg_internal_control_no      IN NUMBER,
                p_collab_dtl_id                 IN VARCHAR2,
                x_return_status                 OUT NOCOPY  VARCHAR2,
                x_msg_data                      OUT NOCOPY  VARCHAR2 )
        IS

                l_org_status_db                 VARCHAR2(10);
                l_error_code                    VARCHAR2(50);
                l_event_name                    VARCHAR2(100);
                l_event_key                     VARCHAR2(255);
                l_error_msg                     VARCHAR2(1000);
                l_dtl_msg                       VARCHAR2(2000);
                l_event_parameters              wf_parameter_list_t;

        BEGIN
                l_event_name            := 'oracle.apps.cln.ch.collaboration.addmessage';
                l_event_parameters      := wf_parameter_list_t();

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Entering m4u_party_query.process_resp_org_data' ,1);
                END IF;

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('---- m4u_party_query.process_resp_org_data -- '                 ,1);
                        cln_debug_pub.Add('p_org_gln                    - '||p_org_gln                     ,1);
                        cln_debug_pub.Add('p_org_name                   - '||p_org_name                    ,1);
                        cln_debug_pub.Add('p_short_name                 - '||p_short_name                  ,1);
                        cln_debug_pub.Add('p_org_type                   - '||p_org_type                    ,1);
                        cln_debug_pub.Add('p_contact                    - '||p_contact                     ,1);
                        cln_debug_pub.Add('p_org_status                 - '||p_org_status                  ,1);
                        cln_debug_pub.Add('p_role                       - '||p_role                        ,1);
                        cln_debug_pub.Add('p_addr1                      - '||p_addr1                       ,1);
                        cln_debug_pub.Add('p_addr2                      - '||p_addr2                       ,1);
                        cln_debug_pub.Add('p_city                       - '||p_city                        ,1);
                        cln_debug_pub.Add('p_state                      - '||p_state                       ,1);
                        cln_debug_pub.Add('p_zip                        - '||p_zip                         ,1);
                        cln_debug_pub.Add('p_country_code               - '||p_country_code                ,1);
                        cln_debug_pub.Add('p_phone                      - '||p_phone                       ,1);
                        cln_debug_pub.Add('p_fax                        - '||p_fax                         ,1);
                        cln_debug_pub.Add('p_email                      - '||p_email                       ,1);
                        cln_debug_pub.Add('p_party_links                - '||p_party_links                 ,1);
                        cln_debug_pub.Add('p_party_query_id             - '||p_party_query_id              ,1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          - '||p_ucc_doc_unique_id           ,1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   - '||p_xmlg_internal_control_no    ,1);
                        cln_debug_pub.Add('p_collab_dtl_id              - '||p_collab_dtl_id);
                        cln_debug_pub.Add('-------------------------------------------'                    ,1);
                END IF;

                -- Check for the collaboration ID based on the collaboration detail ID and get the
                -- attribute 14 value. If the value is set and is AC, that means only active organizations
                -- are desired in the display.

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('Checking for the value of attribute14 for org status' ,1);
                END IF;

                SELECT attribute14
                INTO l_org_status_db
                FROM CLN_COLL_HIST_HDR
                WHERE collaboration_id = ( SELECT collaboration_id
                                           FROM CLN_COLL_HIST_DTL
                                           WHERE collaboration_dtl_id = p_collab_dtl_id);

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Organization Status required '||l_org_status_db ,1);
                END IF;

                -- if the database value for status is AC and the incoming
                -- payload carries organization details with status as IN, return
                IF (l_org_status_db IS NOT NULL) AND (l_org_status_db <> p_org_status) THEN
                        x_return_status         := FND_API.G_RET_STS_SUCCESS;
                        x_msg_data              := 'SUCCESS';
                        RETURN;
                END IF;

                /* NO PROCESSING/UPDATE DEFINED         */

                --create unique key for each event using CLN sequence
                SELECT cln_collaboration_msg_id_s.nextval INTO l_event_key FROM dual ;

                l_dtl_msg := 'GLN - '  || p_org_gln || ', Name - ' || p_org_name || ', Type - ' || p_org_type;
                l_dtl_msg := l_dtl_msg || ', Contact - ' || p_contact || ' , Status  - ' || p_org_status || ', Role - ' || p_role;
                l_dtl_msg := l_dtl_msg || ', Address - ' || p_addr1 || ', ' || p_addr2 || ', '|| p_city || ', ' || p_state || ', ' || p_zip || ', ' || p_country_code;
                l_dtl_msg := l_dtl_msg || ', Phone - ' || p_phone || ', Fax - ' || p_fax ;

                --dbms_output.put_line(l_dtl_msg);

                -- set event parameters for CLN Add Message Event
                wf_event.AddParameterToList(
                                        p_name          => 'COLLABORATION_DETAIL_ID',
                                        p_value         => p_collab_dtl_id,
                                        p_parameterlist => l_event_parameters   );

                wf_event.AddParameterToList(
                                        p_name          => 'DETAIL_MESSAGE',
                                        p_value         => l_dtl_msg,
                                        p_parameterlist => l_event_parameters   );


                wf_event.AddParameterToList(
                                        p_name          => 'REFERENCE_ID1',
                                        p_value         => 'GLN - ' || p_org_gln,
                                        p_parameterlist => l_event_parameters   );

                -- add CLN event to add error messages as to collaboration history
                wf_event.raise(
                                        p_event_name            => l_event_name,
                                        p_event_key             => l_event_key,
                                        p_parameters            => l_event_parameters
                                );

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Raised - ' || l_event_name || ', key - ' || l_event_key,2);
                END IF;

                x_return_status         := FND_API.G_RET_STS_SUCCESS;
                x_msg_data              := 'SUCCESS';

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_party_query.process_resp_org_data - Normal' ,1);
                END IF;

        EXCEPTION
             WHEN OTHERS THEN
                l_error_code    := SQLCODE;
                l_error_msg     := SQLERRM;
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);

                x_msg_data           := ' ' || FND_MESSAGE.GET ||  ' , ';

                IF (l_debug_level <= 5) THEN
                        cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_party_query.process_resp_org_data - exception',2);
                        cln_debug_pub.add('=========================================================',2);
                END IF;

        END process_resp_org_data;


        -- Name
        --      process_party_links
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry_in
        --      This procedure recieves the organization-links info parsed from
        --      the UCCnet party-query command response
        -- Arguments
        --      p_org_gln                       - Party info received in response
        --      p_linked_gln                    - GLN of Org linked to p_org_gln
        --      p_party_query_id                - Id of party command
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      This is only a Dummy API, can be extended based on future requirements
        PROCEDURE process_party_links(
                p_org_gln                       IN VARCHAR2,
                p_linked_gln                    IN VARCHAR2,
                p_party_query_id                IN VARCHAR2,
                p_collab_id                     IN VARCHAR2,
                p_ucc_doc_unique_id             IN VARCHAR2,
                p_xmlg_internal_control_no      IN NUMBER,
                x_collab_detail_id              OUT NOCOPY VARCHAR2,
                x_return_status                 OUT NOCOPY VARCHAR2,
                x_msg_data                      OUT NOCOPY VARCHAR2 )
        IS
                l_error_code                    VARCHAR2(50);
                l_error_msg                     VARCHAR2(1000);
        BEGIN

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Entering m4u_party_query.process_party_links' ,1);
                END IF;



                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('---- m4u_party_query.proces_party_links-- '                     ,1);
                        cln_debug_pub.Add('p_org_gln                    - '||p_org_gln                     ,1);
                        cln_debug_pub.Add('p_linked_gln                 - '||p_linked_gln                  ,1);
                        cln_debug_pub.Add('p_party_query_id             - '||p_party_query_id              ,1);
                        cln_debug_pub.Add('p_collab_id                  - '||p_collab_id                   ,1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          - '||p_ucc_doc_unique_id           ,1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   - '||p_xmlg_internal_control_no    ,1);
                        cln_debug_pub.Add('-------------------------------------------'                    ,1);
                END IF;

                /* NO PROCESSING/UPDATE DEFINED         */
                /* IN-FUTURE THIS CAN BE EXTENDED       */

                x_return_status         := FND_API.G_RET_STS_SUCCESS;
                x_msg_data              := 'SUCCESS';

                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting m4u_party_query.process_party_links - Normal' ,1);
                END IF;

        EXCEPTION
             WHEN OTHERS THEN
                l_error_code    := SQLCODE;
                l_error_msg     := SQLERRM;
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);

                x_msg_data           := ' ' || FND_MESSAGE.GET ||  ' , ';


                IF (l_debug_level <= 5) THEN
                        cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_party_query.process_party_links - exception',2);
                        cln_debug_pub.add('=======================================================',2);
                END IF;

        END process_party_links;



        -- Name
        --      process_resp_doc
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry_in
        --      This procedure updateds the UCCnet Party Query collaboration
        --      with details of the response document, and failre messages in case of error.
        -- Arguments
        --      p_party_query_id                - Id of party query command
        --      p_query_success_flag            - Flag - if query command was sucess/failure
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      None.
        PROCEDURE process_resp_doc(
                p_party_query_id                IN      VARCHAR2,
                p_query_success_flag            IN      VARCHAR2,
                p_ucc_doc_unique_id             IN      VARCHAR2,
                p_xmlg_internal_control_no      IN      NUMBER,
                p_doc_status                    IN      VARCHAR2,
                x_collab_detail_id              OUT     NOCOPY  VARCHAR2,
                x_return_status                 OUT     NOCOPY  VARCHAR2,
                x_msg_data                      OUT     NOCOPY  VARCHAR2 )
        IS
                l_error_code            VARCHAR2(50);
                l_error_msg             VARCHAR2(1000);
                l_disposition           VARCHAR2(50);
                l_coll_status           VARCHAR2(50);
                l_fnd_msg               VARCHAR2(1000);
                l_doc_status            VARCHAR2(50);
        BEGIN

                -- Parameters received
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('---- m4u_party_query.proces_resp_doc ---- '            ,1);
                        cln_debug_pub.Add('p_party_query_id             - '||p_party_query_id     ,1);
                        cln_debug_pub.Add('p_query_success_flag         - '||p_query_success_flag ,1);
                        cln_debug_pub.Add('p_ucc_doc_unique_id          - '||p_ucc_doc_unique_id  ,1);
                        cln_debug_pub.Add('p_xmlg_internal_control_no   - '||p_xmlg_internal_control_no    ,1);
                        cln_debug_pub.Add('p_doc_status                 - '||p_doc_status         ,1);
                        cln_debug_pub.Add('-------------------------------------------'           ,1);
                END IF;


                -- set CLN Disposition, CLN Coll Status, CLN Doc status, CLN Message Text
                IF (UPPER(p_query_success_flag)   = 'TRUE') THEN
                        l_disposition   := 'ACCEPTED' ;
                        l_coll_status   := 'COMPLETED';
                        l_doc_status    := 'SUCCESS';
                        l_fnd_msg       := 'M4U_PARTYQRY_SUCCESS';

                        IF (p_doc_status IS NULL)THEN
                                l_fnd_msg       := 'M4U_PARTYQRY_WRONG_CHOICE';
                        END IF;
                ELSE
                        l_disposition   := 'FAILED' ;
                        l_coll_status   := 'ERROR';
                        l_doc_status    := 'ERROR';
                        l_fnd_msg       := 'M4U_PARTYQRY_FAILURE';
                END IF;



                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Update collaboration parameters set -',1);
                        cln_debug_pub.Add('Disposition          - '|| l_disposition ,1);
                        cln_debug_pub.Add('Collaboration Status - '|| l_coll_status ,1);
                        cln_debug_pub.Add('Document Status      - '|| l_doc_status  ,1);
                        cln_debug_pub.Add('FND Message          - '|| l_fnd_msg     ,1);
                        cln_debug_pub.Add('---------------------------------------' ,1);
                END IF;



                cln_ch_collaboration_pkg.update_collaboration(
                        x_return_status                  => x_return_status,
                        x_msg_data                       => x_msg_data,
                        p_coll_id                        => p_party_query_id,
                        p_msg_text                       => l_fnd_msg,
                        p_xmlg_msg_id                    => NULL,
                        p_xmlg_transaction_type          => 'M4U',
                        p_xmlg_transaction_subtype       => 'RESP_PARTY',
                        p_xmlg_int_transaction_type      => 'M4U',
                        p_xmlg_int_transaction_subtype   => 'RESP_PARTY',
                        p_doc_dir                        => 'IN',
                        p_doc_type                       => 'M4U_RESP_PARTY',
                        p_disposition                    => l_disposition,
                        p_doc_status                     => l_doc_status,
                        p_coll_status                    => l_coll_status,
                        p_xmlg_document_id               => NULL,
                        p_xmlg_internal_control_number   => p_xmlg_internal_control_no,
                        p_tr_partner_type                => m4u_ucc_utils.c_party_type,
                        p_tr_partner_id                  => m4u_ucc_utils.g_party_id,
                        p_tr_partner_site                => m4u_ucc_utils.g_party_site_id,
                        p_attribute8                     => p_ucc_doc_unique_id,
                        p_attribute9                     => null,
                        p_dattribute1                    => sysdate,
                        p_rosettanet_check_required      => false,
                        x_dtl_coll_id                    => x_collab_detail_id  );


                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-- Update Collab API returns Values  -'           ,1);
                        cln_debug_pub.Add('Collab Detail Id         - '|| x_collab_detail_id ,1);
                        cln_debug_pub.Add('CLN API Return Status    - '|| x_return_status    ,1);
                        cln_debug_pub.Add('CLN return msg data      - '|| x_msg_data         ,1);
                END IF;


                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('Exiting - m4u_party_query.process_resp_doc Normal',2);
                END IF;


        EXCEPTION
             WHEN OTHERS THEN
                l_error_code    := SQLCODE;
                l_error_msg     := SQLERRM;
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);

                x_msg_data           := ' ' || FND_MESSAGE.GET ||  ' , ';


                IF (l_debug_level <= 5) THEN
                        cln_debug_pub.add(l_error_code || ':' || l_error_msg, 4);
                END IF;

                IF (l_debug_level <= 2) THEN
                        cln_debug_pub.add('Exiting m4u_party_query.process_resp_doc - exception',2);
                        cln_debug_pub.add('====================================================',2);
                END IF;

        END process_resp_doc;

        BEGIN
                l_debug_level           := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
END m4u_party_query;

/
