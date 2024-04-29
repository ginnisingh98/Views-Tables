--------------------------------------------------------
--  DDL for Package Body M4U_SETUP_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_SETUP_PACKAGE" AS
/* $Header: M4USETPB.pls 120.0 2005/08/01 03:50:08 rkrishan noship $ */

   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

        -- Name
        --      add_or_update_tp_detail
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup detail
        --      for a single transaction based on the params
        --      If detail record is present it updates else inserts
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      <paramlist>                     => corresponds to the ecx_tp_api, nothing to talk abt
        -- Notes
        --      none
        PROCEDURE add_or_update_tp_detail(
                                                x_errbuf                OUT NOCOPY VARCHAR2,
                                                x_retcode               OUT NOCOPY VARCHAR2,
                                                p_txn_subtype           VARCHAR2,
                                                p_map                   VARCHAR2,
                                                p_direction             VARCHAR2,
                                                p_tp_hdr_id             NUMBER
                                         )
        IS
                l_tp_dtl_id                     NUMBER;
                l_ext_process_id                NUMBER;
                l_routing_id                    NUMBER;
                l_doc_conf                      NUMBER;
                l_hub_user_id                   NUMBER;
                l_tp_hdr_id                     NUMBER;


                l_standard_code                 VARCHAR2(10);
                l_party_type                    VARCHAR2(10);
                l_direction                     VARCHAR2(10);
                l_retcode                       VARCHAR2(20);


                l_ext_type                      VARCHAR2(30);
                l_ext_subtype                   VARCHAR2(30);
                l_transaction_type              VARCHAR2(30);
                l_transaction_subtype           VARCHAR2(30);
                l_conn_type                     VARCHAR2(30);
                l_protocol                      VARCHAR2(30);
                l_protocol_addr                 VARCHAR2(30);
                l_user                          VARCHAR2(30);
                l_passwd                        VARCHAR2(30);
                l_src_loc                       VARCHAR2(30);
                l_ext_loc                       VARCHAR2(30);
                l_map                           VARCHAR2(60);
                l_msg_data                      VARCHAR2(255);
                l_retmesg                       VARCHAR2(500);


                l_record_found                  BOOLEAN;



        BEGIN

                IF (l_Debug_Level <= 2) THEN
                      cln_debug_pub.Add('----- ENTERING add_or_update_tp_detail API ------', 2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'    );
                        cln_debug_pub.Add(''    );
                        cln_debug_pub.Add('Parameters :'   );
                        cln_debug_pub.Add('p_txn_subtype  ' || p_txn_subtype  );
                        cln_debug_pub.Add('p_direction    ' || p_direction    );
                        cln_debug_pub.Add('p_map          ' || p_map          );
                        cln_debug_pub.Add('p_tp_hdr_id    ' || p_tp_hdr_id    );
                        cln_debug_pub.Add('------------------------------'    );
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('- Defaulting the local variables - ', 1);
                END IF;

                l_ext_type                      :=      'M4U';
                l_standard_code                 :=      'UCCNET';
                l_transaction_type              :=      'M4U';
                l_party_type                    :=      'I';
                l_doc_conf                      :=      '2';
                l_src_loc                       :=      'UCCNET_HUB';
                l_ext_subtype                   :=      p_txn_subtype;
                l_transaction_subtype           :=      p_txn_subtype;
                l_tp_hdr_id                     :=      p_tp_hdr_id;
                l_map                           :=      p_map;
                l_direction                     :=      p_direction;


                IF (l_direction = 'OUT') THEN
                        l_conn_type             :=      'DIRECT';
                        l_protocol              :=      'HTTP';
                        l_protocol_addr         :=      'http://none';
                        l_user                  :=      'operations';
                        l_passwd                :=      'welcome';
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add('-----------------------------------'    );
                        cln_debug_pub.Add('l_ext_type               :=M4U',1);
                        cln_debug_pub.Add('l_standard_code          :=UCCNET',1);
                        cln_debug_pub.Add('l_transaction_type       :=M4U',1);
                        cln_debug_pub.Add('l_party_type             :=I',1);
                        cln_debug_pub.Add('l_doc_conf               :=2',1);
                        cln_debug_pub.Add('l_src_loc                :=UCCNET_HUB',1);
                        cln_debug_pub.Add('l_hub_user_id            :=null',1);
                        cln_debug_pub.Add('l_routing_id             :=null',1);
                        cln_debug_pub.Add('l_ext_loc                :=null',1);
                        cln_debug_pub.Add('l_ext_subtype            :='||l_ext_subtype,1);
                        cln_debug_pub.Add('l_transaction_subtype    :='||l_ext_subtype,1);
                        cln_debug_pub.Add('l_tp_header_id           :='||l_tp_hdr_id,1);
                        cln_debug_pub.Add('l_map                    :='||l_map,1);
                        cln_debug_pub.Add('l_direction              :='||l_direction,1);
                        cln_debug_pub.Add('------------------------------'    );
                END IF;


                -- query ecx_tp_detail_id to get ecx_tp_detail_id for given location code
                -- if record does not exists create a new detail record
                -- else update the detail record
                BEGIN
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('- Get TP Detail ID - ', 1);
                        END IF;

                        SELECT tp_detail_id
                        INTO   l_tp_dtl_id
                        FROM
                                ecx_tp_details    tpd,
                                ecx_tp_headers    tph,
                                ecx_ext_processes extp,
                                ecx_transactions  txn,
                                ecx_standards     svl
                        WHERE   1=1
                                AND tph.tp_header_id            = tpd.tp_header_id
                                AND tpd.ext_process_id          = extp.ext_process_id
                                AND extp.transaction_id         = txn.transaction_id
                                AND extp.standard_id            = svl.standard_id
                                AND svl.standard_code           = l_standard_code
                                AND extp.ext_type               = l_ext_type
                                AND extp.ext_subtype            = l_ext_subtype
                                AND extp.direction              = l_direction
                                AND txn.transaction_type        = l_transaction_type
                                AND txn.transaction_subtype     = l_transaction_subtype
                                AND tph.tp_header_id            = l_tp_hdr_id;

                        l_record_found   := TRUE;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Got ECX TP Detail ID Value ----', 1);
                              cln_debug_pub.Add('TP Detail Id        -'||l_tp_dtl_id, 1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                               --FND_MESSAGE.SET_NAME('CLN','M4U_TP_DTL_SETUP_NEW');
                               --l_msg_data       := FND_MESSAGE.GET;
                               l_record_found   := FALSE;

                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- TP Detail Setup for M4U does not exist --',1);
                               END IF;

                        WHEN OTHERS THEN
                               FND_MESSAGE.SET_NAME('CLN','M4U_TP_DTL_SETUP_ISSUE');
                               FND_MESSAGE.SET_TOKEN('PARAM1',l_transaction_type);
                               FND_MESSAGE.SET_TOKEN('PARAM2',l_transaction_subtype);
                               FND_MESSAGE.SET_TOKEN('PARAM3',l_direction);
                               FND_MESSAGE.SET_TOKEN('PARAM4',l_standard_code);
                               l_msg_data       := FND_MESSAGE.GET;
                               RAISE FND_API.G_EXC_ERROR;
                END;

                BEGIN
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('- Get Ext Process ID - ', 1);
                        END IF;

                        SELECT  extp.ext_process_id
                        INTO    l_ext_process_id
                        FROM    ecx_ext_processes extp,
                                ecx_transactions  txn,
                                ecx_standards     svl
                        WHERE   1=1
                                AND extp.transaction_id         = txn.transaction_id
                                AND extp.standard_id            = svl.standard_id
                                AND svl.standard_code           = l_standard_code
                                AND extp.ext_type               = l_ext_type
                                AND extp.ext_subtype            = l_ext_subtype
                                AND extp.direction              = l_direction
                                AND txn.party_type              = l_party_type
                                AND txn.transaction_type        = l_transaction_type
                                AND txn.transaction_subtype     = l_transaction_subtype;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Got Ext Process ID Value ----', 1);
                              cln_debug_pub.Add('Ext Process Id        -'||l_ext_process_id, 1);
                        END IF;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- Ext Process ID does not exist --',1);
                               END IF;

                        WHEN TOO_MANY_ROWS THEN
                               FND_MESSAGE.SET_NAME('CLN','M4U_EXT_PROCESS_SETUP_EXISTS');
                               FND_MESSAGE.SET_TOKEN('PARAM1',l_transaction_type);
                               FND_MESSAGE.SET_TOKEN('PARAM2',l_transaction_subtype);
                               FND_MESSAGE.SET_TOKEN('PARAM3',l_direction);
                               FND_MESSAGE.SET_TOKEN('PARAM4',l_standard_code);
                               l_msg_data       := FND_MESSAGE.GET;

                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- Two Many Ext Process ID for M4U exists --',1);
                               END IF;
                               RAISE FND_API.G_EXC_ERROR;

                        WHEN OTHERS THEN
                               l_msg_data       := SQLCODE ||'-'||SQLERRM;
                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('ERROR -'||l_msg_data,1);
                                       cln_debug_pub.Add('-- Error in Finding the External Process ID --',1);
                               END IF;
                               RAISE FND_API.G_EXC_ERROR;
                END;


                IF NOT l_record_found THEN
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Setup ECX TP Detail Values in DB       ----', 1);
                              cln_debug_pub.Add('---- Call ecx_tp_api.create_tp_detail ----', 1);
                        END IF;

                        ecx_tp_api.create_tp_detail(
                                x_return_status                 =>  l_retcode,
                                x_msg                           =>  l_retmesg,
                                x_tp_detail_id                  =>  l_tp_dtl_id,
                                p_tp_header_id                  =>  l_tp_hdr_id,
                                p_ext_process_id                =>  l_ext_process_id,
                                p_map_code                      =>  l_map,
                                p_connection_type               =>  l_conn_type,
                                p_hub_user_id                   =>  l_hub_user_id,
                                p_protocol_type                 =>  l_protocol,
                                p_protocol_address              =>  l_protocol_addr,
                                p_username                      =>  l_user,
                                p_password                      =>  l_passwd,
                                p_routing_id                    =>  l_routing_id,
                                p_source_tp_location_code       =>  l_src_loc,
                                p_external_tp_location_code     =>  l_ext_loc,
                                p_confirmation                  =>  l_doc_conf
                                );

                        IF l_retcode <> 0 THEN
                             FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_API_FAILED');
                             FND_MESSAGE.SET_TOKEN('PARAM1','create');
                             l_msg_data       := FND_MESSAGE.GET;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- ecx_tp_api.update_trading_partner returns Normal----', 1);
                        END IF;
                ELSE

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Setup ECX TP Detail Values in DB       ----', 1);
                              cln_debug_pub.Add('---- Call ecx_tp_api.update_tp_detail ----', 1);
                        END IF;
                        ecx_tp_api.update_tp_detail(
                                        x_return_status                 => l_retcode,
                                        x_msg                           => l_retmesg,
                                        p_tp_detail_id                  => l_tp_dtl_id,
                                        p_map_code                      => l_map,
                                        p_ext_process_id                => l_ext_process_id,
                                        p_connection_type               => l_conn_type,
                                        p_hub_user_id                   => l_hub_user_id,
                                        p_protocol_type                 => l_protocol,
                                        p_protocol_address              => l_protocol_addr,
                                        p_username                      => l_user,
                                        p_password                      => l_passwd,
                                        p_routing_id                    => l_routing_id,
                                        p_source_tp_location_code       => l_src_loc,
                                        p_external_tp_location_code     => l_ext_loc,
                                        p_confirmation                  => l_doc_conf,
                                        p_passupd_flag                  => 'Y'
                                      );

                        IF l_retcode <> 0 THEN
                             FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_API_FAILED');
                             FND_MESSAGE.SET_TOKEN('PARAM1','update');
                             l_msg_data       := FND_MESSAGE.GET;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- ecx_tp_api.update_trading_partner returns Normal----', 1);
                        END IF;
                END IF;

                IF l_retcode = 0 THEN
                        x_retcode  := FND_API.G_RET_STS_SUCCESS;
                        x_errbuf   := 'Successful';
                END IF;

                cln_debug_pub.Add('Exiting add_or_update_tp_detail normally');

        -- Exception Handling
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        x_retcode       :=  2;
                        x_errbuf        :=  l_msg_data;

                        IF (l_Debug_Level <= 2) THEN
                              cln_debug_pub.Add('ERROR : '||x_errbuf, 2);
                              cln_debug_pub.Add('==========ERROR :EXTING add_or_update_tp_detail API ===========', 2);
                        END IF;

                WHEN OTHERS THEN
                        x_retcode :=  2;
                        -- Setup Failed
                        x_errbuf        := SQLCODE||' - '||SQLERRM;

                        IF (l_Debug_Level <= 2) THEN
                              cln_debug_pub.Add('ERROR : '||x_errbuf, 2);
                              cln_debug_pub.Add('==========ERROR :EXTING add_or_update_tp_detail API ===========', 2);
                        END IF;
        END;


        -- Name
        --      SETUP
        -- Purpose
        --      This procedure is called from a concurrent program(can be called from anywhere actually).
        --      This procedure does the setup required for m4u
        --              i)      Setup default TP location in HR_LOCATIONS
        --              ii)     Setup XMLGateway trading partner definition
        -- Arguments
        --      x_err_buf                       => API out result param for concurrent program calls
        --      x_retcode                       => API out result param for concurrent program calls
        --      p_location_code                 => Should have value 'OIPC Default TP'
        --      p_description                   => Some description
        --      p_addr_line_1                   => Some address line 1
        --      p_region_1                      => Some region 1 (province)
        --      p_region_2                      => Some region 2 (State)
        --      p_town_or_city                  => Some city
        --      p_postal_code                   => Some postal code
        -- Notes
        --      All the input arguments are used in the call to setup_hr_locations
        --      The concurrent program will be failed in case of any error
        --      All arguments are moved into the code
        PROCEDURE SETUP(
                           x_errbuf             OUT NOCOPY VARCHAR2,
                           x_retcode            OUT NOCOPY NUMBER

                       )
        IS
                l_style                         VARCHAR2(7);
                l_retcode                       VARCHAR2(20);
                l_location_code                 VARCHAR2(60);
                l_country                       VARCHAR2(60);
                l_description                   VARCHAR2(240);
                l_msg_data                      VARCHAR2(240);
                l_addr_line_1                   VARCHAR2(240);
                l_retmesg                       VARCHAR2(500);

                l_location_id                   NUMBER;
                l_obj_ver_num                   NUMBER;
                l_tp_hdr_id                     NUMBER;

                l_record_found                  BOOLEAN;

        BEGIN

                IF (l_Debug_Level <= 2) THEN
                      cln_debug_pub.Add('==========ENTERING SETUP API ===========', 2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Defaulting the HR Location Values ----', 1);
                END IF;

                l_location_code := 'UCCnet';
                l_description   := 'UCCnet Data hub';
                l_addr_line_1   := 'Princeton';
                l_style         := 'US_GLB';
                l_country       := 'US';

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Location code      -'||l_location_code, 1);
                      cln_debug_pub.Add('Description        -'||l_description, 1);
                      cln_debug_pub.Add('Address Line 1     -'||l_addr_line_1, 1);
                      cln_debug_pub.Add('Address Style      -'||l_style, 1);
                      cln_debug_pub.Add('Country            -'||l_country, 1);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('+++++++++ Check HR Location Values in DB +++++++++', 1);
                END IF;

                -- Setup HR Locations
                -- Check if record exists. Create Locations if it does not else Update Location value
                BEGIN
                        SELECT location_id, object_version_number
                        INTO   l_location_id, l_obj_ver_num
                        FROM   hr_locations_all
                        WHERE location_code = l_location_code;

                        l_record_found   := TRUE;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Got HR Location Values ----', 1);
                              cln_debug_pub.Add('Location Id        -'||l_location_id, 1);
                              cln_debug_pub.Add('Object Version No  -'||l_obj_ver_num, 1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                               l_record_found   := FALSE;

                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- HR Setup for M4U does not exist --',1);
                               END IF;

                        WHEN TOO_MANY_ROWS THEN
                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- HR Setup for M4U already exists with two many rows--',1);
                                       cln_debug_pub.Add('-- Updating one of the records arbitrarily --',1);
                               END IF;

                               SELECT location_id, object_version_number
                               INTO   l_location_id, l_obj_ver_num
                               FROM   hr_locations
                               WHERE location_code = l_location_code
                               AND ROWNUM < 2;

                               l_record_found   := TRUE;

                               IF (l_Debug_Level <= 1) THEN
                                     cln_debug_pub.Add('---- Got HR Location Values limiting rownum ----', 1);
                                     cln_debug_pub.Add('Location Id        -'||l_location_id, 1);
                                     cln_debug_pub.Add('Object Version No  -'||l_obj_ver_num, 1);
                               END IF;

                        WHEN OTHERS THEN
                               FND_MESSAGE.SET_NAME('CLN','M4U_HR_API_ISSUE');
                               l_msg_data       := FND_MESSAGE.GET;
                               RAISE FND_API.G_EXC_ERROR;
                END;

                IF NOT l_record_found THEN
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Setup HR Location Values in DB       ----', 1);
                              cln_debug_pub.Add('---- Call HR_LOCATION_API.create_location ----', 1);
                        END IF;

                        FND_MESSAGE.SET_NAME('CLN','M4U_HR_API_FAILED');
                        FND_MESSAGE.SET_TOKEN('PARAM','Create');
                        l_msg_data       := FND_MESSAGE.GET;

                        HR_LOCATION_API.create_location(
                                     p_effective_date          => sysdate,
                                     p_language_code           => userenv('LANG'),
                                     p_location_code           => l_location_code,
                                     p_description             => l_description,
                                     p_address_line_1          => l_addr_line_1,
                                     p_country                 => l_country,
                                     p_style                   => l_style,
                                     p_location_id             => l_location_id,
                                     p_object_version_number   => l_obj_ver_num );

                        l_msg_data := 'HR Location created with success';

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- HR_LOCATION_API.create_location returns Normal----', 1);
                              cln_debug_pub.Add('Location Id        -'||l_location_id, 1);
                              cln_debug_pub.Add('Object Version No  -'||l_obj_ver_num, 1);
                        END IF;
                ELSE
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Update HR Location Values in DB       ----', 1);
                              cln_debug_pub.Add('---- Call HR_LOCATION_API.update_location ----', 1);
                        END IF;

                        FND_MESSAGE.SET_NAME('CLN','M4U_HR_API_FAILED');
                        FND_MESSAGE.SET_TOKEN('PARAM','Update');
                        l_msg_data       := FND_MESSAGE.GET;

                        HR_LOCATION_API.update_location(
                                     p_effective_date          => sysdate,
                                     p_language_code           => userenv('LANG'),
                                     p_location_code           => l_location_code,
                                     p_description             => l_description,
                                     p_address_line_1          => l_addr_line_1,
                                     p_country                 => l_country,
                                     p_style                   => l_style,
                                     p_location_id             => l_location_id,
                                     p_object_version_number   => l_obj_ver_num );

                        l_msg_data := 'HR Location updated with success';

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- HR_LOCATION_API.update_location returns Normal----', 1);
                              cln_debug_pub.Add('Location Id        -'||l_location_id, 1);
                              cln_debug_pub.Add('Object Version No  -'||l_obj_ver_num, 1);
                        END IF;
                END IF;


                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('+++++++++ Setup ECX TP Header Values  +++++++++', 1);
                END IF;

                -- reset the value for next phase
                l_record_found   := FALSE;

                -- Setup ECX TP header
                -- Check if record exists. Create TP Header if it does not else Update value
                BEGIN

                        SELECT tp_header_id
                        INTO l_tp_hdr_id
                        FROM   ecx_tp_headers
                        WHERE       party_type          = 'I'
                                AND party_id            = l_location_id
                                AND party_site_id       = l_location_id;

                        l_record_found   := TRUE;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Got ECX TP Header Values ----', 1);
                              cln_debug_pub.Add('TP Header Id        -'||l_tp_hdr_id, 1);
                        END IF;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                               l_record_found   := FALSE;

                               IF (l_Debug_Level <= 1) THEN
                                       cln_debug_pub.Add('-- TP Header Setup for M4U does not exist --',1);
                               END IF;

                        WHEN OTHERS THEN
                               FND_MESSAGE.SET_NAME('CLN','M4U_TP_HDR_SETUP_ISSUE');
                               l_msg_data       := FND_MESSAGE.GET;
                               RAISE FND_API.G_EXC_ERROR;
                END;

                IF NOT l_record_found THEN
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Setup ECX TP Header Values in DB       ----', 1);
                              cln_debug_pub.Add('---- Call ecx_tp_api.create_trading_partner ----', 1);
                        END IF;

                        ecx_tp_api.create_trading_partner(
                                                x_return_status         => l_retcode,
                                                x_msg                   => l_retmesg,
                                                x_tp_header_id          => l_tp_hdr_id,
                                                p_party_type            => 'I',
                                                p_party_id              => l_location_id,
                                                p_party_site_id         => l_location_id,
                                                p_company_admin_email   => 'purna.pidaparti@oracle.com'
                                                );

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Return Values From API ----', 1);
                              cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                              cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                        END IF;

                        IF l_retcode <> 0 THEN
                             FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPHDR_API_FAILED');
                             FND_MESSAGE.SET_TOKEN('PARAM','Create');
                             l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- ecx_tp_api.create_trading_partner returns Normal----', 1);
                        END IF;
                ELSE
                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Update ECX TP Header Values in DB      ----', 1);
                              cln_debug_pub.Add('---- Call ecx_tp_api.update_trading_partner ----', 1);
                        END IF;

                        ecx_tp_api.update_trading_partner(
                                                x_return_status         => l_retcode,
                                                x_msg                   => l_retmesg,
                                                p_tp_header_id          => l_tp_hdr_id,
                                                p_company_admin_email   => 'purna.pidaparti@oracle.com'
                                                );

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- Return Values From API ----', 1);
                              cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                              cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                        END IF;

                        IF l_retcode <> 0 THEN
                             FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPHDR_API_FAILED');
                             FND_MESSAGE.SET_TOKEN('PARAM','update');
                             l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF (l_Debug_Level <= 1) THEN
                              cln_debug_pub.Add('---- ecx_tp_api.update_trading_partner returns Normal----', 1);
                        END IF;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('+++++++++  Setup ECX TP Details Values ++++++++', 1);
                END IF;

                -- setup ECX TP details
                --1
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'CIN','m4u_230_cin_out','OUT',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --2
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'GBREGQRY','m4u_230_gbreg_qry_out','OUT',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


                --3
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'PARTYQRY','m4u_230_party_qry_out','OUT',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;

                END IF;

                --4
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'RCIR','m4u_230_rcir_out','OUT',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --5
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'WLQ','m4u_230_wlq_out','OUT',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --6
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_ACK','m4u_230_resp_ack_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --7
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_BATCH','m4u_230_resp_batch_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --8
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_CIC','m4u_230_resp_cic_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --9
                M4U_SETUP_PACKAGE.add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_GTIN','m4u_230_resp_gbregqry_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --10
                add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_PARTY','m4u_230_resp_partyqry_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                --11
                add_or_update_tp_detail(l_retmesg,l_retcode,'RESP_RFCIN','m4u_230_resp_rfcin_in','IN',l_tp_hdr_id);
                IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('---- Return Values From API ----', 1);
                      cln_debug_pub.Add('Return Message   - '||l_retmesg, 1);
                      cln_debug_pub.Add('Return Code      - '||l_retcode, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_ECXTPDTL_FAILURE');
                        l_msg_data       := FND_MESSAGE.GET||' : '||l_retmesg;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                x_retcode  := 0;
                x_errbuf   := 'SUCCESS';


                IF (l_Debug_Level <= 2) THEN
                      cln_debug_pub.Add('==========EXTING SETUP API :NORMALLY===========', 2);
                END IF;

        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        x_retcode       :=  2;
                        x_errbuf        :=  l_msg_data;

                        IF (l_Debug_Level <= 2) THEN
                              cln_debug_pub.Add('ERROR : '||x_errbuf, 2);
                              cln_debug_pub.Add('==========ERROR :EXTING SETUP API ===========', 2);
                        END IF;

                WHEN OTHERS THEN
                        x_retcode :=  2;
                        FND_MESSAGE.SET_NAME('CLN','M4U_SETUP_FAILURE');
                        -- Setup Failed
                        x_errbuf        := FND_MESSAGE.GET || ' - ' ||SQLCODE||' - '||SQLERRM;

                        IF (l_Debug_Level <= 2) THEN
                              cln_debug_pub.Add('ERROR : '||x_errbuf, 2);
                              cln_debug_pub.Add('==========ERROR :EXTING SETUP API ===========', 2);
                        END IF;
        END SETUP;

END M4U_SETUP_PACKAGE;

/
