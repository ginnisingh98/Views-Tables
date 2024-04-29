--------------------------------------------------------
--  DDL for Package Body ITG_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SETUP" AS
/* $Header: itghlocb.pls 120.3 2006/07/28 12:34:37 bsaratna noship $ */
 l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

        G_PKG_NAME CONSTANT     VARCHAR2(30)    := 'itg_setup';
        G_EXEC_PROC_NAME        VARCHAR2(30)    := 'setup';


        -- Name
        --      setup
        -- Purpose
        --      This procedure is called from a concurrent program(can be called from anywhere actually).
        --      This procedure does the setup required for ITG
        --              i)      Setup default TP location in HR_LOCATIONS
        --              ii)     Setup XMLGateway trading partner definition
        --              iii)    Enable all the ITG triggers
        --      HR_LOCATIONS_ALL table. This is required for the ITG XMLGateway trading partner setup.
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
        PROCEDURE setup(
                             x_errbuf           OUT NOCOPY VARCHAR2,
                             x_retcode          OUT NOCOPY NUMBER

                       )
        IS
                l_retcode                       VARCHAR2(20);
                l_retmesg                       VARCHAR2(400);
                l_tp_hdr_id                     NUMBER;
                l_location_code                 VARCHAR2(30);
                l_description                   VARCHAR2(30);
                l_addr_line_1                   VARCHAR2(30);
                l_country                       VARCHAR2(30);
                l_style                         VARCHAR2(30);
        BEGIN
                G_EXEC_PROC_NAME := 'setup';

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('ENTERING setup'   ,1);
                END IF;

                l_location_code := 'OIPC Default TP';
                l_description   := 'Default XMLG TP for ITG';
                l_addr_line_1   := 'Valhalla';
                l_country       := 'US';
                l_style         := 'US_GLB';


                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('------------------------------'   ,1);
                        itg_debug_pub.Add('Procedure executed with params'   ,1);
                        itg_debug_pub.Add('l_location_code'|| l_location_code,1);
                        itg_debug_pub.Add('l_description ' || l_description  ,1);
                        itg_debug_pub.Add('l_addr_line_1 ' || l_addr_line_1  ,1);
                        itg_debug_pub.Add('l_country  '    || l_country      ,1);
                        itg_debug_pub.Add('l_style    '    || l_style        ,1);
                        itg_debug_pub.Add('------------------------------'   ,1);
                END IF;

                setup_hr_loc(l_retmesg,l_retcode,l_location_code,l_description,
                                l_addr_line_1,l_country,l_style);

                IF (l_Debug_Level <= 5) THEN
                        itg_debug_pub.Add('setup_hr_loc_data - ' || l_retcode ||  ' - ' || substr(l_retmesg,1,200), 5);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode       := 2;
                        x_errbuf        := 'ITG Setup failed (step 1) : '  || l_retmesg;
                        RETURN;
                END IF;

                setup_ecx_tp_header(l_retmesg,l_retcode,l_tp_hdr_id,l_location_code,'itg@oracle.com');

                IF (l_Debug_Level <= 5) THEN
                        itg_debug_pub.Add('setup_ecx_tp_header - ' ||  l_retcode ||  ' - ' || substr(l_retmesg,1,200), 5);
                        itg_debug_pub.Add('setup_ecx_tp_header returns - tp_header_id - ' || l_tp_hdr_id, 5);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode       := 2;
                        x_errbuf        := 'ITG Setup failed (step 2): '  || l_retmesg;
                        RETURN;
                END IF;

                setup_tp_details(l_retmesg,l_retcode,l_tp_hdr_id);

                IF (l_Debug_Level <= 5) THEN
                        itg_debug_pub.Add('setup_tp_details - ' ||  l_retcode ||  ' - ' || substr(l_retmesg,1,200), 5);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode       := 2;
                        x_errbuf        := 'ITG Setup failed (step 3): '  || l_retmesg;
                        RETURN;
                END IF;

                trigger_control(l_retmesg,l_retcode,true);

                IF (l_Debug_Level <= 5) THEN
                        itg_debug_pub.Add('trigger_control(true) - ' ||  l_retcode ||  ' - ' || substr(l_retmesg,1,200), 5);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode       := 2;
                        x_errbuf        := 'ITG Setup failed (step 4): '  || l_retmesg;
                        RETURN;
                END IF;

                x_retcode  := 0;
                x_errbuf   := 'Successful';

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('EXITING itg_setup.setup successful', 2);
                END IF;

        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  2;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);
                        x_errbuf := 'ITG Setup failed : ' ||  x_errbuf;

                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add(x_errbuf, 6);
                                itg_debug_pub.Add('EXITING itg_setup.setup fails,returns on exception', 6);
                        END IF;

        END;

        -- Name
        --      setup_hr_loc
        -- Purpose
        --      This procedure sets up the ITG default trading partner information (OIPC Default TP) in the
        --      HR_LOCATIONS_ALL table. This is required for the ITG XMLGateway trading partner setup.
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_location_code                 => Should have value 'OIPC Default TP'
        --      p_description                   => Some description
        --      p_addr_line_1                   => Some address line 1
        --      p_region_1                      => Some region 1 (province)
        --      p_region_2                      => Some region 2 (State)
        --      p_town_or_city                  => Some city
        --      p_postal_code                   => Some postal code
        -- Notes
        --      We really do not care what value go in here so long as a record
        --      with location code 'OIPC Default TP' is created in Hr_Locations table
        --      All the params input here are mandatory, to the HR APIs which create a location
        --      Defaulting is done in the Concurrent Program definition which wraps this call
        PROCEDURE setup_hr_loc(
                                          x_errbuf         OUT NOCOPY VARCHAR2,
                                          x_retcode        OUT NOCOPY VARCHAR2,
                                          p_location_code  IN VARCHAR2,
                                          p_description    IN VARCHAR2,
                                          p_addr_line_1    IN VARCHAR2,
                                          p_country        IN VARCHAR2,
                                          p_style          IN VARCHAR2
                                )
        IS
             CURSOR check_hrloc_data(p_location_code VARCHAR2) IS
                        SELECT location_id, object_version_number
                        FROM     hr_locations
                        WHERE location_code = p_location_code;
                l_location_id   NUMBER;
                l_obj_ver_num   NUMBER;
                l_record_found  BOOLEAN;
        BEGIN
                G_EXEC_PROC_NAME := 'setup_hr_loc';

                IF (l_Debug_Level <= 2 ) THEN
                        itg_debug_pub.Add('ENTERING setup_hr_loc'   ,1);
                END IF;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('------------------------------'   ,1);
                        itg_debug_pub.Add('Procedure setup_hr_loc executed with params'  ,1 );
                        itg_debug_pub.Add('p_location_code'|| p_location_code,1);
                        itg_debug_pub.Add('p_description ' || p_description  ,1);
                        itg_debug_pub.Add('p_addr_line_1 ' || p_addr_line_1  ,1);
                        itg_debug_pub.Add('p_country     ' || p_country      ,1);
                        itg_debug_pub.Add('p_style       ' || p_style        ,1);
                        itg_debug_pub.Add('------------------------------'   ,1);
                END IF;

                -- validate params check for non-null
                -- if validation fails return error message and bailout.
                IF (     p_location_code   IS NULL
                        OR p_description   IS NULL
                        OR p_addr_line_1   IS NULL
                        OR p_country       IS NULL
                        OR p_style         IS NULL)     THEN

                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        -- Not using a translated message her, since this condition will never occur
                        -- the Concurrent Request submit form itself will validate that input parameters
                        -- are entered by the user.
                        x_errbuf  := 'Missing mandatory parameter for itg_setup.setup_hr_loc';
                        IF (l_Debug_Level <= 6 ) THEN
                                itg_debug_pub.Add('Missing mandatory parameter for itg_setup.setup_hr_loc',6);
                        END IF;

                        RETURN;
                END IF;

                -- query Hr_locations to get location id for given location code
                -- if record does not exists create a new location
                -- else update using the location-id as key
                -- The object_verion_number field is used for optimistic locking in the HR apis

                OPEN  check_hrloc_data(p_location_code);
                FETCH check_hrloc_data INTO l_location_id, l_obj_ver_num;
                l_record_found := check_hrloc_data%FOUND;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('---------------------------------',1);
                        itg_debug_pub.Add('Cursor check_hrloc_data          ',1);
                END IF;

                IF l_record_found THEN
                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('l_record_found - true ' ,1);
                        END IF;
                ELSE
                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('l_record_found - false' ,1);
                        END IF;
                END IF;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('l_location_id  ' || l_location_id ,1);
                        itg_debug_pub.Add('l_obj_ver_num  ' || l_obj_ver_num ,1);
                        itg_debug_pub.Add('---------------------------------',1);
                END IF;

                CLOSE check_hrloc_data;

                IF NOT l_record_found THEN
                        HR_LOCATION_API.create_location(
                                        p_effective_date        => sysdate,
                                        p_language_code         => userenv('LANG'),
                                        p_location_code         => p_location_code,
                                        p_description           => p_description,
                                        p_address_line_1        => p_addr_line_1,
                                        p_country               => p_country,
                                        p_style                 => p_style,
                                        p_location_id           => l_location_id,
                                        p_object_version_number => l_obj_ver_num        );

                                        IF (l_Debug_Level <= 1 ) THEN
                                                itg_debug_pub.Add('---------------------------------' ,1);
                                                itg_debug_pub.Add('HR_LOCATION_API.create_location returns normal',1);
                                                itg_debug_pub.Add('l_location_id  ' || l_location_id ,1);
                                                itg_debug_pub.Add('l_obj_ver_num  ' || l_obj_ver_num ,1);
                                                itg_debug_pub.Add('---------------------------------',1);
                                        END IF;
                ELSE
                        HR_LOCATION_API.update_location(
                                        p_effective_date        => sysdate,
                                        p_language_code         => userenv('LANG'),
                                        p_style                 => p_style,
                                        p_description           => p_description,
                                        p_address_line_1        => p_addr_line_1,
                                        p_region_1              => NULL,
                                        p_region_2              => NULL,
                                        p_town_or_city          => NULL,
                                        p_postal_code           => NULL,
                                        p_country               => p_country,
                                        p_location_id           => l_location_id,
                                        p_object_version_number => l_obj_ver_num        );

                                        IF (l_Debug_Level <= 1 ) THEN
                                                itg_debug_pub.Add('HR_LOCATION_API.update_location returns normal' ,1);
                                        END IF;
                END IF;

                x_retcode  := FND_API.G_RET_STS_SUCCESS;
                x_errbuf   := 'Successful';

                IF (l_Debug_Level <= 2 ) THEN
                        itg_debug_pub.Add('EXITING itg_setup.setup_hr_loc returns normal' ,2);
                END IF;

        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);

                        IF (l_Debug_Level <= 6 ) THEN
                                itg_debug_pub.Add(x_errbuf,6);
                                itg_debug_pub.Add('EXITING itg_setup.setup_hr_loc fails,returns on exception',6);
                        END IF;
        END;

        -- Name
        --      trigger_control
        -- Purpose
        --      Enable or disable all the V3 Connector triggers based on the
        --      boolean value of the p_enable argument.
        -- Arguments
        --      x_errbuf                       => API error mesg param
        --      x_retcode                      => API result param
        --      p_enable                       => true - enable / false - disable trigger
        -- Notes
        --      The trigger list here MUST track the list of triggers
        --      created in itgoutev.sql
        PROCEDURE trigger_control(
                                        x_errbuf       OUT NOCOPY VARCHAR2,
                                        x_retcode      OUT NOCOPY VARCHAR2,
                                        p_enable       BOOLEAN)
        IS
                TYPE trigger_list_t IS VARRAY(20) OF VARCHAR(40);

                /* NOTE: The trigger list here MUST track the list of triggers
                *       created in itgoutev.sql
                */
                trigger_list trigger_list_t :=
                trigger_list_t('itg_ip_requisition_headers_ARU',
                        'itg_ip_requisition_lines_ARU',
                        --'itg_ip_invoices_all_ARI',
                        'itg_ip_headers_all_ARU',
                        'itg_ip_headers_all2_ARU',
                        'itg_ip_lines_all_ARU',
                        'itg_ip_releases_all_ARU',
                        'itg_ip_releases_all2_ARU',
                        'itg_ip_line_locations_all_ARU',
                        'itg_ip_rcv_trans_interface_ASD',
                        'itg_ip_rcv_transactions_ARI');
                i            BINARY_INTEGER;
                l_action     VARCHAR2(10);
        BEGIN
                G_EXEC_PROC_NAME := 'trigger_control';

                IF (l_Debug_Level <= 2 ) THEN
                        itg_debug_pub.Add('ENTERING trigger_control ' ,2);
                END IF;

                IF p_enable THEN
                        l_action := 'ENABLE';
                ELSE
                        l_action := 'DISABLE';
                END IF;
                FOR i IN trigger_list.first .. trigger_list.last LOOP
                        BEGIN
                                EXECUTE IMMEDIATE 'ALTER TRIGGER '||trigger_list(i)||' '||l_action;
                                itg_debug_pub.Add(l_action || ' - ' || trigger_list(i));
                        EXCEPTION
                                WHEN OTHERS THEN
                                        IF (l_Debug_Level <= 5 ) THEN
                                                itg_debug_pub.Add('itg_setup.trigger_control(true) - ' || SQLCODE || ' - ' || SQLERRM, 5);
                                        END IF;
                        END;
                END LOOP;

                x_retcode  := FND_API.G_RET_STS_SUCCESS;
                x_errbuf  := 'Successful';

                IF (l_Debug_Level <= 2 ) THEN
                        itg_debug_pub.Add('EXITING itg_setup.trigger_control(true) returns normal' ,2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);

                        IF (l_Debug_Level <= 6 ) THEN
                                itg_debug_pub.Add(x_errbuf ,6);
                                itg_debug_pub.Add('EXITING itg_setup.trigger_control(true) fails,returns on exception', 6);
                        END IF;
        END;

        -- Name
        --      setup_ecx_tp_header
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup Header block
        --      for a given location code
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_location_code                 => location code for which TP setup is defined
        -- Notes
        --      The given location code should already be present in HR_Locations_all
        PROCEDURE setup_ecx_tp_header(
                                          x_errbuf         OUT NOCOPY VARCHAR2,
                                          x_retcode        OUT NOCOPY VARCHAR2,
                                          x_tp_hdr_id      OUT NOCOPY NUMBER,
                                          p_location_code  IN VARCHAR2,
                                          p_email_id       IN VARCHAR2
                                )
        IS
                l_retcode       VARCHAR2(30);
                l_retmesg       VARCHAR2(400);
                l_loc_id        NUMBER;
                l_tp_hdr_id     NUMBER;
                l_found         BOOLEAN;

             CURSOR check_ecx_tp_hdr(p_party_type       VARCHAR2,
                                     p_party_id         NUMBER ,
                                     p_party_site_id    NUMBER) IS
                        SELECT tp_header_id
                        FROM   ecx_tp_headers
                        WHERE       party_type          = p_party_type
                                AND party_id            = p_party_id
                                AND party_site_id       = p_party_site_id;

        BEGIN
                G_EXEC_PROC_NAME := 'setup_ecx_tp_header';

                IF (l_Debug_Level <= 2 ) THEN
                      itg_debug_pub.Add('ENTERING setup_ecx_tp_header'    ,2);
                END IF;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('------------------------------'    ,1);
                        itg_debug_pub.Add('Procedure setup_ecx_tp_header executed with params'  ,1 );
                        itg_debug_pub.Add('p_location_code'|| p_location_code ,1);
                        itg_debug_pub.Add('------------------------------'    ,1);
                END IF;

                SELECT  location_id
                INTO    l_loc_id
                FROM    hr_locations_all
                WHERE   location_code = p_location_code;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('Obtained location id - ' || l_loc_id,1);
                END IF;
                -- query ecx_tp_headers to get tp_header_id for a given trading partner setup
                -- If no record is found create a tp header block else update it

                OPEN  check_ecx_tp_hdr('I',l_loc_id,l_loc_id);
                FETCH check_ecx_tp_hdr INTO l_tp_hdr_id;
                l_found := check_ecx_tp_hdr%FOUND;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('---------------------------------',1);
                        itg_debug_pub.Add('Cursor check_ecx_tp_hdr          ',1);
                END IF;

                IF l_found THEN
                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('check_ecx_tp_hdr%FOUND - true ' ,1);
                        END IF;
                ELSE
                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('check_ecx_tp_hdr%FOUND - false',1);
                        END IF;
                END IF;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('l_tp_hdr_id  ' || l_tp_hdr_id ,1);
                        itg_debug_pub.Add('---------------------------------',1);
                END IF;

                CLOSE check_ecx_tp_hdr;

                IF NOT l_found THEN
                        ecx_tp_api.create_trading_partner(
                                                x_return_status         => l_retcode,
                                                x_msg                   => l_retmesg,
                                                x_tp_header_id          => l_tp_hdr_id,
                                                p_party_type            => 'I',
                                                p_party_id              => l_loc_id,
                                                p_party_site_id         => l_loc_id ,
                                                p_company_admin_email   => p_email_id
                                                );
                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('---------------------------------',1);
                                itg_debug_pub.Add('ecx_tp_api.create_trading_partner returns normal',1);
                                itg_debug_pub.Add('x_return_status  '       || l_retcode      ,1);
                                itg_debug_pub.Add('x_msg  '                 || l_retmesg      ,1);
                                itg_debug_pub.Add('x_tp_header_id  '        || l_tp_hdr_id    ,1);
                                itg_debug_pub.Add('---------------------------------',1);
                        END IF;
                ELSE
                        -- this is an overkill for ITG
                        -- the email id will not be used for anything
                        ecx_tp_api.update_trading_partner(
                                                x_return_status         => l_retcode,
                                                x_msg                   => l_retmesg,
                                                p_tp_header_id          => l_tp_hdr_id,
                                                p_company_admin_email   => p_email_id
                                                );

                        IF (l_Debug_Level <= 1 ) THEN
                                itg_debug_pub.Add('---------------------------------',1);
                                itg_debug_pub.Add('ecx_tp_api.update_trading_partner returns normal',1);
                                itg_debug_pub.Add('x_return_status  '       || l_retcode      ,1);
                                itg_debug_pub.Add('x_msg  '                 || l_retmesg      ,1);
                                itg_debug_pub.Add('---------------------------------' ,1);
                        END IF;
                END IF;

                IF l_retcode <> 0 THEN
                        x_tp_hdr_id := NULL;
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                ELSE
                        x_retcode   := FND_API.G_RET_STS_SUCCESS;
                        x_errbuf    := 'Successful';
                        x_tp_hdr_id := l_tp_hdr_id;
                END IF;

                IF (l_Debug_Level <= 1 ) THEN
                        itg_debug_pub.Add('EXITING itg_setup.setup_ecx_tp_header returns normal' ,1);
                        itg_debug_pub.Add('x_errbuf         - ' || x_errbuf   ,1);
                        itg_debug_pub.Add('x_retcode        - ' || x_retcode  ,1);
                        itg_debug_pub.Add('x_tp_hdr_id      - ' || x_tp_hdr_id ,1);
                        itg_debug_pub.Add('---------------------------------' ,1);
                END IF;
        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        x_tp_hdr_id := NULL;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);

                        IF (l_Debug_Level <= 6 )THEN
                                itg_debug_pub.Add(x_errbuf ,6);
                                itg_debug_pub.Add('EXITING itg_setup.setup_ecx_tp_header fails,returns on exception',6);
                        END IF;
        END;



        PROCEDURE setup_tp_details(
                                        x_errbuf        OUT NOCOPY VARCHAR2,
                                        x_retcode       OUT NOCOPY VARCHAR2,
                                        p_tp_hdr_id     NUMBER)
        IS
                l_retcode               VARCHAR2(20);
                l_retmesg               VARCHAR2(800);
                l_tp_dtl_id             NUMBER;

        BEGIN
                G_EXEC_PROC_NAME := 'setup_tp_details';

                IF (l_Debug_Level <= 2 )THEN
                      itg_debug_pub.Add('ENTERING setup_tp_details API'    ,2);
                END IF;


                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_PO_RELEASE','OAG','ITG','SYNC_PO_RELEASE','OUT',
                                        'itg_sync_po_release_007_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_PO_RELEASE - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','CANCEL_PO_RELEASE','OAG','ITG','CANCEL_PO_RELEASE','OUT',
                                        'itg_cancel_po_release_006_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('CANCEL_PO_RELEASE - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','CANCEL_PO','OAG','ITG','CANCEL_PO','OUT',
                                        'itg_cancel_po_006_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('CANCEL_PO - ' || l_retcode || l_retmesg ,1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','ADD_REQUISITN','OAG','ITG','ADD_REQUISITN','OUT',
                                        'itg_add_requisitn_005_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('ADD_REQUISITN - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','CHANGE_REQUISITN','OAG','ITG','CHANGE_REQUISITN','OUT',
                                        'itg_change_requisitn_005_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('CHANGE_REQUISITN - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','CANCEL_REQUISITN','OAG','ITG','CANCEL_REQUISITN','OUT',
                                        'itg_cancel_requisitn_005','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('CANCEL_REQUISITN - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_PO','OAG','ITG','SYNC_PO','OUT',
                                        'itg_sync_po_007_out','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_PO - ' || l_retcode || l_retmesg , 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','UPDATE_DELIVERY','OAG','ITG','UPDATE_DELIVERY','OUT',
                                        'itg_update_delivery_005','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                      itg_debug_pub.Add('UPDATE_DELIVERY - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','LOAD_PLINVOICE','OAG','ITG','LOAD_PLINVOICE','OUT',
                                        'itg_load_plinvoice_004','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');

                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('UPDATE_DELIVERY - ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ECX','CBODO','OAG','BOD','CONFIRM','OUT',
                                        'ECX_CBODO_OAG72_OUT_CONFIRM','DIRECT',null,'ITG03','129.0.0.1',
                                        'itg','welcome',null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('CBODO - ' || l_retcode || l_retmesg , 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_FIELD_004','OAG','ITG','SYNC_FIELD_004','IN',
                                        'itg_sync_field_004_in',null,null,null,null,
                                        null,null,null,'ITG03',null,0,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_FIELD_004 IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_UOMGROUP_003','OAG','ITG','SYNC_UOMGROUP_003','IN',
                                        'itg_sync_uomgroup_003_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');

                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_UOMGROUP_003 IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_SUPPLIER_005','OAG','ITG','SYNC_SUPPLIER_005','IN',
                                        'itg_sync_supplier_005_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_SUPPLIER_005 IN- ' || l_retcode || l_retmesg ,1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_EXCHNGRATE_003','OAG','ITG','SYNC_EXCHNGRATE_003','IN',
                                        'itg_sync_exchngrate_003_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SSYNC_EXCHNGRATE_003 IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_ITEM_006','OAG','ITG','SYNC_ITEM_006','IN',
                                        'itg_Sync_Item_006_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_ITEM_006 IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_COA_003','OAG','ITG','SYNC_COA_003','IN',
                                        'itg_sync_coa_003_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_COA_003 IN- ' || l_retcode || l_retmesg ,1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'ITG','SYNC_PO','OAG','ITG','SYNC_PO_007','IN',
                                        'ITG_sync_po_007_in',null,null,null,null,
                                        null,null,null,'ITG03',null,2,p_tp_hdr_id,'I');

                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('SYNC_PO IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                add_or_update_tp_detail(l_retmesg,l_retcode,l_tp_dtl_id,
                                        'CLN','NBOD','OAG','CLN','NBOD','IN',
                                        'CLN_NBODI_OAG72_IN_CONFIRM',null,null,null,null,
                                        null,null,null,'ITG03',null,0,p_tp_hdr_id,'I');
                IF (l_Debug_Level <= 1 )THEN
                        itg_debug_pub.Add('NBOD IN- ' || l_retcode || l_retmesg, 1);
                END IF;

                IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                        RETURN;
                END IF;

                x_retcode  := FND_API.G_RET_STS_SUCCESS;
                x_errbuf   := 'Successful';


                IF (l_Debug_Level <= 2 )THEN
                      itg_debug_pub.Add(' EXITING itg_setup.setup_tp_details normal', 2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);

                        IF (l_Debug_Level <= 6 )THEN
                                itg_debug_pub.Add(x_errbuf, 6);
                                itg_debug_pub.Add('EXITING itg_setup.setup_tp_details fails,returns on exception',6);
                        END IF;
        END;

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
                                                x_errbuf        OUT NOCOPY VARCHAR2,
                                                x_retcode       OUT NOCOPY VARCHAR2,
                                                x_tp_dtl_id     NUMBER,
                                                p_txn_type      VARCHAR2,
                                                p_txn_subtype   VARCHAR2,
                                                p_std_code      VARCHAR2,
                                                p_ext_type      VARCHAR2,
                                                p_ext_subtype   VARCHAR2,
                                                p_direction     VARCHAR2,
                                                p_map           VARCHAR2,
                                                p_conn_type     VARCHAR2,
                                                p_hub_user_id   NUMBER,
                                                p_protocol      VARCHAR2,
                                                p_protocol_addr VARCHAR2,
                                                p_user          VARCHAR2,
                                                p_passwd        VARCHAR2,
                                                p_routing_id    NUMBER,
                                                p_src_loc       VARCHAR2,
                                                p_ext_loc       VARCHAR2,
                                                p_doc_conf      NUMBER,
                                                p_tp_hdr_id     NUMBER,
                                                p_party_type    VARCHAR2

                                         )
        IS
                CURSOR get_tp_detail_id(
                                        p_tp_hdr_id     VARCHAR2,
                                        p_standard_code VARCHAR2,
                                        p_ext_type      VARCHAR2,
                                        p_ext_subtype   VARCHAR2,
                                        p_direction     VARCHAR2,
                                        p_txn_type      VARCHAR2,
                                        p_txn_subtype   VARCHAR2
                                        )IS
                        SELECT tp_detail_id
                        FROM
                                ecx_tp_details    tpd,
                                ecx_tp_headers    tph,
                                ecx_ext_processes extp,
                                ecx_transactions  txn,
                                ecx_standards     svl
                        WHERE   1=1
                                AND tph.tp_header_id    = tpd.tp_header_id
                                AND tpd.ext_process_id  = extp.ext_process_id
                                AND extp.transaction_id = txn.transaction_id
                                AND extp.standard_id    = svl.standard_id
                                AND svl.standard_code   = p_std_code
                                AND extp.ext_type       = p_ext_type
                                AND extp.ext_subtype    = p_ext_subtype
                                AND extp.direction      = p_direction
                                AND txn.transaction_type    = p_txn_type
                                AND txn.transaction_subtype = p_txn_subtype
                                AND tph.tp_header_id        = p_tp_hdr_id;

                l_tp_dtl_id      NUMBER;
                l_ext_process_id NUMBER;
                l_record_found   BOOLEAN;
                l_retcode        NUMBER;
                l_count          NUMBER := 0;
                l_retmesg        VARCHAR2(400);
        BEGIN

                G_EXEC_PROC_NAME := 'add_or_update_tp_detail';

                IF (l_Debug_Level <= 2 )THEN
                        itg_debug_pub.Add('ENTERING add_or_update_tp_detail API'    ,2);
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('------------------------------'    ,1);
                        itg_debug_pub.Add('Procedure add_or_update_tp_detail with params'  ,1 );
                        itg_debug_pub.Add('p_txn_type     ' || p_txn_type     ,1);
                        itg_debug_pub.Add('p_txn_subtype  ' || p_txn_subtype  ,1);
                        itg_debug_pub.Add('p_std_code     ' || p_std_code     ,1);
                        itg_debug_pub.Add('p_ext_type     ' || p_ext_type     ,1);
                        itg_debug_pub.Add('p_ext_subtype  ' || p_ext_subtype  ,1);
                        itg_debug_pub.Add('p_direction    ' || p_direction    ,1);
                        itg_debug_pub.Add('p_map          ' || p_map          ,1);
                        itg_debug_pub.Add('p_conn_type    ' || p_conn_type    ,1);
                        itg_debug_pub.Add('p_hub_user_id  ' || p_hub_user_id  ,1);
                        itg_debug_pub.Add('p_protocol     ' || p_protocol     ,1);
                        itg_debug_pub.Add('p_protocol_addr' || p_protocol_addr,1);
                        itg_debug_pub.Add('p_user         ' || p_user         ,1);
                        itg_debug_pub.Add('p_passwd       ' || p_passwd       ,1);
                        itg_debug_pub.Add('p_routing_id   ' || p_routing_id   ,1);
                        itg_debug_pub.Add('p_src_loc      ' || p_src_loc      ,1);
                        itg_debug_pub.Add('p_ext_loc      ' || p_ext_loc      ,1);
                        itg_debug_pub.Add('p_doc_conf     ' || p_doc_conf     ,1);
                        itg_debug_pub.Add('p_tp_hdr_id    ' || p_tp_hdr_id    ,1);
                        itg_debug_pub.Add('p_tparty_type  ' || p_party_type   ,1);
                        itg_debug_pub.Add('------------------------------'    ,1);
                END IF;

                -- query ecx_tp_detail_id to get ecx_tp_detail_id for given location code
                -- if record does not exists create a new detail record
                -- else update the detail record
                OPEN  get_tp_detail_id(p_tp_hdr_id, p_std_code,p_ext_type,p_ext_subtype,
                                       p_direction,p_txn_type,p_txn_subtype);

                FETCH get_tp_detail_id INTO l_tp_dtl_id;
                l_record_found := get_tp_detail_id%FOUND;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('---------------------------------', 1);
                        itg_debug_pub.Add('Cursor get_tp_detail_id          ', 1);
                END IF;

                IF l_record_found THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('l_record_found - true ', 1);
                        END IF;
                ELSE
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('l_record_found - false', 1);
                        END IF;
                END IF;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('l_tp_dtl_id  ' || l_tp_dtl_id ,1);
                        itg_debug_pub.Add('---------------------------------',1);
                END IF;

                CLOSE get_tp_detail_id;

                BEGIN
                        SELECT  extp.ext_process_id
                        INTO    l_ext_process_id
                        FROM    ecx_ext_processes extp,
                                ecx_transactions  txn,
                                ecx_standards     svl
                        WHERE           1=1
                                AND extp.transaction_id         = txn.transaction_id
                                AND extp.standard_id            = svl.standard_id
                                AND svl.standard_code           = p_std_code
                                AND extp.ext_type               = p_ext_type
                                AND extp.ext_subtype            = p_ext_subtype
                                AND extp.direction              = p_direction
                                AND txn.party_type              = p_party_type
                                AND txn.transaction_type        = p_txn_type
                                AND txn.transaction_subtype     = p_txn_subtype;

                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('ext_process_id - ' || l_ext_process_id ,1);
                                END IF;
                EXCEPTION
                        WHEN OTHERS THEN
                             IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add('Cannot retrieve ext_process_id', 6);
                                itg_debug_pub.Add('Exception - ' || SQLCODE || ' - ' || SQLERRM, 6);
                             END IF;

                             x_retcode  := FND_API.G_RET_STS_ERROR;
                             set_errmesg(x_errbuf,SQLCODE,SQLERRM);
                             RETURN;
                END;

                BEGIN
                        SELECT  count(*)
                        INTO    l_count
                        FROM    ecx_ext_processes extp,
                                ecx_tp_details    tpd,
                                ecx_standards     svl
                        WHERE           1=1
                                AND extp.standard_id     = svl.standard_id
                                AND svl.standard_code   = p_std_code
                                AND extp.ext_process_id = tpd.ext_process_id
                                AND extp.ext_type       = p_ext_type
                                AND extp.ext_subtype    = p_ext_subtype
                                AND extp.direction      = p_direction
                                AND tpd.source_tp_location_code = p_src_loc
                                AND tpd.tp_header_id          <> p_tp_hdr_id;

                                IF l_count > 0 THEN
                                        x_retcode  := FND_API.G_RET_STS_ERROR;
                                        x_errbuf   := 'Found ECX TP Detail record for (' || p_std_code
                                        || ',' || p_ext_type || ','  || p_ext_subtype
                                        || ',' || p_direction || ',' || ' source location '|| p_src_loc
                                        || '), please delete this record and resubmit the Setup program.';
                                        RETURN;
                                END IF;

                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('ext_process_id - ' || l_ext_process_id);
                                END IF;
                EXCEPTION
                        WHEN OTHERS THEN
                                   IF (l_Debug_Level <= 6) THEN
                                         itg_debug_pub.Add('Unexpected error', 6);
                                         itg_debug_pub.Add('Exception - ' || SQLCODE || ' - ' || SQLERRM, 6);
                                   END IF;

                                   x_retcode  := FND_API.G_RET_STS_ERROR;
                                   set_errmesg(x_errbuf,SQLCODE,SQLERRM);
                                   RETURN;
                END;

                IF NOT l_record_found THEN
                        ecx_tp_api.create_tp_detail(
                                x_return_status                 =>  l_retcode,
                                x_msg                           =>  l_retmesg,
                                x_tp_detail_id                  =>  l_tp_dtl_id,
                                p_tp_header_id                  =>  p_tp_hdr_id,
                                p_ext_process_id                =>  l_ext_process_id,
                                p_map_code                      =>  p_map,
                                p_connection_type               =>  p_conn_type,
                                p_hub_user_id                   =>  p_hub_user_id,
                                p_protocol_type                 =>  p_protocol,
                                p_protocol_address              =>  p_protocol_addr,
                                p_username                      =>  p_user,
                                p_password                      =>  p_passwd,
                                p_routing_id                    =>  p_routing_id,
                                p_source_tp_location_code       =>  p_src_loc,
                                p_external_tp_location_code     =>  p_ext_loc,
                                p_confirmation                  =>  p_doc_conf
                                );

                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('----------------------------' ,1);
                                        itg_debug_pub.Add('ecx_tp_api.create_tp_detail returns normal',1);
                                        itg_debug_pub.Add('l_retcode   ' || l_retcode   ,1);
                                        itg_debug_pub.Add('l_retmesg   ' || l_retmesg   ,1);
                                        itg_debug_pub.Add('l_tp_dtl_id ' || l_tp_dtl_id ,1);
                                        itg_debug_pub.Add('----------------------------',1);
                                END IF;
                ELSE
                        ecx_tp_api.update_tp_detail(
                                        x_return_status                 => l_retcode,
                                        x_msg                           => l_retmesg,
                                        p_tp_detail_id                  => l_tp_dtl_id,
                                        p_map_code                      => p_map,
                                        p_ext_process_id                => l_ext_process_id,
                                        p_connection_type               => p_conn_type,
                                        p_hub_user_id                   => p_hub_user_id,
                                        p_protocol_type                 => p_protocol,
                                        p_protocol_address              => p_protocol_addr,
                                        p_username                      => p_user,
                                        p_password                      => p_passwd,
                                        p_routing_id                    => p_routing_id,
                                        p_source_tp_location_code       => p_src_loc,
                                        p_external_tp_location_code     => p_ext_loc,
                                        p_confirmation                  => p_doc_conf,
                                        p_passupd_flag                  => 'Y'
                                      );


                                IF (l_Debug_Level <= 1) THEN
                                        itg_debug_pub.Add('----------------------------' ,1);
                                        itg_debug_pub.Add('ecx_tp_api.update_tp_detail returns normal',1);
                                        itg_debug_pub.Add('l_retcode   ' || l_retcode   ,1);
                                        itg_debug_pub.Add('l_retmesg   ' || l_retmesg   ,1);
                                        itg_debug_pub.Add('----------------------------',1);
                                END IF;
                END IF;

                IF l_retcode = 0 THEN
                        x_retcode  := FND_API.G_RET_STS_SUCCESS;
                        x_errbuf   := 'Successful';
                ELSE
                        x_retcode  := FND_API.G_RET_STS_ERROR;
                        x_errbuf   := l_retmesg;
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('EXITING itg_setup.add_or_update_tp_detail returns normal', 2);
                END IF;
        -- Exception Handling
        EXCEPTION
                WHEN OTHERS THEN
                        x_retcode :=  FND_API.G_RET_STS_ERROR;
                        set_errmesg(x_errbuf,SQLCODE,SQLERRM);

                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add(x_errbuf, 6);
                                itg_debug_pub.Add('EXITING itg_setup.add_or_update_tp_detail fails,returns on exception',6);
                        END IF;
        END;



        -- Name
        --      set_errmesg
        -- Purpose
        --      Helper routine, wraps FND_MESSAGE API call
        -- Arguments
                --      x_err_buf       => FND message containing error with context info
                --      p_errcode       => Error code
                --      p_errmesg       => Error message
        -- Notes
        --      None
        PROCEDURE set_errmesg(          x_errbuf          OUT NOCOPY VARCHAR2,
                                        p_errcode         IN  VARCHAR2,
                                        p_errmesg         IN  VARCHAR2)
        IS
                l_errmesg VARCHAR2(250);
        BEGIN
                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('ENTERING set_errmesg', 2);
                END IF;

                l_errmesg := SUBSTR(p_errmesg,1,200);

                IF p_errcode IS NOT NULL THEN
                     l_errmesg := p_errcode || ' - ' || l_errmesg;
                END IF;

                FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_errmesg);
                FND_MESSAGE.SET_TOKEN('PKG_NAME',G_PKG_NAME);
                FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',G_EXEC_PROC_NAME);
                x_errbuf := FND_MESSAGE.GET;

                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('EXITING set_errmesg -  ' || x_errbuf, 2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        IF (l_Debug_Level <= 6) THEN
                                itg_debug_pub.Add('EXITING set_errmesg - ' || SQLCODE || ' - ' || SQLERRM,6);
                        END IF;
                        x_errbuf := p_errcode || ' - ' || p_errmesg;
        END;

END itg_setup;

/
