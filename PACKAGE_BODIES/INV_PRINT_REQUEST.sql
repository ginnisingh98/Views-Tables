--------------------------------------------------------
--  DDL for Package Body INV_PRINT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PRINT_REQUEST" AS
/* $Header: INVPRRQB.pls 120.1 2006/03/02 00:44:24 dchithir noship $ */

PROCEDURE trace(p_message VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
        inv_label.trace(p_message, 'PRINT_REQUEST');
    END IF;
END trace;

PROCEDURE SYNC_PRINT_REQUEST
(
    p_xml_content       IN LONG
,   x_job_status        OUT NOCOPY VARCHAR2
,   x_printer_status    OUT NOCOPY VARCHAR2
,   x_status_type       OUT NOCOPY NUMBER
) IS
BEGIN
    -- Call out to 3rd party print procedures
    INV_SYNC_PRINT_REQUEST.SYNC_PRINT_REQUEST
    (p_xml_content, x_job_status,x_printer_status,x_status_type);
END;

PROCEDURE WRITE_XML
(
    p_xml_content       IN LONG
,   p_request_id        IN NUMBER
,   x_return_status     OUT NOCOPY VARCHAR2
,   x_msg_count         OUT NOCOPY NUMBER
,   x_msg_data          OUT NOCOPY VARCHAR2
) IS
    l_output_dir VARCHAR2(200);
    l_output_file_prefix VARCHAR2(50);
    l_output_file_name  VARCHAR2(50);

    l_file_end CONSTANT VARCHAR2(10) := '.xml';
    l_file_handler UTL_FILE.FILE_TYPE;

    --l_substr VARCHAR2(254);
    --i NUMBER;
    --l_last_index NUMBER;
    --l_cur_index NUMBER;
    l_dir_seperator VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get profile values for output directory
    --      and output file prefix
    FND_PROFILE.GET('WMS_LABEL_OUTPUT_DIRECTORY', l_output_dir);
    IF (l_output_dir IS NULL) OR (trim(l_output_dir) = '') THEN
        IF (l_debug = 1) THEN
            trace(' WMS_LABEL_OUTPUT_DIRECTORY is null, can not write XML file ');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    FND_PROFILE.GET('WMS_LABEL_FILE_PREFIX', l_output_file_prefix);
    IF (l_debug = 1) THEN
        trace(' Profile value obtained, dir='||l_output_dir ||', prefix='|| l_output_file_prefix);
    END IF;

    -- Get the file name = prefix + l_request_id .xml
    l_output_file_name := l_output_file_prefix || p_request_id || l_file_end;

    l_dir_seperator := '/';
    IF(instr(l_output_dir, l_dir_seperator) = 0) THEN
        l_dir_seperator := '\';
    END IF;

    -- Open the file
    l_file_handler := UTL_FILE.fopen(rtrim(l_output_dir,l_dir_seperator), l_output_file_name, 'w');

    -- Write into the file
    /*l_last_index :=1;
    l_cur_index := instr(p_xml_content, '>', l_last_index);

    WHILE l_cur_index <> 0 LOOP
       l_substr := substr(p_xml_content, l_last_index, l_cur_index-l_last_index+1);
       utl_file.put_line(l_file_handler, l_substr);
       l_last_index := l_cur_index + 1;
       IF(substr(p_xml_content, l_last_index+1,1) = 'v') THEN
          l_cur_index := instr(p_xml_content, '>', l_last_index, 2);
       ELSE
          l_cur_index := instr(p_xml_content, '>', l_last_index, 1);
       END IF;
    END LOOP; */

    -- Because of the change that line break will be included in p_xml_content,
    -- can just use one put_line to write all the data into file
    utl_file.put_line(l_file_handler, p_xml_content);
    utl_file.fflush(l_file_handler);
    utl_file.fclose(l_file_handler);
    IF (l_debug = 1) THEN
        trace(length(p_xml_content) ||' characters of xml string writtten into '||l_output_dir||l_dir_seperator||l_output_file_name);
    END IF;

EXCEPTION
    WHEN utl_file.invalid_path THEN
        IF (l_debug = 1) THEN
        trace(' Invalid Path error in '|| G_PKG_NAME||'.write_xml, can not write xml file');
        trace('ERROR CODE = ' || SQLCODE);
        trace('ERROR MESSAGE = ' || SQLERRM);
        END IF;
        utl_file.fclose(l_file_handler);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := SQLERRM;
    WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
         trace(' Expected Error In '|| G_PKG_NAME||'.write_xml');
        trace('ERROR CODE = ' || SQLCODE);
        trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
        utl_file.fclose(l_file_handler);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
         trace(' Unexpected Error In '|| G_PKG_NAME||'.write_xml');
        trace('ERROR CODE = ' || SQLCODE);
        trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
        utl_file.fclose(l_file_handler);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := SQLERRM;
    WHEN others THEN
      IF (l_debug = 1) THEN
         trace(' Other Error In '|| G_PKG_NAME||'.write_xml');
        trace('ERROR CODE = ' || SQLCODE);
        trace('ERROR MESSAGE = ' || SQLERRM);
      END IF;
        utl_file.fclose(l_file_handler);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := SQLERRM;
END WRITE_XML;

PROCEDURE GET_REQUEST_STATUS
(
    p_request_id        IN  NUMBER
,   x_job_status        OUT NOCOPY VARCHAR2
,   x_printer_status    OUT NOCOPY VARCHAR2
,   x_status_type       OUT NOCOPY NUMBER
) IS
BEGIN
    null;
END;



/*
 * Method for sending the label XML file to a TCP-IP address when profile
 * WMS:Label Print Mode is set to Synchronous TCP/IP. The TCP-IP address
 * is derived by first retrieving the printer specified in the XML file,
 * and then doing a lookup for this printer in the Printer-IP table.
 */
PROCEDURE SYNC_PRINT_TCPIP
(
    p_xml_content       IN LONG
,   x_job_status        OUT NOCOPY VARCHAR2
,   x_printer_status    OUT NOCOPY VARCHAR2
,   x_status_type       OUT NOCOPY NUMBER
,   x_return_status     OUT NOCOPY VARCHAR2
,   x_return_msg        OUT NOCOPY VARCHAR2
) IS
    l_printer_name VARCHAR2(50);
    l_ip_address VARCHAR2(50);
    l_port_number NUMBER;
    l_index NUMBER;
    l_ocurrent_count NUMBER;
    l_start_of_printername NUMBER;
    l_end_of_printername NUMBER;

    l_return NUMBER;
    l_return_msg VARCHAR2(2000);
    l_printer_status VARCHAR2(2000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    --Fix for Bug: 5004303.
    l_time  DATE;
    l_delay_time number := NVL(FND_PROFILE.VALUE('WMS_SYNCHRONOUS_TCPIP_LABEL_REQUEST_DELAY'),0);
    --End of fix for 5004303

BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Search for the occurrent of _PRINTERNAME in the p_xml_content
    --  from the end, until found a PRINTERNAME which is not null
    l_printer_name := null;
    l_index := 0;
    l_ocurrent_count := 1;
    LOOP
        l_index := instr(p_xml_content, '_PRINTERNAME',-1,l_ocurrent_count);
        IF l_index = 0 THEN
            IF l_debug = 1 THEN
                trace('End of searching. l_index ='||l_index);
            END IF;
            EXIT;
        END IF;
        -- Get the value of the printername from _PRINTERNAME="XXX"
        -- Find the first and second occurence of " after the start of _PRINTERNAME
        l_start_of_printername := instr(p_xml_content, '"', l_index, 1);
        l_end_of_printername := instr(p_xml_content, '"', l_index, 2);
        IF l_end_of_printername-l_start_of_printername <= 1 THEN
            l_printer_name := null;
        ELSE
            l_printer_name := trim(substr(p_xml_content,l_start_of_printername+1, l_end_of_printername-l_start_of_printername-1));
        END IF;
        IF length(l_printer_name) > 0 THEN
            EXIT;
        END IF;
        l_ocurrent_count := l_ocurrent_count + 1;
    END LOOP;
    IF l_printer_name IS NULL OR length(l_printer_name) = 0 THEN
        IF l_debug = 1 THEN
            trace('Printer name is null, can not process');
        END IF;
        fnd_message.set_name('WSH','WSH_PRINTER_NAME_REQUIRED'); --Printer name is required
        x_return_msg := fnd_message.get();
        raise fnd_api.G_EXC_ERROR;
    END IF;

    IF l_debug = 1 THEN
        trace('Found PRINTER NAME as '||l_printer_name);
    END IF;
    -- Obtain the IP address and port number for the printer
    BEGIN
        SELECT ip_address, port_number
        INTO l_ip_address, l_port_number
        FROM WMS_PRINTER_IP_DEF
        WHERE printer_name = l_printer_name;
    EXCEPTION
        WHEN no_data_found THEN
            IF l_debug = 1 THEN
                trace('Can not find IP address and port number for printer '||l_printer_name);
            END IF;
            fnd_message.set_name('INV','INV_NO_IP_PORT'); -- Invalid Printer, can not find IP address and port number
            fnd_message.set_token('PRINTER',l_printer_name); -- Invalid Printer, can not find IP address and port number
            x_return_msg := fnd_message.get();
            raise fnd_api.G_EXC_ERROR;
        WHEN others THEN
            IF l_debug = 1 THEN
                trace('Other error when getting IP address and port number for printer '||l_printer_name);
            END IF;
            raise fnd_api.G_EXC_UNEXPECTED_ERROR;
    END;
    IF l_debug = 1 THEN
        trace('IP address:'||l_ip_address||', Port number:'||l_port_number);
        trace('Calling SEND_XML_TCPIP ');
    END IF;

    l_return := SEND_XML_TCPIP(
        p_ip_address => l_ip_address
    ,   p_port => to_char(l_port_number)
    ,   p_xml_content => p_xml_content
    ,   x_return_msg => l_return_msg
    ,   x_printer_status => l_printer_status
    );

    IF l_debug = 1 THEN
        trace('Called SEND_XML_TCPIP, l_return='||l_return||', l_return_msg='||l_return_msg||', l_printer_status='||l_printer_status);
        trace('Starting time delay...');
    END IF;

    --Fix for Bug: 5004303
    l_time := SYSDATE + (l_delay_time/(86400000));
    WHILE l_time > SYSDATE LOOP
       NULL;
    END LOOP ;
    --End of fix for 5004303

    IF l_debug = 1 THEN
        trace('After time delay.');
    END IF;

    IF l_return = -1 THEN
        x_return_msg := l_return_msg;
        raise fnd_api.G_EXC_ERROR;
    END IF;

    x_printer_status := l_printer_status;

EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
        IF l_debug = 1 THEN
            trace('Expected Error in SYNC_PRINT_TCPIP');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
        x_return_status := fnd_api.G_RET_STS_ERROR;
    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug = 1 THEN
            trace('Unexpected Error in SYNC_PRINT_TCPIP');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
    WHEN others THEN
        IF l_debug = 1 THEN
            trace('Other Error in SYNC_PRINT_TCPIP');
            trace('ERROR Code ='||SQLCODE);
            trace('ERROR Message='||SQLERRM);
        END IF;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
END SYNC_PRINT_TCPIP;

/*
 * Method for sending a string to a TCP-IP address. Used to send the
 * label-XML file to a print-server. The x_return_msg returns any
 * message send back from this TCP-IP address. This function returns
 * 0 if the file was send successfully. It returns -1 if there was
 * any error.
 */
FUNCTION SEND_XML_TCPIP
(
        p_ip_address            IN  VARCHAR2
,       p_port                  IN  VARCHAR2
,       p_xml_content           IN  VARCHAR2
,       x_return_msg           OUT  NOCOPY VARCHAR2
,       x_printer_status       OUT  NOCOPY VARCHAR2
) RETURN NUMBER
  AS LANGUAGE JAVA NAME 'oracle.apps.inv.labels.server.SyncTCPIP.sendXML(
                     java.lang.String,
                     java.lang.String,
                     java.lang.String,
                     java.lang.String[],
                     java.lang.String[]) return java.lang.Integer';


END INV_PRINT_REQUEST;

/
