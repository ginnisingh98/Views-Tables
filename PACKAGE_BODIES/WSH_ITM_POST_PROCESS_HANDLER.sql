--------------------------------------------------------
--  DDL for Package Body WSH_ITM_POST_PROCESS_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_POST_PROCESS_HANDLER" AS
/* $Header: WSHITPHB.pls 120.3.12010000.2 2008/10/01 12:47:49 skanduku ship $ */
        --
        G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_POST_PROCESS_HANDLER';
        --
        /*
        ** This procedure checks if there are any pending requests
        ** to be processed in case the request belongs to a
        ** request set. It also calls the CALL_CUSTOM_API procedure
        **
        ** p_request_control_id - REQUEST CONTROL ID
        ** p_request_set_id     - REQUEST SET ID
        ** p_application_id     - APPLICATION ID
        ** p_source             - SOURCE OF CALL
        **                              ECX - XMLGATEWAY(ASYNCHRNOUS MODE)
        **                              ITM - ITM JAVA CODE(SYNCHRNOUS MODE)
        */
        PROCEDURE CHECK_PENDING_CALL_API(p_request_control_id   NUMBER,
                                         p_request_set_id       NUMBER,
                                         p_application_id       NUMBER,
                                         p_source               VARCHAR2) IS
                l_count         NUMBER;
                --
                l_debug_on    BOOLEAN;
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PENDING_CALL_API';
                --

        BEGIN
                --
                l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                --
                IF ( l_debug_on IS NULL )
                THEN
                    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                END IF;
                --
                IF l_debug_on and p_source = 'ITM' THEN
                    WSH_DEBUG_SV.Push(l_module_name);
                    WSH_DEBUG_SV.Log(l_module_name, 'p_request_control_id', p_request_control_id );
                    WSH_DEBUG_SV.Log(l_module_name, 'p_request_set_id', p_request_set_id );
                    WSH_DEBUG_SV.Log(l_module_name, 'p_application_id', p_application_id );
                    WSH_DEBUG_SV.Log(l_module_name, 'p_source', p_source );
                END IF;
                --

                BEGIN
                        IF p_request_set_id <> 0 THEN
                                SELECT COUNT(REQUEST_CONTROL_ID)
                                INTO   l_count
                                FROM   WSH_ITM_REQUEST_CONTROL
                                WHERE  REQUEST_SET_ID = p_request_set_id
                                AND    PROCESS_FLAG <= 0;

                                IF l_count = 0 THEN
                                        IF l_debug_on THEN
                                           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Program Unit CALL_CUSTOM_API with p_request_set_id',WSH_DEBUG_SV.C_PROC_LEVEL);
                                        END IF;
                                        CALL_CUSTOM_API(0, p_request_set_id, p_application_id, p_source);
                                ELSE
                                       IF l_debug_on AND P_SOURCE = 'ITM' THEN
                                            WSH_DEBUG_SV.logmsg(l_module_name, 'Pending records for Request Set '|| p_request_set_id);
                                        END IF;
                                END IF;
                        ELSE
                                IF l_debug_on THEN
                                   WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Program Unit CALL_CUSTOM_API with p_request_control_id',WSH_DEBUG_SV.C_PROC_LEVEL);
                                END IF;
                                CALL_CUSTOM_API(p_request_control_id, 0, p_application_id, p_source);
                        END IF;
                EXCEPTION
                        WHEN OTHERS THEN

                             WSH_UTIL_CORE.Default_Handler(l_module_name);
                             IF l_debug_on AND P_SOURCE = 'ITM' THEN
                                WSH_DEBUG_SV.logmsg(l_module_name, 'Error in calling CALL_CUSTOM_API '||SQLERRM);
                             END IF;
                END;
                --
                IF l_debug_on AND p_source = 'ITM' THEN
                   WSH_DEBUG_SV.Pop(l_module_name);
                END IF;
                --

        EXCEPTION
           WHEN OTHERS THEN
             IF l_debug_on AND p_source = 'ITM' THEN
                WSH_DEBUG_SV.logmsg(l_module_name,SQLCODE||'-'||SQLERRM);
                WSH_DEBUG_SV.Pop(l_module_name);
             END IF;

        END;

        /*
        ** This procedure gets the application short name and builds
        ** the custom procedure which is coded by the integrating
        ** application. This could drive the integrating application
        ** into whatever process they have been into since they
        ** entered ITM for soem kind of complaince check.
        **
        ** p_request_control_id - REQUEST CONTROL ID
        ** p_request_set_id     - REQUEST SET ID
        ** p_application_id     - APPLICATION ID
        ** p_source             - SOURCE OF CALL
        **                              ECX - XMLGATEWAY(ASYNCHRNOUS MODE)
        **                              ITM - ITM JAVA CODE(SYNCHRNOUS MODE)
        */
        PROCEDURE CALL_CUSTOM_API( p_request_control_id NUMBER,
                                   p_request_set_id     NUMBER,
                                   p_application_id     NUMBER,
                                   p_source             VARCHAR2) IS
                l_app_shname                    VARCHAR2(10);
                l_procedure_name                VARCHAR2(500);
                l_debug_on    BOOLEAN;
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CALL_CUSTOM_API';
        BEGIN
                 --
                l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                --
                IF ( l_debug_on IS NULL )
                THEN
                    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                END IF;
                --
                IF l_debug_on and p_source = 'ITM' THEN
                    WSH_DEBUG_SV.Push(l_module_name);
                END IF;
                --

                --GET APPLICATION SHORT NAME
                BEGIN
                        SELECT APPLICATION_SHORT_NAME
                        INTO   l_app_shname
                        FROM   FND_APPLICATION
                        WHERE  APPLICATION_ID = p_application_id;
                EXCEPTION
                        WHEN OTHERS THEN
                               WSH_UTIL_CORE.Default_Handler(l_module_name);
                               IF l_debug_on AND p_source = 'ITM' THEN
                                   WSH_DEBUG_SV.Log(l_module_name, 'Error getting application shortname for Id - ' || p_application_id, SQLERRM);
                               END IF;
                               goto end_block;
                END;

                --      build procedure <short_name>_ITM_PKG.WSH_ITM_<short_name>
                l_procedure_name := ' BEGIN '||l_app_shname||'_ITM_PKG.WSH_ITM_'||l_app_shname ||'(p_request_control_id=>:p_request_control_id, p_request_set_id=>:p_request_set_id); END;';

                IF l_debug_on AND p_source = 'ITM' THEN
                    WSH_DEBUG_SV.Logmsg(l_module_name, 'l_procedure_name '||l_procedure_name );
                END IF;

                BEGIN
                        EXECUTE IMMEDIATE  l_procedure_name
                                  USING  p_request_control_id,
                                         p_request_set_id;
                EXCEPTION
                        WHEN OTHERS THEN
                                WSH_UTIL_CORE.Default_Handler(l_module_name);
                             IF l_debug_on AND p_source = 'ITM' THEN
                                 WSH_DEBUG_SV.Logmsg(l_module_name, 'Error in Custom Procedure '|| SQLERRM);
                             END IF;
                             goto end_block;
                END;
          --      Added as part of Additional Attributes required by G.E
          --      build procedure <short_name>_ITM_CUSTOM_PROCESS.POST_PROCESS_REQUEST
                IF l_debug_on AND p_source = 'ITM' THEN
                        WSH_DEBUG_SV.Logmsg(l_module_name, 'Calling WSH_ITM_CUSTOM_PROCESS.POST_PROCESS_'||l_app_shname||'_REQUEST');
                END IF;

                l_procedure_name := ' BEGIN WSH_ITM_CUSTOM_PROCESS.POST_PROCESS_'||l_app_shname||'_REQUEST (p_request_control_id=>:p_request_control_id); END;';

                BEGIN
                        EXECUTE IMMEDIATE  l_procedure_name
                                  USING  p_request_control_id;

                EXCEPTION
                        WHEN OTHERS THEN
                                IF l_debug_on AND p_source = 'ITM' THEN
                                        WSH_DEBUG_SV.Logmsg(l_module_name, 'Error in Custom Procedure:' || l_procedure_name || ' - ' || SQLERRM);
                                END IF;
                END;
                <<end_block>>
                --
                IF l_debug_on AND p_source = 'ITM' THEN
                   WSH_DEBUG_SV.Pop(l_module_name);
                END IF;
                --

         EXCEPTION
           WHEN OTHERS THEN
             IF l_debug_on AND p_source = 'ITM' THEN
                WSH_DEBUG_SV.logmsg(l_module_name,SQLCODE||'-'||SQLERRM);
                WSH_DEBUG_SV.Pop(l_module_name);
             END IF;

        END CALL_CUSTOM_API;

        -- Bug 5222683
        -- Overloaded API added for enabling shipping and OM debugging
        PROCEDURE CHECK_PENDING_CALL_API(p_request_control_id   NUMBER,
                                         p_request_set_id       NUMBER,
                                         p_application_id       NUMBER,
                                         p_source               VARCHAR2,
                                         p_itm_log_level        NUMBER,
                                         p_log_filename         VARCHAR2)
        IS
           l_file_ptr        UTL_FILE.File_Type;
           l_debug_process   BOOLEAN;
           l_log_directory   VARCHAR2(4000);
        BEGIN

           --If ITM Log Severity is set to DEBUG then enable Shipping and OM Debugging
           IF ( p_itm_log_level = '1' ) THEN -- {
           BEGIN
              fnd_profile.get('WSH_DEBUG_LOG_DIRECTORY',l_log_directory);
              l_file_ptr := UTL_FILE.Fopen(l_log_directory, p_log_filename, 'a');
              WSH_DEBUG_INTERFACE.Start_Debugger(
                 p_dir_name    => l_log_directory,
                 p_file_name   => p_log_filename,
                 p_file_handle => l_file_ptr );
              OE_DEBUG_PUB.Start_ONT_Debugger(
                 p_directory   => l_log_directory,
                 p_filename    => p_log_filename,
                 p_file_handle => l_file_ptr );

              l_debug_process := TRUE;

           -- Added Exception handler so that we can call API Check_Pending_Call_API
           -- even if file handling raises any exception.
           EXCEPTION
             WHEN OTHERS THEN
               l_debug_process := FALSE;
           END;
           END IF; --}

           --Call Internal API
           Check_Pending_Call_API( p_request_control_id => p_request_control_id,
                                   p_request_set_id     => p_request_set_id,
                                   p_application_id     => p_application_id,
                                   p_source             => p_source);


           --If ITM Log Severity is set to DEBUG then disable Shipping and OM Debugging
           IF ( p_itm_log_level = '1' and l_debug_process ) THEN -- {
              OE_DEBUG_PUB.Stop_ONT_Debugger;
              WSH_DEBUG_INTERFACE.Stop_Debugger;
              IF utl_file.is_open(l_file_ptr) THEN
                 utl_file.fclose(l_file_ptr);
              END IF;
           END IF; --}

         EXCEPTION
           WHEN OTHERS THEN
                IF ( p_itm_log_level = '1' ) THEN -- {
                   OE_DEBUG_PUB.Stop_ONT_Debugger;
                   WSH_DEBUG_INTERFACE.Stop_Debugger;
                   IF utl_file.is_open(l_file_ptr) THEN
                      utl_file.fclose(l_file_ptr);
                   END IF;
                END IF; --}

        END CHECK_PENDING_CALL_API;
END WSH_ITM_POST_PROCESS_HANDLER;

/
