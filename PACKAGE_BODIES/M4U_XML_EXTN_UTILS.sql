--------------------------------------------------------
--  DDL for Package Body M4U_XML_EXTN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4U_XML_EXTN_UTILS" AS
/* $Header: M4UXUTLB.pls 120.1 2006/06/09 08:13:36 bsaratna noship $ */

        g_success_code          VARCHAR2(30);  -- cache FND code
        g_err_code              VARCHAR2(30);  -- cache FND code
        g_unexp_err_code        VARCHAR2(30);  -- cache FND code
        g_log_lvl               NUMBER;        -- CLN log level
        g_log_dir               VARCHAR2(800); -- CLN log directory


        -- helper routine
        -- escapes predefined xml entities from value string
        -- ampersand, apos, quot, lt, gt
        FUNCTION escape_entities(a_val IN varchar2)
        RETURN VARCHAR2 AS
                l_cntr          NUMBER;
                l_size          NUMBER;
                l_char          CHAR(1);
                l_ret_val       VARCHAR2(32767);
        BEGIN
                IF a_val IS NULL THEN
                        l_ret_val := NULL;
                ELSE
                        l_size := length(a_val);
                        l_cntr := 1;
                        LOOP
                                EXIT WHEN l_cntr > l_size;

                                l_char := substr(a_val,l_cntr,1);

                                IF l_char = '<' THEN
                                        l_ret_val := l_ret_val || fnd_global.Local_Chr(38) || 'lt;';
                                ELSIF l_char = '>' THEN
                                        l_ret_val := l_ret_val || fnd_global.Local_Chr(38) || 'gt;';
                                ELSIF l_char = '"' THEN
                                        l_ret_val := l_ret_val || fnd_global.Local_Chr(38) || 'quot;';
                                ELSIF l_char = '''' THEN
                                        l_ret_val := l_ret_val || fnd_global.Local_Chr(38) || 'apos;';
                                ELSIF l_char = fnd_global.Local_Chr(38) THEN
                                        l_ret_val := l_ret_val || fnd_global.Local_Chr(38) || 'amp;';
                                ELSE
                                        l_ret_val := l_ret_val || l_char;
                                END IF;
                                l_cntr := l_cntr+1;
                        END LOOP;
                END IF;

                RETURN l_ret_val;
        END escape_entities;


        -- Helper procedure to handle exception
        -- creates translatable message based on error and context
        -- sets x_ret_sts to error and x_ret_msg to message
        -- logs error
        PROCEDURE handle_exception(
                        a_sql_code              IN NUMBER,
                        a_sql_errm              IN VARCHAR2,
                        a_actn                  IN VARCHAR2,
                        a_proc                  IN VARCHAR2,
                        x_ret_sts               OUT NOCOPY VARCHAR2,
                        x_ret_msg               OUT NOCOPY VARCHAR2)
        AS
        BEGIN
                IF g_log_lvl <= 6 THEN
                        cln_debug_pub.add('Unexpected error occured in - ' || a_proc,6);
                        cln_debug_pub.add('Exception - ' || SQLCODE || ' - ' || SQLERRM,6);
                END IF;

                FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_UNEXP_ERR');
                FND_MESSAGE.SET_TOKEN('API',a_proc);
                FND_MESSAGE.SET_TOKEN('ERR',SQLCODE||'-'||SQLERRM);
                FND_MESSAGE.SET_TOKEN('ACTION',a_actn);
                x_ret_msg := FND_MESSAGE.GET;
                x_ret_sts := g_unexp_err_code;

        EXCEPTION
                WHEN OTHERS THEN
                        x_ret_sts := g_unexp_err_code;
                        x_ret_msg := a_actn;
        END handle_exception;

        -- Helper procedure logs generated XML
        -- Create .txt file containing XML fragment
        -- File is created in CLN_DEBUG_LOG_DIRECTORY
        -- Returns failure on exception
        PROCEDURE log_xml(a_xml        IN         VARCHAR2,
                          x_ret_sts    OUT NOCOPY VARCHAR2,
                          x_ret_msg    OUT NOCOPY VARCHAR2)
        IS
                l_buff          VARCHAR2(400);
                l_lin_len       NUMBER;
                l_xml           VARCHAR2(32767);
                l_file_ptr      utl_file.file_type;
                l_log_fil       VARCHAR2(100);
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Log generated XML';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.log_xml',2);
                END IF;


                -- obtains logfile name
                SELECT substr('M4UXGEN-' ||  to_char(sysdate,'dd-mon-yyyy') || '-' || lpad(cln_debug_s.nextval,8,'0'),1,28)
                INTO    l_log_fil
                FROM    dual;
                l_log_fil       := l_log_fil || '.txt';


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('l_log_fil - ' || l_log_fil,1);
                        cln_debug_pub.add('g_log_dir - ' || g_log_dir,1);
                END IF;

                -- obtain UTL file for logging
                l_file_ptr := utl_file.fopen(g_log_dir, l_log_fil, 'a');

                -- break XML into pieces of 80 and write to log file
                l_xml   := a_xml;
                IF a_xml is NULL THEN
                        l_xml := '<M4U>Empty or NULL XML generated</M4U>';
                END IF;
                l_lin_len := 80;
                l_buff  := NULL;

                WHILE LENGTH(l_xml) >= 1 LOOP
                        l_buff  :=      SUBSTR(l_xml,1,l_lin_len);
                        l_xml   :=      SUBSTR(l_xml,l_lin_len+1);
                        utl_file.put_line(l_file_ptr,l_buff);
                        utl_file.fflush(l_file_ptr);
                END LOOP;

                -- Done, close the log file
                utl_file.fclose(l_file_ptr);
                -- Return success
                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.log_xml - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.log_xml',
                                                x_ret_sts,x_ret_msg);
        END;

        /*FUNCTIONS/PROCEDURES DEFINED BELOW ARE USED IN XML VALIDATION */

        -- Procuedure for DTD validation
        -- Not tested!
        -- Validates DTD using xmldom return success or error information
        PROCEDURE dtd_validation(a_xml       IN         VARCHAR2,
                                 x_ret_sts   OUT NOCOPY VARCHAR2,
                                 x_ret_msg   OUT NOCOPY VARCHAR2)
        IS
                l_parser xmlparser.Parser;
                l_doc_typ xmldom.domdocumenttype;
                l_progress VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.dtd_validation',2);
                END IF;

                l_progress := 'XML DTD validation';

                BEGIN
                        -- Obtain XML parser instance
                        l_parser := xmlparser.newparser;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.parser instance obtained',1);
                        END IF;

                        -- Set parser base directory for resolving external entities
                        xmlparser.setBaseDIR(l_parser,g_hdr_rec.dtd_base_dir);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.setBaseURL successful',1);
                        END IF;

                        -- Parse DTD document
                        xmlparser.parseDTD(l_parser,g_hdr_rec.dtd_schma_loc,g_hdr_rec.xml_root_node);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.parseDTD successful',1);
                        END IF;

                        -- Get the DTD as a xmldom.domdocumenttype instance
                        l_doc_typ := xmlparser.getDoctype(l_parser);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.getDoctype successful',1);
                        END IF;

                        -- Set parser to DTD validation mode
                        xmlparser.setValidationMode(l_parser,true);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.setValidationMode successful',1);
                        END IF;

                        -- Set Doc type to parsed DTD
                        xmlparser.setDoctype(l_parser,l_doc_typ);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.setDoctype successful',1);
                        END IF;

                        -- Parse input XML and validate against DTD
                        xmlparser.parseBuffer(l_parser,a_xml);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.parseBuffer successful',1);
                        END IF;

                        -- No exeception means validation is successful
                        -- Exit with success code
                        xmlparser.freeParser(l_parser);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.freeParser successful',1);
                        END IF;

                        x_ret_sts := g_success_code;
                        x_ret_msg := NULL;


                EXCEPTION
                        WHEN OTHERS THEN
                                -- Exception has occured during DTD validation
                                -- Create translatable user message
                                -- Embed DTD error within
                                FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_VALDTN_ERR');
                                FND_MESSAGE.SET_TOKEN('VALIDATION_TYPE','DTD');
                                FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
                                FND_MESSAGE.SET_TOKEN('ERRMESG',SQLERRM);

                                -- return failure and DTD errors
                                x_ret_msg := FND_MESSAGE.GET;
                                x_ret_sts := g_err_code;

                END;

                -- Done parsing, return results
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.dtd_validation - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.dtd_validation',
                                                x_ret_sts,x_ret_msg);
        END dtd_validation;

        -- Java procedure call for Schema Validation
        -- Note this requires APPS schema to have 9.0.4 XDK version or above.
        FUNCTION java_schema_validate(a_xml IN VARCHAR2, a_xsd_file IN VARCHAR2)
        RETURN VARCHAR2
        IS LANGUAGE JAVA NAME 'oracle.apps.cln.m4u.SchemaUtil.validation(oracle.sql.CHAR,oracle.sql.CHAR) returns java.lang.String';

        -- Procedure for Schema Validation
        -- Makes Java API call top SchemaUtil.validation
        -- Requires XDK 9.0.4 version or above to be installed in APPS schema
        PROCEDURE schema_validation(a_xml       IN  VARCHAR2,
                                    x_ret_sts   OUT NOCOPY VARCHAR2,
                                    x_ret_msg   OUT NOCOPY VARCHAR2)
        IS
                l_ret_msg VARCHAR2(4000);
                l_progress VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.schema_validation',2);
                END IF;

                l_progress := 'XML XSD validation';

                -- make call to Java API to validate XML
                l_ret_msg := java_schema_validate(a_xml,g_hdr_rec.dtd_schma_loc);

                -- Return=success, return success
                IF l_ret_msg = 'SUCCESS' THEN
                        x_ret_msg := NULL;
                        x_ret_sts := g_success_code;
                ELSE
                        -- Return=failure, return translatable user message
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_VALDTN_ERR');
                        FND_MESSAGE.SET_TOKEN('VALIDATION_TYPE','XSD');
                        FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
                        FND_MESSAGE.SET_TOKEN('ERRMESG',SQLERRM);

                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;

                END IF;
                -- Done, bye
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.schema_validation - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.schema_validation',
                                                x_ret_sts,x_ret_msg);
        END schema_validation;

        -- Checks if fragment produced is a "Well-formed"XML document
        -- Creates DOM instance and returns any error
        -- No "validation" performed
        PROCEDURE no_validation(a_xml       IN         VARCHAR2,
                                x_ret_sts   OUT NOCOPY VARCHAR2,
                                x_ret_msg   OUT NOCOPY VARCHAR2)
        IS
                l_parser xmlparser.Parser;
                l_progress VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.no_validation',2);
                END IF;

                l_progress := 'XML well-formedness check';

                BEGIN

                        --Obtain parser instance
                        l_parser := xmlparser.newparser;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.parser instance obtained',1);
                        END IF;

                        -- Parse XML buffer
                        xmlparser.parseBuffer(l_parser,a_xml);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.parseBuffer successful',1);
                        END IF;

                        -- Free parser
                        xmlparser.freeParser(l_parser);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('xmlparser.freeParser successful',1);
                        END IF;

                        -- set retcode to success
                        x_ret_sts := g_success_code;
                        x_ret_msg := NULL;

                EXCEPTION
                        WHEN OTHERS THEN
                                -- creates and return translatable error
                                FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_VALDTN_ERR');
                                FND_MESSAGE.SET_TOKEN('VALIDATION_TYPE','NONE');
                                FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
                                FND_MESSAGE.SET_TOKEN('ERRMESG',SQLERRM);

                                x_ret_msg := FND_MESSAGE.GET;
                                x_ret_sts := g_err_code;
                END;

                -- Done, bye
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.no_validation - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.no_validation',
                                                x_ret_sts,x_ret_msg);
        END no_validation;


        -- Generic validation procedure
        -- XSD validation - Requires XDK .9.0.4 in APPS schema
        -- DTD validation - Not tested
        -- Defaulting validation to NONE for current release
        PROCEDURE validate(
                a_xml                   IN          VARCHAR2,
                x_valdtn_sts            OUT NOCOPY  VARCHAR2,
                x_valdtn_msg            OUT NOCOPY  VARCHAR2,
                x_api_ret_sts           OUT NOCOPY  VARCHAR2,
                x_api_ret_msg           OUT NOCOPY  VARCHAR2)
        AS
                l_progress VARCHAR2(4000);
        BEGIN

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.validate',2);
                        cln_debug_pub.add('g_hdr_rec.valdtn_typ - ' || g_hdr_rec.valdtn_typ,2);
                END IF;

                -- Default to NONE.
                g_hdr_rec.valdtn_typ := c_valdtn_none;
                l_progress := 'XML validation';

                x_valdtn_msg    := NULL;
                x_valdtn_sts    := g_success_code;
                x_api_ret_sts   := g_success_code;
                x_api_ret_msg   := NULL;

                -- Based on validation type call required procedure
                -- x_valdtn_sts contains validation status
                -- x_valdtn_msg contains validation error
                -- x_api_ret_msg contains other errors in procedure
                IF g_hdr_rec.valdtn_typ = c_valdtn_dtd THEN

                        dtd_validation(a_xml,x_valdtn_sts,x_valdtn_msg);
                ELSIF g_hdr_rec.valdtn_typ = c_valdtn_xsd THEN

                        schema_validation(a_xml,x_valdtn_sts,x_valdtn_msg);
                ELSIF g_hdr_rec.valdtn_typ = c_valdtn_none THEN

                        no_validation(a_xml,x_valdtn_sts,x_valdtn_msg);
                ELSE
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                        FND_MESSAGE.SET_TOKEN('PARAM','M4U_XML_EXTENSIONS.VALIDATION_TYPE');
                        FND_MESSAGE.SET_TOKEN('VALUE',g_hdr_rec.valdtn_typ);
                        x_api_ret_msg := FND_MESSAGE.GET;
                END IF;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.validate - Normal',2);
                        cln_debug_pub.add('x_api_ret_msg    - ' || x_api_ret_msg,1);
                        cln_debug_pub.add('x_api_ret_sts    - ' || x_api_ret_sts,1);
                        cln_debug_pub.add('x_valdtn_ret_msg - ' || x_valdtn_msg,1);
                        cln_debug_pub.add('x_valdtn_ret_sts - ' || x_valdtn_sts,1);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.validate',
                                                x_api_ret_sts,x_api_ret_msg);
        END validate;


        /*FUNCTIONS/PROCEDURES DEFINED BELOW ARE USED IN LOADING MAPPING */
        /*META-DATA INTO MEMORY DATA-STRUCTURES                          */
        -- called by init map, loads header info to memory
        -- if a_dflt_tp = true then look for M4U_DEFAULT_TP if
        -- tp specific mapping is not present
        -- if a_dflt_tp = false then only look for tp specific mapping
        PROCEDURE init_hdr(
                a_extn_name             IN              VARCHAR2,
                a_tp_id                 IN              VARCHAR2,
                a_dflt_tp               IN              BOOLEAN,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2)
        AS
                l_extn_found BOOLEAN;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Load header information';
                -- log inputs
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.init_hdr',2);
                        cln_debug_pub.add('a_extn_name - '  || a_extn_name,2);
                        cln_debug_pub.add('a_tp_id     - '  || a_tp_id,2);
                        IF a_dflt_tp THEN
                                cln_debug_pub.add('a_dflt_tp - '  || 'Y',2);
                        ELSE
                                cln_debug_pub.add('a_dflt_tp - '  || 'N',2);
                        END IF;
                END IF;

                l_extn_found := false;

                BEGIN
                        -- Query mapping for corresponding to trading_partner_id = a_tp_id
                        -- set l_extn_found = true if data is found else false
                        SELECT  UPPER(TRIM(extn_name)), TRIM(trading_partner_id),
                                UPPER(TRIM(validation_type)), dtd_or_schema_location,
                                root_node, base_dir
                        INTO    g_hdr_rec.extn_name, g_hdr_rec.tp_id, g_hdr_rec.valdtn_typ, g_hdr_rec.dtd_schma_loc,
                                g_hdr_rec.xml_root_node, g_hdr_rec.dtd_base_dir
                        FROM    m4u_xml_extensions
                        WHERE   extn_name = a_extn_name
                        AND     trading_partner_id = a_tp_id;
                        l_extn_found := true;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('TP specific mapping found',1);
                        END IF;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                l_extn_found := false;
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('TP specific mapping not-found',1);
                                END IF;
                        END;


                -- If TP defaulting is allowed look for default tp mapping
                IF l_extn_found = false and a_dflt_tp = true THEN
                        BEGIN
                                -- Query mapping for corresponding to M4U_DEFAULT_TP
                                SELECT  UPPER(TRIM(extn_name)), TRIM(trading_partner_id),
                                        UPPER(TRIM(validation_type)), dtd_or_schema_location,
                                        root_node, base_dir
                                INTO    g_hdr_rec.extn_name, g_hdr_rec.tp_id, g_hdr_rec.valdtn_typ, g_hdr_rec.dtd_schma_loc,
                                        g_hdr_rec.xml_root_node, g_hdr_rec.dtd_base_dir
                                FROM    m4u_xml_extensions
                                WHERE   extn_name = a_extn_name
                                        AND     trading_partner_id = 'M4U_DEFAULT_TP';
                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('Default mapping found',1);
                                END IF;
                                l_extn_found := true;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_extn_found := false;
                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('Default mapping not-found',1);
                                        END IF;
                        END;
                END IF;

                -- header information is loaded
                -- return success
                IF l_extn_found THEN
                        x_ret_msg := NULL;
                        x_ret_sts := g_success_code;
                ELSE
                        -- neither tp specific nor default mapping found
                        -- return failue
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_NO_MAP');
                        FND_MESSAGE.SET_TOKEN('EXTN_NAME',a_extn_name);
                        FND_MESSAGE.SET_TOKEN('TP_ID',a_tp_id);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;
                END IF;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.init_hdr - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.init_hdr',
                                                x_ret_sts,x_ret_msg);
        END init_hdr;

        -- Load data from m4u_element_mappings for
        -- given extn, tp_id
        -- store level in g_elmnt_tab index by level-id
        PROCEDURE load_elmnt_mapping(
                        x_ret_sts       OUT NOCOPY VARCHAR2,
                        x_ret_msg       OUT NOCOPY VARCHAR2)
        IS

                l_tmp_rec elmnt_rec_typ;
                CURSOR l_cur_elmnt_map(
                                a_extn_name     IN      VARCHAR2,
                                a_tp_id IN      VARCHAR2)
                IS
                        SELECT  node_id, node_sequence, node_name, UPPER(TRIM(node_type)),
                                level_id, parent_node_id, UPPER(TRIM(mapping_type)),
                                UPPER(TRIM(view_name)), UPPER(TRIM(column_name)), view_level_id,
                                UPPER(TRIM(variable_name)), constant_val
                        FROM    m4u_element_mappings
                        WHERE   extn_name = a_extn_name
                         AND    NVL(trading_partner_id,'@@') = NVL(a_tp_id,'@@')
                         AND    ignore_mapping <> 'Y'
                        ORDER BY  node_sequence ASC;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Loading m4u_element_mappings';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_elmnt_mapping',2);
                END IF;

                OPEN l_cur_elmnt_map(g_hdr_rec.extn_name,g_hdr_rec.tp_id);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('cursor processing begins',1);
                END IF;

                g_elmnt_map.DELETE;
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('deleted g_elmnt_map',1);
                END IF;
                g_elmnt_count := 0;

                LOOP

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('loop> g_elmnt_count - ' || g_elmnt_count,1);
                        END IF;

                        -- read record-by-record and fetch into g_elmnt_map;
                        -- read data into memory
                        FETCH l_cur_elmnt_map
                        INTO    l_tmp_rec.id, l_tmp_rec.seq, l_tmp_rec.name, l_tmp_rec.type,
                                l_tmp_rec.lvl_id, l_tmp_rec.parent_id, l_tmp_rec.map_typ,
                                l_tmp_rec.view_nam, l_tmp_rec.col, l_tmp_rec.view_lvl,
                                l_tmp_rec.var, l_tmp_rec.const;


                        EXIT WHEN l_cur_elmnt_map%NOTFOUND;

                        g_elmnt_count := g_elmnt_count + 1;


                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_tmp_rec.id - ' || l_tmp_rec.id,1);
                        END IF;

                        -- store data by index in order of sequence
                        g_elmnt_map(g_elmnt_count) := l_tmp_rec;
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Assinged record',1);
                        END IF;
                END LOOP;

                --Close open cursor
                CLOSE l_cur_elmnt_map;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Loop end - g_elmnt_count: ' || g_elmnt_count,1);
                END IF;

                -- Error, no mapping found
                IF g_elmnt_count <= 0 THEN
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_NO_MAP');
                        FND_MESSAGE.SET_TOKEN('EXTN_NAME',g_hdr_rec.extn_name);
                        FND_MESSAGE.SET_TOKEN('TP_ID',g_hdr_rec.tp_id);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;
                ELSE
                        x_ret_msg := NULL;
                        x_ret_sts := g_success_code;
                END IF;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_elmnt_mapping - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_elmnt_mapping',
                                                x_ret_sts,x_ret_msg);
        END load_elmnt_mapping;

        -- load level information from db
        -- do static initialization of level information
        -- store level in g_lvl_tab index by level-id
        PROCEDURE load_lvls(x_ret_sts OUT NOCOPY VARCHAR2,
                            x_ret_msg OUT NOCOPY VARCHAR2)
        IS
                l_lvl_id NUMBER;
                l_lvl_rec lvl_rec_typ;
                CURSOR l_cur_lvls(a_extn_name     IN      VARCHAR2,
                                  a_tp_id         IN      VARCHAR2)
                IS
                        SELECT DISTINCT level_id
                        FROM   m4u_element_mappings
                        WHERE  extn_name = a_extn_name
                        AND    NVL(trading_partner_id,'@@') = NVL(a_tp_id,'@@');
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Load XML levels';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_lvls',2);
                END IF;

                g_lvl_rec_tab.delete;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Deleted g_lvl_rec_tab',1);
                END IF;
                -- open curosr
                OPEN l_cur_lvls(g_hdr_rec.extn_name,g_hdr_rec.tp_id);

                LOOP
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('in the loop',1);
                        END IF;

                        FETCH   l_cur_lvls
                        INTO    l_lvl_id;

                        EXIT WHEN l_cur_lvls%NOTFOUND;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_lvl_id - ' || l_lvl_id,1);
                        END IF;

                        -- store level-ids into g_lvl_rec_tab
                        l_lvl_rec.id := l_lvl_id;
                        l_lvl_rec.view_count := 0;
                        l_lvl_rec.rpt_count  := 1;
                        l_lvl_rec.is_mapped  := false;
                        l_lvl_rec.end_tag_stk_ptr:= 0;
                        l_lvl_rec.vals.delete;

                        g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_lvl_id - ' || l_lvl_id ,1);
                        END IF;


                END LOOP;

                -- return success
                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                -- 5299569
                CLOSE l_cur_lvls;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_lvls - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;
                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_lvls',
                                                x_ret_sts,x_ret_msg);
        END load_lvls;

        -- loop through g_lvl_rec_tab
        -- for each level loop load view data
        PROCEDURE load_lvl_views(
                x_ret_sts       OUT NOCOPY VARCHAR2,
                x_ret_msg       OUT NOCOPY VARCHAR2
        )
        IS
                l_lvl_id        NUMBER;
                l_view_rec      view_rec_typ;
                l_lvl_rec       lvl_rec_typ;

                CURSOR l_cur_lvl_id(
                                        a_extn_name     IN      VARCHAR2,
                                        a_tp_id         IN      VARCHAR2)
                IS
                        SELECT  level_id, view_name, where_clause
                        FROM    m4u_level_views
                        WHERE   extn_name = a_extn_name
                                AND     NVL(trading_partner_id,'@@') = NVL(a_tp_id,'@@');
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Load view sequels';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_lvl_views',2);
                END IF;

                -- Fetch views corresponding to each level
                OPEN l_cur_lvl_id(g_hdr_rec.extn_name,g_hdr_rec.tp_id);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Cursor opened',1);
                END IF;


                LOOP

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('in the loop',1);
                        END IF;

                        -- clean l_view_rec
                        l_view_rec.rowcount   := 0;
                        l_view_rec.bind_count := 0;
                        l_view_rec.col_count  := 0;
                        l_view_rec.bind_tab.DELETE;
                        l_view_rec.col_tab.DELETE;

                        --
                        FETCH   l_cur_lvl_id
                        INTO    l_lvl_id, l_view_rec.view_nam, l_view_rec.whr_claus;

                        EXIT WHEN l_cur_lvl_id%NOTFOUND;

                        IF trim(l_view_rec.whr_claus) IS NOT NULL THEN
                                l_view_rec.whr_claus := 'WHERE 1=1 AND '  || l_view_rec.whr_claus;
                        ELSE
                                l_view_rec.whr_claus := 'WHERE 1=1';
                        END IF;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Fectched data',1);
                                cln_debug_pub.add('l_lvl_id                     - ' ||l_lvl_id,1);
                                cln_debug_pub.add('l_view_rec.view_nam  - ' ||l_view_rec.view_nam,1);
                                cln_debug_pub.add('l_view_rec.whr_claus - ' ||l_view_rec.whr_claus,1);
                        END IF;

                        -- load binding corresponding to l_lvl_id, l_view_rec
                        load_bindings(l_lvl_id, l_view_rec,x_ret_sts,x_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('returned from load_bindings',1);
                                cln_debug_pub.add('x_ret_sts    - ' || x_ret_sts,1);
                                cln_debug_pub.add('x_ret_msg    - ' || x_ret_msg,1);
                        END IF;

                        IF NVL(x_ret_sts,'F') <> g_success_code THEN
                                EXIT;
                        END IF;

                        -- load view_cols corresponding to l_lvl_id, l_view_rec
                        load_view_cols(l_lvl_id, l_view_rec,x_ret_sts,x_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('returned from load_view_cols',1);
                                cln_debug_pub.add('x_ret_sts           - ' || x_ret_sts,1);
                                cln_debug_pub.add('x_ret_msg           - ' || x_ret_msg,1);
                                cln_debug_pub.add('l_view_rec.exec_sql - ' || l_view_rec.exec_sql,1);
                        END IF;

                        IF NVL(x_ret_sts,'F') <> g_success_code THEN
                                EXIT;
                        END IF;

                        l_lvl_rec               := g_lvl_rec_tab(l_lvl_id);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Obtained l_lvl_rec',1);
                        END IF;
                        l_lvl_rec.view_tab(l_lvl_rec.view_count+1) := l_view_rec;
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('set view_rec',1);
                        END IF;
                        l_lvl_rec.is_mapped     := true;
                        l_lvl_rec.view_count    := l_lvl_rec.view_count + 1;
                        l_lvl_rec.rpt_count     := 0;
                        g_lvl_rec_tab(l_lvl_id) := l_lvl_rec;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_lvl_rec.id         - ' || l_lvl_rec.id,1);
                                cln_debug_pub.add('l_lvl_rec.view_count - ' || l_lvl_rec.view_count,1);
                        END IF;


                END LOOP;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Closing cursor - ' || l_lvl_rec.view_count,1);
                END IF;

                CLOSE l_cur_lvl_id;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_lvl_views - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_lvl_views',
                                                x_ret_sts,x_ret_msg);
        END load_lvl_views;

        -- load list of columns to be fetched for each view
        -- create exec_sql dynamically
        PROCEDURE load_view_cols(
                                a_lvl_id        IN              NUMBER,
                                x_view_rec      IN OUT NOCOPY   view_rec_typ,
                                x_ret_sts       OUT NOCOPY      VARCHAR2,
                                x_ret_msg       OUT NOCOPY      VARCHAR2)
        IS
                CURSOR l_cur_view_cols(
                                                a_extn_name IN  VARCHAR2,
                                                a_tp_id IN      VARCHAR2,
                                                a_lvl_id        IN      VARCHAR2,
                                                a_view_nam      IN      VARCHAR2
                                                )
                IS
                        SELECT  DISTINCT UPPER(TRIM(column_name)) col
                        FROM    m4u_element_mappings
                        WHERE   extn_name = a_extn_name AND NVL(trading_partner_id,'@@') = a_tp_id
                                AND view_level_id = a_lvl_id AND view_name = a_view_nam
                                AND TRIM(column_name) IS NOT NULL
                        UNION
                        SELECT DISTINCT UPPER(TRIM(source_column)) col
                        FROM    m4u_view_binding
                        WHERE   extn_name = a_extn_name AND NVL(trading_partner_id,'@@') = a_tp_id
                                AND source_level_id = a_lvl_id AND source_view = a_view_nam
                                AND TRIM(source_column) IS NOT NULL;


                l_col_nam       m4u_element_mappings.column_name%TYPE;
                i               NUMBER;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Load columns for view sequels';

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_view_cols',2);
                        cln_debug_pub.add('a_lvl_id            - ' || a_lvl_id,2);
                        cln_debug_pub.add('x_view_rec.view_nam - ' || x_view_rec.view_nam,2);
                END IF;

                OPEN l_cur_view_cols(g_hdr_rec.extn_name,g_hdr_rec.tp_id,a_lvl_id,x_view_rec.view_nam);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Cursor opened',1);
                END IF;

                x_view_rec.col_tab.delete;
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Delete - x_view_rec.col_tab',1);
                END IF;
                -- have minimum of 1 column
                -- create SQL statement while looping through column list
                x_view_rec.col_tab(1) := '1';
                x_view_rec.col_count := 1;
                x_view_rec.exec_sql := 'SELECT 1';

                LOOP

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('in the loop - ' || x_view_rec.col_count,1);
                        END IF;

                        FETCH   l_cur_view_cols
                        INTO    l_col_nam;

                        EXIT WHEN l_cur_view_cols%NOTFOUND;


                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Fectched data',1);
                                cln_debug_pub.add('l_col_nam  - ' ||l_col_nam,1);
                        END IF;


                        x_view_rec.col_count := x_view_rec.col_count+1;
                        x_view_rec.col_tab(x_view_rec.col_count) := l_col_nam;

                        x_view_rec.exec_sql  := x_view_rec.exec_sql || ', ' || l_col_nam;



                END LOOP;

                x_view_rec.exec_sql := x_view_rec.exec_sql || ' FROM ' || x_view_rec.view_nam || ' V';
                x_view_rec.exec_sql := x_view_rec.exec_sql || ' ' || x_view_rec.whr_claus;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('x_view_rec.col_count - '|| x_view_rec.col_count,1);
                        cln_debug_pub.add('x_view_rec.exec_sql  - '|| x_view_rec.exec_sql ,1);
                        cln_debug_pub.add('Closing cursor',1);
                END IF;



                x_ret_msg       := NULL;
                x_ret_sts       := g_success_code;

                CLOSE l_cur_view_cols;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_view_cols - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_view_cols',
                                                x_ret_sts,x_ret_msg);
        END load_view_cols;

        -- load list of bind variable to be supplied for each where clause
        -- load mapping info for each bind variable
        PROCEDURE load_bindings(
                        a_lvl_id        IN              NUMBER,
                        x_view_rec      IN OUT NOCOPY   view_rec_typ,
                        x_ret_sts       OUT NOCOPY      VARCHAR2,
                        x_ret_msg       OUT NOCOPY      VARCHAR2
                )
        IS
                CURSOR l_cur_bindngs(
                                        a_extn_name     IN      VARCHAR2,
                                        a_tp_id         IN      VARCHAR2,
                                        a_lvl_id        IN      NUMBER,
                                        a_view_nam      IN      VARCHAR2)
                IS
                        SELECT          TRIM(bind_variable), UPPER(TRIM(bind_type)),
                                        UPPER(TRIM(source_view)), UPPER(TRIM(source_column)),
                                        UPPER(TRIM(source_var)), source_level_id
                        FROM            m4u_view_binding
                        WHERE           extn_name = a_extn_name
                                AND     NVL(trading_partner_id,'@@') = NVL(a_tp_id,'@@')
                                AND     view_name = a_view_nam
                                AND     level_id  = a_lvl_id;

                l_bind_rec      bind_rec_typ;
                l_progress VARCHAR2(4000);

        BEGIN
                l_progress := 'Load bind-information for view sequels';

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_bindings',2);
                END IF;

                OPEN l_cur_bindngs(g_hdr_rec.extn_name,g_hdr_rec.tp_id,a_lvl_id,x_view_rec.view_nam);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('cursor opened',1);
                END IF;

                x_view_rec.bind_tab.delete;
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('bind_tab deleted',1);
                END IF;

                x_view_rec.bind_count := 0;
                LOOP
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('in the loop - ' || x_view_rec.bind_count,1);
                        END IF;

                        FETCH l_cur_bindngs
                        INTO    l_bind_rec.nam, l_bind_rec.typ, l_bind_rec.src_view, l_bind_rec.src_col,
                                l_bind_rec.src_var, l_bind_rec.src_lvl_id;

                        EXIT WHEN l_cur_bindngs%NOTFOUND;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Fectched data',1);
                                cln_debug_pub.add('l_bind_rec.nam               - ' ||l_bind_rec.nam,1);
                                cln_debug_pub.add('l_bind_rec.typ               - ' ||l_bind_rec.typ,1);
                                cln_debug_pub.add('l_bind_rec.src_view  - ' ||l_bind_rec.src_view,1);
                                cln_debug_pub.add('l_bind_rec.src_col   - ' ||l_bind_rec.src_col,1);
                                cln_debug_pub.add('l_bind_rec.src_var   - ' ||l_bind_rec.src_var,1);
                                cln_debug_pub.add('l_bind_rec.src_lvl_id        - ' ||l_bind_rec.src_lvl_id,1);
                        END IF;

                        x_view_rec.bind_count := x_view_rec.bind_count + 1;

                        x_view_rec.bind_tab(x_view_rec.bind_count) := l_bind_rec;
                END LOOP;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Closing cursor - ' || x_view_rec.bind_count,1);
                END IF;

                CLOSE l_cur_bindngs;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_bindings - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

                RETURN;


        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_bindings',
                                                x_ret_sts,x_ret_msg);
        END load_bindings;

        -- load global variable from input wf_parameter_list_t
        -- into index by VARCHAR2(varname) table
        -- variable names are case-insensitive
        PROCEDURE load_global_var(a_param_lst   IN  wf_parameter_list_t,
                                  x_ret_sts     OUT NOCOPY VARCHAR2,
                                  x_ret_msg     OUT NOCOPY VARCHAR2)
        IS
                i       NUMBER;
                l_nam   VARCHAR2(100);
                l_val   VARCHAR2(4000);
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Read global variable for mapping';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.load_global_var',2);
                END IF;

                -- delete any old-data
                g_glb_var_tab.DELETE;
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Deleted   g_glb_var_tab',1);
                END IF;

                i := 0;
                WHILE i < a_param_lst.count LOOP
                        l_nam := a_param_lst(i+1).getName();
                        l_val := a_param_lst(i+1).getValue();

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('i            - ' || i,1);
                                cln_debug_pub.add('l_nam        - ' || l_nam,1);
                                cln_debug_pub.add('l_val        - ' || l_val,1);
                        END IF;

                        g_glb_var_tab(UPPER(l_nam)) := l_val;

                        i := i+1;
                END LOOP;

                -- return success
                x_ret_msg := NULL;
                x_ret_sts := g_success_code;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.load_global_var - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.load_global_var',
                                                x_ret_sts,x_ret_msg);
        END load_global_var;

        -- init map
        -- 1. load header info from m4u_xml_extensions
        -- 2. element mapping from m4u_element_mappings
        -- 3. level-ids from m4u_element_mappings
        --      4. views for each level
        --         5. columns for each view
        --         6. bind variable and mapping info for each view
        PROCEDURE init_map(a_extn_name  IN              VARCHAR2,
                           a_tp_id      IN              VARCHAR2,
                           a_dflt_tp    IN              BOOLEAN,
                           a_param_list IN              wf_parameter_list_t,
                           a_log_lvl    IN              NUMBER,
                           x_ret_sts    OUT NOCOPY      VARCHAR2,
                           x_ret_msg    OUT NOCOPY      VARCHAR2)

        IS
                l_progress VARCHAR2(2000);
        BEGIN
                -- a_log_lvl is supplied override profile value
                g_log_lvl := NVL(a_log_lvl,g_log_lvl);
                -- log inputs
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.init_map',2);
                        cln_debug_pub.add('a_extn_name  - ' || a_extn_name,2);
                        cln_debug_pub.add('a_tp_id      - ' || a_tp_id,2);
                        IF a_dflt_tp THEN
                                cln_debug_pub.add('a_dflt_tp    - ' || 'Y',2);
                        ELSE
                                cln_debug_pub.add('a_dflt_tp    - ' || 'N',2);
                        END IF;
                END IF;

                l_progress := 'Initialize XML mapping information';

                -- load header data
                init_hdr(a_extn_name,a_tp_id,a_dflt_tp,x_ret_sts,x_ret_msg);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Returned from m4u_xml_extn_utils.init_hdr',1);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts, 1);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg, 1);
                END IF;

                -- load element mapping
                l_progress := 'Read from m4u_element_mappings';
                IF x_ret_sts = g_success_code THEN
                        load_elmnt_mapping(x_ret_sts,x_ret_msg);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from m4u_xml_extn_utils.load_elmnt_mapping',1);
                                cln_debug_pub.add('x_ret_sts - ' || x_ret_sts, 1);
                                cln_debug_pub.add('x_ret_msg - ' || x_ret_msg, 1);
                        END IF;
                END IF;


                -- load level ids, initial g_lvl_rec.tab
                l_progress := 'Load XML levels';
                IF x_ret_sts = g_success_code THEN
                        load_lvls(x_ret_sts,x_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from m4u_xml_extn_utils.load_lvls',1);
                                cln_debug_pub.add('x_ret_sts - ' || x_ret_sts, 1);
                                cln_debug_pub.add('x_ret_msg - ' || x_ret_msg, 1);
                        END IF;
                END IF;


                -- load views for each level
                l_progress := 'Load DB view queries';
                IF x_ret_sts = g_success_code THEN
                        load_lvl_views(x_ret_sts,x_ret_msg);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from m4u_xml_extn_utils.load_lvl_views',1);
                                cln_debug_pub.add('x_ret_sts - ' || x_ret_sts, 1);
                                cln_debug_pub.add('x_ret_msg - ' || x_ret_msg, 1);
                        END IF;
                END IF;

                -- load global vairables from a_param_list
                l_progress := 'Read global variable for mapping';
                IF x_ret_sts = g_success_code THEN
                        load_global_var(a_param_list,x_ret_sts,x_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Returned from m4u_xml_extn_utils.load_global_var',1);
                                cln_debug_pub.add('x_ret_sts - ' || x_ret_sts, 1);
                                cln_debug_pub.add('x_ret_msg - ' || x_ret_msg, 1);
                        END IF;
                END IF;

                -- Done! all mapping information is in-memory
                -- ready to being processing
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.init_map - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.init_map',
                                                x_ret_sts,x_ret_msg);
        END init_map;


        -- Helper procedure used in XML generation
        -- Purpose is to
        -- Find if input level_id is currently stacked on runtime level stack
        --    If yes, lookup level record in g_lvl_tab
        --    If no,  return error_sts and NULL
        FUNCTION find_lvl_stack(a_lvl_id        IN         NUMBER,
                                x_ret_sts       OUT NOCOPY VARCHAR2,
                                x_ret_msg       OUT NOCOPY VARCHAR2)
        RETURN lvl_rec_typ
        IS
                l_idx       NUMBER;
                l_lvl_id    NUMBER;
                l_lvl_rec   m4u_xml_extn_utils.lvl_rec_typ;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Find level on stack - ' || a_lvl_id;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.find_lvl_stack', 2);
                        cln_debug_pub.add('a_lvl_id - ' || a_lvl_id, 2);
                END IF;

                -- start searching the stack from top
                -- g_lvl_stk_ptr points to Top of stack
                l_idx := g_lvl_stk_ptr;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('g_lvl_stk_ptr - ' || g_lvl_stk_ptr,1);
                END IF;

                -- Loop element by element
                WHILE l_idx > 0 LOOP

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_idx - ' || l_idx ,1);
                        END IF;

                        -- get level_id
                        l_lvl_id  := g_lvl_stk(l_idx);
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_lvl_id - ' || l_lvl_id ,1);
                        END IF;

                        -- if lvl_id is same as input level
                        -- lookup level record and return success
                        IF l_lvl_id = a_lvl_id THEN
                                l_lvl_rec := m4u_xml_extn_utils.g_lvl_rec_tab(l_lvl_id);
                                IF g_log_lvl <= 2 THEN
                                        cln_debug_pub.add('Found level rec, exiting',2);
                                END IF;
                                x_ret_sts := g_success_code;
                                x_ret_msg := NULL;
                                RETURN l_lvl_rec;
                        END IF;
                        l_idx := l_idx - 1;
                END LOOP;

                -- Did not find level on the stack
                -- return error an null
                x_ret_sts := g_err_code;
                x_ret_msg := 'Level not found on stack';
                l_lvl_rec := null;


                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('m4u_xml_extn.find_lvl_stack exiting - failure' ,2);
                END IF;

                RETURN l_lvl_rec;
        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.find_lvl_stack',x_ret_sts,x_ret_msg);
                        l_lvl_rec := null;
                        RETURN l_lvl_rec;
        END find_lvl_stack;


        /*FUNCTIONS/PROCEDURES DEFINED BELOW ARE USED IN XML GENERATION*/


        -- Helper procedure to lookup view value
        -- Finds input level on the run-time stack
        -- And looks up view.column data corresponding to current
        -- iteration of the run-time level.
        -- Note, if view returns 5 rows level is iterated 5 times
        FUNCTION lookup_view_value( a_view      IN VARCHAR2 ,
                                    a_col       IN VARCHAR2 ,
                                    a_lvl       IN NUMBER   ,
                                    x_ret_sts   OUT NOCOPY VARCHAR2,
                                    x_ret_msg   OUT NOCOPY VARCHAR2 )
        RETURN VARCHAR2
        IS
                l_tmp_val VARCHAR2(32767);
                l_lvl_rec lvl_rec_typ;
                l_idx     NUMBER;
                l_size    NUMBER;
                l_key     VARCHAR2(100);
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Lookup value returned by ' || a_view || '.' || a_col;
                -- log inputs
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.lookup_view_value',2);
                        cln_debug_pub.add('a_view   - ' || a_view,  2);
                        cln_debug_pub.add('a_col    - ' || a_col,   2);
                        cln_debug_pub.add('a_lvl    - ' || a_lvl,   2);
                END IF;

                -- To fetch view.column data for a level, first find level_record from stack
                -- If level is not found, return failure
                l_lvl_rec:= find_lvl_stack(a_lvl,x_ret_sts,x_ret_msg);
                IF x_ret_sts <> g_success_code THEN
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('find_lvl_stack - returns failure' ,6);
                        END IF;
                        l_tmp_val := null;
                        RETURN l_tmp_val;
                END IF;

                -- key to find values table for corresponding column
                l_key    := a_view || '.' || a_col;
                -- log current level count and key
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('l_lvl_rec.cntr - ' || l_lvl_rec.cntr,1);
                        cln_debug_pub.add('key            - ' || l_key);
                END IF;

                BEGIN
                        l_size := l_lvl_rec.vals(l_key).count;
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_size       - ' || l_size,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF g_log_lvl <= 6 THEN
                                        cln_debug_pub.add('Value table not found for ' || l_key,6);
                                END IF;
                                x_ret_sts := g_err_code;
                                x_ret_msg := NULL;
                                RAISE;
                END;

                -- l_lvl_rec.cntr loops from 0 to l_lvl_rec.rpt_count-1
                -- return data corresding to l_lvl_rec.cntr rec for the view.
                -- if view records coundf < number of repetitions of level
                -- (this is possible when a level has multiple views)
                -- retrive the last record for view
                l_idx := l_lvl_rec.cntr + 1;
                IF l_idx  > l_size   THEN
                        l_idx := l_size;
                END IF;

                -- l_idx is now points to the view record being accessed for data
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('l_idx  - ' || l_idx,1);
                END IF;

                -- if l_idx > 0, then lookup value and return
                -- else return NULL
                IF l_idx > 0 THEN
                        l_tmp_val := l_lvl_rec.vals(l_key)(l_idx);
                ELSE
                        l_tmp_val := NULL;
                END IF;

                -- exit with success
                x_ret_sts   := g_success_code;
                x_ret_msg   := NULL;

                -- log value and return
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn.lookup_view_value - Normal',2);
                        cln_debug_pub.add('ret_val  - ' || substr(l_tmp_val,1,255),     2);
                END IF;

                RETURN l_tmp_val;

        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn_utils.lookup_view_value',x_ret_sts,x_ret_msg);
                        l_tmp_val := null;
                        RETURN l_tmp_val;
        END lookup_view_value;


        -- Helper procedure to pop lvl stack
        -- retunrs l_lvl_id popped from runtime level stack
        FUNCTION pop_lvl_stack( x_ret_sts OUT NOCOPY  VARCHAR2,
                                x_ret_msg OUT NOCOPY  VARCHAR2)
        RETURN NUMBER
        IS
                l_lvl_id        NUMBER;
                l_progress VARCHAR2(4000);
        BEGIN

                l_progress := 'Pop level from stack';
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering pop_lvl_stack', 2);
                        cln_debug_pub.add('g_lvl_stk_ptr - ' || g_lvl_stk_ptr, 2);
                END IF;

                -- stack is empty return NULL
                -- else, return TOS and decrement stack
                IF g_lvl_stk_ptr < 0 THEN
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('g_lvl_stk_ptr < 0',1);
                        END IF;
                        l_lvl_id := null;
                ELSE
                        l_lvl_id        := g_lvl_stk(g_lvl_stk_ptr);
                        g_lvl_stk_ptr   := g_lvl_stk_ptr - 1;
                END IF;

                -- Done
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting pop_lvl_stack - Normal', 2);
                        cln_debug_pub.add('l_lvl_id      - ' || l_lvl_id, 2);
                        cln_debug_pub.add('g_lvl_stk_ptr - ' || g_lvl_stk_ptr, 2);
                END IF;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;
                RETURN l_lvl_id;

        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.pop_lvl_stack',x_ret_sts,x_ret_msg);
        END pop_lvl_stack;


        -- Push input level id to top of run-time stack
        PROCEDURE push_lvl_stack(l_lvl_id    IN         NUMBER,
                                 x_ret_sts   OUT NOCOPY VARCHAR2,
                                 x_ret_msg   OUT NOCOPY VARCHAR2)
        IS
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Push level to stack - ' || l_lvl_id;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering push_lvl_stack', 2);
                        cln_debug_pub.add('l_lvl_id       - '|| l_lvl_id,2);
                        cln_debug_pub.add('g_lvl_stk_ptr  - '|| g_lvl_stk_ptr,2);
                END IF;


                g_lvl_stk_ptr := g_lvl_stk_ptr + 1;
                g_lvl_stk(g_lvl_stk_ptr) := l_lvl_id;

                x_ret_sts := g_success_code;
                x_ret_msg := NULL;
                RETURN;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting push_lvl_stack', 2);
                        cln_debug_pub.add('g_lvl_stk_ptr - ' || g_lvl_stk_ptr, 2);
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn.push_lvl_stack',x_ret_sts,x_ret_msg);
        END push_lvl_stack;

        -- Get value for bind-variable
        -- Mapping for bind-variables is from m4u_view_binding
        -- This function is called for each bind variable
        FUNCTION get_bind_value(
                        a_bind_rec      IN            bind_rec_typ,
                        x_ret_sts       OUT NOCOPY    VARCHAR2,
                        x_ret_msg       OUT NOCOPY    VARCHAR2)
        RETURN VARCHAR2 AS
                l_tmp_val VARCHAR2(32767);
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Fetch value of bind-variable - ' || a_bind_rec.nam;
                -- Log input api parameters
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn.get_bind_value',2);
                        cln_debug_pub.add('a_bind_rec.nam  - ' || a_bind_rec.nam,2);
                        cln_debug_pub.add('a_bind_rec.typ  - ' || a_bind_rec.typ,2);
                END IF;

                l_tmp_val := NULL;

                -- conditional processing based on  a_bind_rec.typ
                IF a_bind_rec.typ = m4u_xml_extn_utils.c_maptyp_var THEN

                        -- Lookup global variable table
                        -- if global variable table does not contain
                        -- the required var, return error, message
                        BEGIN
                                l_tmp_val := g_glb_var_tab(a_bind_rec.src_var);
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                                        FND_MESSAGE.SET_TOKEN('PARAM','Global variable');
                                        FND_MESSAGE.SET_TOKEN('VALUE',a_bind_rec.src_var);
                                        x_ret_msg := FND_MESSAGE.GET;
                                        x_ret_sts := g_err_code;
                                        IF g_log_lvl <= 1 THEN
                                                cln_debug_pub.add('Fetch global variable error',1);
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;

                ELSIF a_bind_rec.typ = m4u_xml_extn_utils.c_maptyp_view THEN
                        -- make call  to lookup view value
                        -- pass mapping info to m4u_xml_extn_utils.lookup_view_value
                        -- if error, bailout
                        l_tmp_val := m4u_xml_extn_utils.lookup_view_value
                                        (a_bind_rec.src_view,a_bind_rec.src_col,
                                        a_bind_rec.src_lvl_id,x_ret_sts, x_ret_msg);

                        IF x_ret_sts <> g_success_code THEN
                                IF g_log_lvl <= 6 THEN
                                        cln_debug_pub.add('lookup_view_value returns error',6);
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                ELSE
                        -- Bad data, only mapping types supported are
                        -- view and variables
                        -- Constants can be directly used in sequels
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('Mapping type not-found',6);
                        END IF;
                        FND_MESSAGE.SET_NAME('CLN','M4U_XFWK_INV_PARAM');
                        FND_MESSAGE.SET_TOKEN('PARAM','Bind-variable mapping type');
                        FND_MESSAGE.SET_TOKEN('VALUE',a_bind_rec.typ);
                        x_ret_msg := FND_MESSAGE.GET;
                        x_ret_sts := g_err_code;
                        RAISE FND_API.G_EXC_ERROR;

                END IF;

                x_ret_sts       := g_success_code;
                x_ret_msg       := NULL;
                -- exit success
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.get_bind_value - Normal',2);
                        cln_debug_pub.add('ret_val  - ' || substr(l_tmp_val,1,255), 2);
                END IF;

                RETURN l_tmp_val;
        EXCEPTION
                -- return error information present in x_ret_msg
                WHEN FND_API.G_EXC_ERROR THEN
                        IF g_log_lvl <= 6 THEN
                                cln_debug_pub.add('Exiting m4u_xml_extn_utils.get_bind_value - Error',6);
                                cln_debug_pub.add('x_ret_msg        - ' || x_ret_msg,6);
                        END IF;
                        x_ret_sts := g_err_code;
                        l_tmp_val := null;
                        RETURN l_tmp_val;
                -- unknow error has occured, created unknow message and return
                WHEN OTHERS THEN
                        m4u_xml_extn_utils.handle_exception(SQLCODE,SQLERRM,l_progress,
                        'm4u_xml_extn_utils.get_bind_value',x_ret_sts,x_ret_msg);
                        l_tmp_val := null;
                        RETURN l_tmp_val;
        END get_bind_value;

        -- fetch view data
        -- this function fetches view data corresponding to a view_rec
        -- and stores into in the lvl_rec
        -- lvl_rec.vals contains data, indexed by (view.col)(rownum)
        PROCEDURE fetch_data(a_view_rec IN OUT NOCOPY   view_rec_typ,
                             a_lvl_rec  IN OUT NOCOPY   lvl_rec_typ,
                             x_ret_sts  OUT NOCOPY      VARCHAR2,
                             x_ret_msg  OUT NOCOPY      VARCHAR2)
        IS
                l_cursor        NUMBER;
                l_bind_val      VARCHAR2(4000);
                l_idx           NUMBER;
                l_bind_rec      bind_rec_typ;
                l_key           VARCHAR2(100);
                l_discard       NUMBER;
                l_tmp_var       VARCHAR2(4000);
                l_rowcount      NUMBER;
                l_vals          g_vals_typ;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Fetch rows for view - ' || a_view_rec.view_nam;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.fetch_data',2);
                        cln_debug_pub.add('a_view_rec.view_nam  - ' || a_view_rec.view_nam,2);
                END IF;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('a_view_rec.exec_sql - ' || a_view_rec.exec_sql,1);
                END IF;

                -- create dbms_sql cursor
                l_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(l_cursor,a_view_rec.exec_sql,dbms_sql.NATIVE);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('a_view_rec.bind_count ' || a_view_rec.bind_count,1);
                END IF;

                l_idx := 1;
                -- loop through list of bind variables for each view
                WHILE l_idx <= a_view_rec.bind_count LOOP
                        -- for a bind record
                        l_bind_rec   := a_view_rec.bind_tab(l_idx);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_bind_rec.nam - ' || l_bind_rec.nam,1);
                        END IF;
                        -- fetch the bind value
                        l_bind_val := get_bind_value(l_bind_rec,x_ret_sts,x_ret_msg);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('get_bind_value x_ret_sts - ' || x_ret_sts,1);
                        END IF;
                        IF x_ret_sts <> g_success_code THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        -- bind it to the sql
                        dbms_sql.bind_variable(l_cursor,l_bind_rec.nam,l_bind_val);

                        l_idx := l_idx + 1;
                END LOOP;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('a_view_rec.col_count - ' || a_view_rec.col_count,1);
                END IF;


                l_idx := 1;
                l_vals.delete;
                WHILE l_idx <= a_view_rec.col_count LOOP

                        -- key for data-lookup = view.column
                        l_key := a_view_rec.view_nam || '.'|| a_view_rec.col_tab(l_idx);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('define array l_key - ' || l_key,1);
                        END IF;
                        -- initialize storage for each view.colunm
                        a_lvl_rec.vals(l_key) := l_vals;

                        -- define column in cursor
                        dbms_sql.define_column(l_cursor,l_idx,l_tmp_var,4000);
                        l_idx := l_idx + 1;
                END LOOP;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('dbms_sql.define_column: done ',1);
                END IF;

                l_discard := dbms_sql.execute(l_cursor);

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Executed cursor',1);
                END IF;

                l_rowcount := 0;
                LOOP
                        l_discard := dbms_sql.fetch_rows(l_cursor);

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('l_discard  - ' || l_discard,1);
                                cln_debug_pub.add('l_rowcount - ' || l_rowcount,1);
                        END IF;

                        IF l_discard = 0 THEN
                                EXIT;
                        END IF;
                        l_rowcount := l_rowcount + 1;
                        l_idx := 1;
                        WHILE l_idx <= a_view_rec.col_count LOOP

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_idx  - ' || l_idx,1);
                                END IF;

                                l_key := a_view_rec.view_nam || '.'|| a_view_rec.col_tab(l_idx);

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('l_key  - ' || l_key,1);
                                END IF;

                                dbms_sql.column_value(l_cursor,l_idx,l_tmp_var);

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('column_value - ' || substr(l_tmp_var,1,255),1);
                                END IF;

                                -- store data into the level record
                                -- a_lvl_rec.vals(l_key) has been initialized in prev loop
                                a_lvl_rec.vals(l_key)(l_rowcount) := l_tmp_var;

                                l_idx := l_idx + 1;
                        END LOOP;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Rows fectched - ' || l_rowcount,1);
                        END IF;
                END LOOP;

                a_view_rec.rowcount := l_rowcount;


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Fetching view data complete ',1);
                        cln_debug_pub.add('a_lvl_rec.rpt_count - ' || a_lvl_rec.rpt_count);
                END IF;

                -- 5299569
                dbms_sql.close_cursor(l_cursor);
                -- this makes sense when there are mutliple views for a level
                -- level to repeat itself based on view with max records
                IF a_lvl_rec.rpt_count < a_view_rec.rowcount THEN
                        a_lvl_rec.rpt_count := a_view_rec.rowcount;
                END IF;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('a_lvl_rec.rpt_count - ' || a_lvl_rec.rpt_count);
                END IF;

                -- no execptions, succcess!
                x_ret_sts := g_success_code;
                x_ret_msg := NULL;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.fetch_data - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                        cln_debug_pub.add('a_view_rec.rowcount - ' || a_view_rec.rowcount,2);
                END IF;
                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.fetch_data',
                                                x_ret_sts,x_ret_msg);
        END fetch_data;



        -- Initializes level before placing on run-time stack
        -- execute view queried and load data into vals
        -- level level cnt to zero and rpt_count to max(view count)
        -- initialize level end-tag-stack
        -- level has no associated views, then set rpt_count = 1 and view_count=0
        -- (redundant since we already do that while loading level)
        PROCEDURE init_level(a_lvl_id        IN              VARCHAR2,
                             x_lvl_rec       OUT NOCOPY      lvl_rec_typ,
                             x_ret_sts       OUT NOCOPY      VARCHAR2,
                             x_ret_msg       OUT NOCOPY      VARCHAR2)
        IS
                l_lvl_rec       lvl_rec_typ;
                l_cntr          NUMBER;
                l_view_rec      view_rec_typ;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Initialize level - ' || a_lvl_id;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.init_level',2);
                        cln_debug_pub.add('a_lvl_id  - ' || a_lvl_id ,2);
                END IF;

                x_ret_sts := g_success_code;

                --code to initialize level-record
                l_lvl_rec := g_lvl_rec_tab(a_lvl_id);
                l_lvl_rec.cntr              := 0;
                l_lvl_rec.end_tag_stk_ptr   := 0;
                l_lvl_rec.end_tag_stk.delete;


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Cleaned l_lvl_rec.id - ' || l_lvl_rec.id,1);
                END IF;


                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('l_lvl_rec.view_count - ' || l_lvl_rec.view_count,1);
                END IF;

                IF l_lvl_rec.view_count = 0 THEN
                        l_lvl_rec.is_mapped := false;
                        l_lvl_rec.rpt_count := 1;
                ELSE
                        l_cntr     := 1;
                        l_lvl_rec.rpt_count := 0;
                        l_lvl_rec.is_mapped := true;
                        l_lvl_rec.vals.delete;

                        -- loop through each view for the level
                        WHILE l_cntr <= l_lvl_rec.view_count LOOP
                                -- obtain view rec
                                l_view_rec := l_lvl_rec.view_tab(l_cntr);

                                IF g_log_lvl <=1 THEN
                                        cln_debug_pub.add('l_view_rec.view_nam - ' || l_view_rec.view_nam,1);
                                END IF;

                                -- fetch data for view
                                -- l_view_rec contains rowcount for view
                                -- l_level_rec.vals contain data indexed by (view.colum)(rownum)
                                -- rpt count is set to number of times the level repeats
                                fetch_data(l_view_rec,l_lvl_rec,x_ret_sts,x_ret_msg);
                                -- store data back into level record
                                l_lvl_rec.view_tab(l_cntr) := l_view_rec;

                                IF g_log_lvl <= 1 THEN
                                        cln_debug_pub.add('fetch_data x_ret_sts - ' || x_ret_sts,1);
                                        cln_debug_pub.add('fetch_data x_ret_msg - ' || x_ret_msg,1);
                                END IF;
                                -- failure, no point procesing further
                                IF x_ret_sts <> g_success_code THEN
                                        EXIT;
                                END IF;
                                l_cntr := l_cntr + 1;

                        END LOOP;

                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('Exited loop',1);
                        END IF;
                END IF;

                -- store level in table and return it
                g_lvl_rec_tab(a_lvl_id) := l_lvl_rec;
                x_lvl_rec               := l_lvl_rec;

                IF x_ret_sts = g_success_code THEN
                        x_ret_msg := NULL;
                END IF;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.init_level - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;
                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.init_level',
                                                x_ret_sts,x_ret_msg);
        END init_level;

        -- cleans up run-time info of level
        -- this is important
        -- since same level can be brought back onto stack multiple times
        -- so make sure data from previous run of level is not carried
        PROCEDURE un_init_level(a_lvl_id        IN              NUMBER,
                                x_ret_sts       OUT NOCOPY      VARCHAR2,
                                x_ret_msg       OUT NOCOPY      VARCHAR2)
        IS
                l_lvl_rec lvl_rec_typ;
                l_progress VARCHAR2(4000);
        BEGIN
                l_progress := 'Free level - ' || a_lvl_id;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.un_init_level',2);
                        cln_debug_pub.add('a_lvl_id - ' || a_lvl_id,2);
                END IF;

                l_lvl_rec := g_lvl_rec_tab(a_lvl_id);
                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('Obtained level record',1);
                END IF;

                l_lvl_rec.cntr := 0;
                l_lvl_rec.end_tag_stk_ptr := 0;
                l_lvl_rec.end_tag_stk.delete;

                IF g_log_lvl <= 1 THEN
                        cln_debug_pub.add('deleted l_lvl_rec.end_tag_stk',1);
                END IF;


                IF l_lvl_rec.is_mapped THEN
                       l_lvl_rec.rpt_count := 0;
                       l_lvl_rec.vals.delete;
                        IF g_log_lvl <= 1 THEN
                                cln_debug_pub.add('deleted l_lvl_rec.vals',1);
                        END IF;
                END IF;

                -- store changes back into level table
                g_lvl_rec_tab(a_lvl_id) := l_lvl_rec;
                x_ret_sts := g_success_code;
                x_ret_msg := null;
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.un_init_level - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;
                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.un_init_level',
                                         x_ret_sts,x_ret_msg);
        END un_init_level;

        -- cleans up any memory held by map
        PROCEDURE un_init_map(x_ret_sts OUT NOCOPY VARCHAR2,
                              x_ret_msg OUT NOCOPY VARCHAR2)
        IS
                l_progress VARCHAR2(4000);
        BEGIN
                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Entering m4u_xml_extn_utils.un_init_map',2);
                END IF;

                l_progress := 'Un-load mapping information';
                -- dont leave stray variables in session
                -- they may affect the next run
                g_hdr_rec.extn_name     := NULL;
                g_hdr_rec.tp_id         := NULL;
                g_hdr_rec.valdtn_typ    := NULL;
                g_hdr_rec.dtd_schma_loc := NULL;
                g_hdr_rec.dtd_base_dir  := NULL;
                g_hdr_rec.xml_root_node := NULL;
                g_elmnt_count           := 0;
                g_lvl_stk_ptr           := 0;

                -- important! delete all collections
                g_lvl_stk.delete;
                g_elmnt_map.delete;
                g_glb_var_tab.delete;
                g_lvl_rec_tab.delete;

                x_ret_sts := g_success_code;
                x_ret_msg := null;

                IF g_log_lvl <= 2 THEN
                        cln_debug_pub.add('Exiting m4u_xml_extn_utils.un_init_map - Normal',2);
                        cln_debug_pub.add('x_ret_msg - ' || x_ret_msg,2);
                        cln_debug_pub.add('x_ret_sts - ' || x_ret_sts,2);
                END IF;
                RETURN;
        EXCEPTION
                WHEN OTHERS THEN
                        handle_exception(SQLCODE,SQLERRM,l_progress,'m4u_xml_extn_utils.un_init_map',
                                         x_ret_sts,x_ret_msg);
        END un_init_map;


BEGIN
        -- initialize constants, profile dependant values
        g_success_code          := FND_API.G_RET_STS_SUCCESS;
        g_err_code              := FND_API.G_RET_STS_ERROR;
        g_unexp_err_code        := FND_API.G_RET_STS_UNEXP_ERROR;
        g_log_lvl               := NVL(FND_PROFILE.VALUE('CLN_DEBUG_LEVEL'),5);
        g_log_dir               := NVL(FND_PROFILE.VALUE('CLN_DEBUG_LOG_DIRECTORY'),'/tmp');
END m4u_xml_extn_utils;

/
