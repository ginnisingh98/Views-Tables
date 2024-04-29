--------------------------------------------------------
--  DDL for Package Body INV_LABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL" AS
/* $Header: INVLABPB.pls 120.17.12010000.7 2010/03/05 11:56:03 vpedarla ship $ */

LABELS_B    CONSTANT VARCHAR2(50) := '<labels';
LABELS_E    CONSTANT VARCHAR2(50) := '</labels>'||fnd_global.local_chr(10);
LABEL_B     CONSTANT VARCHAR2(50) := '<label';
LABEL_E     CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B  CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E  CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E       CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
BPA_HEADER_B CONSTANT VARCHAR2(10) := '<bpl>';
BPA_HEADER_E CONSTANT VARCHAR2(10) := '</bpl>';

TRACE_LEVEL CONSTANT NUMBER := 12;
TRACE_PROMPT CONSTANT VARCHAR2(10) := 'LABEL_MAIN';

XML_HEADER1 VARCHAR2(100) := '<?xml version="1.0" encoding="';
XML_HEADER1_2 CONSTANT VARCHAR2(100) := '" standalone="no"?>'||fnd_global.local_chr(10);
XML_HEADER2 CONSTANT VARCHAR2(100) := '<!DOCTYPE labels SYSTEM "label.dtd">'||fnd_global.local_chr(10);

/*-----------------------------------------
 *  PRIVATE API
 *---------------------------------------*/
/*************************
 * Clear global variables
 *************************/
PROCEDURE CLEAR_GLOBALS IS
BEGIN
    INV_LABEL_PVT3.g_lpn_id := -1;
    INV_LABEL_PVT8.clear_carton_count;
END CLEAR_GLOBALS;

/************************************
 * Get numbers between a range
 ************************************/
PROCEDURE GET_NUMBER_BETWEEN_RANGE(
    fm_x_number     IN VARCHAR2
,   to_x_number IN VARCHAR2
,   x_return_status     OUT NOCOPY VARCHAR2
,   x_number_table  OUT NOCOPY serial_tab_type
)  IS

    l_number_table      serial_tab_type;
    l_end_numeric       NUMBER := 0;
    l_numeric_len       NUMBER := 0;
    l_LOOP_END          NUMBER := 0;
    l_number        VARCHAR2(30);
    m               NUMBER := 0;
    l_start_prefix      VARCHAR2(30);
    l_end_prefix        VARCHAR2(30);
    l_start_numeric         NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Determine the start number prefix
    l_start_prefix := rtrim(fm_x_number, '0123456789');

    -- Determine the end serial number prefix
    l_end_prefix := rtrim(to_x_number, '0123456789');

    -- Determine the base start numeric portion
    l_start_numeric := to_number(SUBSTR(fm_x_number, nvl(length(l_start_prefix),0) + 1));

    -- Determine the base end numeric portion
    l_end_numeric := to_number(SUBSTR(to_x_number, nvl(length(l_end_prefix),0) + 1));

    -- Determine length of numeric portion
    l_numeric_len := length(SUBSTR(fm_x_number,nvl(length(l_start_prefix),0) + 1));


    -- First serial number
    m := 1;
    l_number_table(m) := fm_x_number;
    WHILE (l_start_numeric < l_end_numeric)
    LOOP
        l_number := l_start_prefix || lpad('000000000000000000000000000000',l_numeric_len - length(to_char(l_start_numeric + 1)))
        || to_char(l_start_numeric + 1);

        m := m + 1;
        l_number_table(m)  := l_number;
        l_start_numeric := l_start_numeric + 1;
    END LOOP;

    x_number_table := l_number_table;
END GET_NUMBER_BETWEEN_RANGE;

PROCEDURE GET_TYPE_TO_PRINT(
    x_return_status     OUT NOCOPY VARCHAR2
,   x_msg_count     OUT NOCOPY VARCHAR2
,   x_msg_data      OUT NOCOPY VARCHAR2
,   x_types_to_print    OUT NOCOPY label_type_tbl_type
,   p_business_flow     IN NUMBER
,   p_label_type_id     IN NUMBER
,   p_no_of_copies      IN NUMBER
,   p_format_id     IN NUMBER   -- Added for Add Format/Printer project
,   p_printer_name      IN VARCHAR2 -- Added for Add Format/Printer project
)
IS
    CURSOR c_types IS
        SELECT wblt.document_id      label_type_id,
               ml.meaning            label_type_name,
               wblt.level_type_code  level_type_code
                -- Bug 3836484. The following literal is not good for performance
                -- Remove the following since it is only used for trace message
              -- , decode(wblt.level_type_code,10001,'Site',10002,'Application',10003,'Responsibility',10004,'User') level_type_name
        FROM wms_bflow_label_type wblt, mfg_lookups ml
        WHERE wblt.business_flow_code = p_business_flow
        AND   wblt.level_value_id  =
               decode(wblt.level_type_code, 10001,0,10002,FND_GLOBAL.RESP_APPL_ID
        ,10003,FND_GLOBAL.RESP_ID,10004, FND_GLOBAL.USER_ID)
        AND   nvl(wblt.enabled_flag, 'N') = 'Y'
        AND   ml.lookup_type = 'WMS_LABEL_TYPE'
        AND   ml.lookup_code = wblt.document_id
        order by wblt.level_type_code desc;

--Bug 6716623
--Cursor to remove those labels from printing at Cartonization
--which are enabled for both cartonization and pick release business flow.
Cursor sel_lab is
SELECT wblt.document_id      label_type_id,
               ml.meaning            label_type_name,
               wblt.level_type_code  level_type_code
        FROM wms_bflow_label_type wblt, mfg_lookups ml
        WHERE wblt.business_flow_code = 22
        AND   nvl(wblt.enabled_flag, 'N') = 'Y'
        AND   ml.lookup_type = 'WMS_LABEL_TYPE'
        AND   ml.lookup_code = wblt.document_id
MINUS
 SELECT wblt.document_id      label_type_id,
               ml.meaning            label_type_name,
               wblt.level_type_code  level_type_code
        FROM wms_bflow_label_type wblt, mfg_lookups ml
        WHERE wblt.business_flow_code = 42
        AND   nvl(wblt.enabled_flag, 'N') = 'Y'
        AND   ml.lookup_type = 'WMS_LABEL_TYPE'
        AND   ml.lookup_code = wblt.document_id
 ORDER BY level_type_code DESC;    --Added Order By clause for Bug#7214797

    v_type c_types%ROWTYPE;
    l_type sel_lab%ROWTYPE;

    l_count NUMBER := 0;

    l_default_printer VARCHAR2(100);
    l_api_status VARCHAR2(100);
    l_error_message VARCHAR2(1000);

    -- Added for Add Format/Printer project
    l_format_name VARCHAR2(100);

    CURSOR c_type_name(p_label_type_id NUMBER) IS
        SELECT meaning FROM mfg_lookups
        WHERE lookup_type = 'WMS_LABEL_TYPE'
        AND lookup_code = p_label_type_id;

    l_prev_level NUMBER := 0;
    --Bug 4553439. Added the local variable for the organization_id
    l_org_id     NUMBER ;

BEGIN
   IF (l_debug = 1) THEN
      trace(' FND_GLOBAL.USER_ID : '|| FND_GLOBAL.USER_ID, TRACE_PROMPT, TRACE_LEVEL);
   END IF;

   IF (l_debug = 1) THEN
      trace(' In Get_type_to_print,busFlow,lableTypeID,Manualformat,ManualPrinter= '
       ||p_business_flow||','||p_label_type_id||','||p_format_id||','||p_printer_name, TRACE_PROMPT, TRACE_LEVEL);
   END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Bug 4553439. Getting the value of org_id from fnd_profile
    FND_PROFILE.GET('MFG_ORGANIZATION_ID', l_org_id );
    IF(l_debug = 1 ) THEN
      trace('Value of org id from the profile' || l_org_id, TRACE_PROMPT,TRACE_LEVEL);
    END IF;
    --End of fix for Bug 4553439

    -- Start to check if this is a manual print request.
    IF p_label_type_id IS NOT NULL THEN
        -- Manual mode, given label type
        -- Get the label type name..
        OPEN c_type_name(p_label_type_id);
        FETCH c_type_name INTO x_types_to_print(1).label_type;

            IF c_type_name%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    trace(' Invalid label type ID: '|| p_label_type_id ||', no label will be printed' , TRACE_PROMPT, TRACE_LEVEL);
                END IF;
                CLOSE c_type_name;
                RETURN;
            END IF;

            CLOSE c_type_name;

        x_types_to_print(1).label_type_id := p_label_type_id;
      -- fabdi GMO changes
        x_types_to_print(1).business_flow_code := p_business_flow;
--       x_types_to_print(1).business_flow_code := null;
      -- end fabdi GMO changes

        -- Added for Add Format/Printer project
        -- In case of Formats, the Default Format is derived irrespective.
        IF p_format_id IS NOT NULL THEN
        -- This means that the format ID is passed in..
        -- If the format is passed in, the default
            x_types_to_print(1).manual_format_id := p_format_id;
            BEGIN
                SELECT label_format_name INTO l_format_name
                FROM WMS_LABEL_FORMATS
                WHERE label_format_id = p_format_id;
            EXCEPTION
                WHEN others THEN
                    IF (l_debug = 1) THEN
                        trace('Error in getting format name for format ID '||p_format_id,TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
            END;
            x_types_to_print(1).manual_format_name := l_format_name;
        ELSE
            x_types_to_print(1).manual_format_id := null;
            x_types_to_print(1).manual_format_name := null;
        END IF;
        IF (l_debug = 1) THEN
            trace(' Manual format ID '||x_types_to_print(1).manual_format_id||' Name '||x_types_to_print(1).manual_format_name, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Get default format for the label irrespective.
        GET_DEFAULT_FORMAT( p_label_type_id => p_label_type_id,
                    p_label_format => x_types_to_print(1).default_format_name,
                    p_label_format_id => x_types_to_print(1).default_format_id);

        IF (l_debug = 1) THEN
            trace(' Default format '||x_types_to_print(1).default_format_name || ',' || x_types_to_print(1).default_format_id , TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Add printer/Format to Manual Label Printing page.
        -- In case of Printers, the Default Printer is derived only if the printer name passed
        -- in, is NULL;.
        IF p_printer_name IS NOT NULL THEN
        -- This means that the printer name is passed in..
            x_types_to_print(1).manual_printer := p_printer_name;
            x_types_to_print(1).default_printer   := NULL;
        END IF;

        -- Deleted the IF condition around the call to the
        -- WSH_REPORT_PRINTERS_PVT.GET_PRINTER() as part of cleanup since irrespective of
        -- the fact that a default format is  defined or not the printer has to be derived.
        -- The format can also be derived in the individual label API's(INVLAP*B.pls) via
        -- the rules engine anyways. Moreover the default printer is defined based on the
        -- document (label type in this case and not on the format)

        --Get default printer
        IF(l_debug = 1 ) THEN -- For Bug 4553439
           trace('Value of org id before calling printer for manual mode: ' || l_org_id, TRACE_PROMPT,TRACE_LEVEL);
        END IF;

        WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
            p_concurrent_program_id=>p_label_type_id,
            p_organization_id      =>l_org_id,--Bug 4553439. Added the parameter for organization_id
            p_user_id              =>fnd_global.user_id,
            p_responsibility_id    =>fnd_global.resp_id,
            p_application_id       =>fnd_global.resp_appl_id,
            x_printer              =>l_default_printer,
            x_api_status           =>l_api_status,
            x_error_message        =>l_error_message
            );

        IF l_api_status <> 'S' THEN
            IF (l_debug = 1) THEN
                trace(' Error in getting the default printer: '|| l_error_message , TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            l_default_printer := null;
        END IF;

        x_types_to_print(1).default_printer   := l_default_printer;
        x_types_to_print(1).default_no_of_copies := nvl(p_no_of_copies,1);

        IF (l_debug = 1) THEN
        trace(' Found type to print,type id-name,format id-name,Default printer,manualFormat id-name, Manual printer ' , TRACE_PROMPT, TRACE_LEVEL);
        trace('       '||  x_types_to_print(1).label_type_id || ' '
        || x_types_to_print(1).label_type || ' '
        ||x_types_to_print(1).default_format_id || ' '
        ||x_types_to_print(1).default_format_name || ' '
        ||x_types_to_print(1).default_printer
        ||x_types_to_print(1).manual_format_id ||' '
        ||x_types_to_print(1).manual_format_name || ' '
        ||x_types_to_print(1).manual_printer
        , TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Get type is done for given p_label_type_id,
        -- Return
        RETURN;
    END IF;
    -- End to check if this is a manual print request.

    IF (l_debug = 1) THEN
           trace(' Check setup for types to print, start from user level ', TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    -- Start :Giving business flow code, find label type
    -- This is a transaction mode label print request.

     --Start Bug 6715800
   IF p_business_flow = 22 THEN
      OPEN sel_lab;
      FETCH sel_lab INTO l_type;
      IF(l_debug=1) THEN
           trace(' after opening and fetching the values', TRACE_PROMPT, TRACE_LEVEL);
      END IF;
      IF sel_lab%NOTFOUND THEN
         IF(l_debug=1) THEN
            trace(' No types found to print', TRACE_PROMPT, TRACE_LEVEL);
         END IF;
         CLOSE sel_lab;
         RETURN;
      ELSE
       IF(l_debug=1) THEN
           trace(' inside else', TRACE_PROMPT, TRACE_LEVEL);
       END IF;
         l_prev_level := l_type.level_type_code;
         l_count := 0;
         WHILE (sel_lab%FOUND) AND (l_type.level_type_code = l_prev_level)
         LOOP
            l_count := l_count + 1;

            GET_DEFAULT_FORMAT
               (p_label_type_id => l_type.label_type_id,
               p_label_format => x_types_to_print(l_count).default_format_name,
               p_label_format_id => x_types_to_print(l_count).default_format_id );


            IF(l_debug = 1 ) THEN
               trace('Value of org id before calling printer for business flow: ' || l_org_id, TRACE_PROMPT,TRACE_LEVEL);
            END IF ;

            WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
               p_concurrent_program_id=>  l_type.label_type_id,
               p_organization_id      =>l_org_id,--Bug 4553439. Added the parameter for organization_id
               p_user_id              =>fnd_global.user_id,
               p_responsibility_id    =>fnd_global.resp_id,
               p_application_id       =>fnd_global.resp_appl_id,
               x_printer              =>l_default_printer,
               x_api_status           =>l_api_status,
               x_error_message        =>l_error_message
            );

            IF l_api_status <> 'S' THEN
               IF (l_debug = 1) THEN
                  trace(' Error in getting the default printer: '|| l_error_message , TRACE_PROMPT, TRACE_LEVEL);
               END IF;
               l_default_printer := null;
            END IF;

            x_types_to_print(l_count).default_printer   := l_default_printer;
            x_types_to_print(l_count).default_no_of_copies := nvl(p_no_of_copies,1);
            x_types_to_print(l_count).business_flow_code := p_business_flow;
            x_types_to_print(l_count).label_type_id := l_type.label_type_id;
            x_types_to_print(l_count).label_type := l_type.label_type_name;
            IF (l_debug = 1) THEN
               trace(' Found type to print, '||
                  ' type id='|| x_types_to_print(l_count).label_type_id ||
                  ' type name='|| x_types_to_print(l_count).label_type ||
                  ' formatId=' || x_types_to_print(l_count).default_format_id ||
                  ' formatName='||x_types_to_print(l_count).default_format_name||
                  ' printer='||x_types_to_print(l_count).default_printer
                  , TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            l_prev_level := l_type.level_type_code;
            FETCH sel_lab INTO l_type;
         END LOOP;
         CLOSE sel_lab;
      END IF;
   ELSE
   --ENd Bug 6715800
      OPEN c_types;
      FETCH c_types INTO v_type;
      IF c_types%NOTFOUND THEN
      -- No types found
         IF(l_debug=1) THEN
            trace(' No types found to print', TRACE_PROMPT, TRACE_LEVEL);
         END IF;
         CLOSE c_types;
         RETURN;
      ELSE
      -- Found types to print
         l_prev_level := v_type.level_type_code;
         l_count := 0;
         WHILE (c_types%FOUND) AND (v_type.level_type_code = l_prev_level)
         LOOP
            -- Find a type, get attributes
            l_count := l_count + 1;
            -- first get label format
            GET_DEFAULT_FORMAT
               (p_label_type_id => v_type.label_type_id,
               p_label_format => x_types_to_print(l_count).default_format_name,
               p_label_format_id => x_types_to_print(l_count).default_format_id );

            -- Deleted the IF condition around the call to the
            -- WSH_REPORT_PRINTERS_PVT.GET_PRINTER() as part of cleanup since irrespective of
            -- the fact that a default format is  defined or not the printer has to be derived.
            -- The format can also be derived in the individual label API's(INVLAP*B.pls) via
            -- the rules engine anyways. Moreover the default printer is defined based on the
            -- document (label type in this case and not on the format)

            -- Get default printer

            IF(l_debug = 1 ) THEN -- For Bug 4553439
               trace('Value of org id before calling printer for business flow: ' || l_org_id, TRACE_PROMPT,TRACE_LEVEL);
            END IF ;

            WSH_REPORT_PRINTERS_PVT.GET_PRINTER(
               p_concurrent_program_id=>  v_type.label_type_id,
               p_organization_id      =>l_org_id,--Bug 4553439. Added the parameter for organization_id
               p_user_id              =>fnd_global.user_id,
               p_responsibility_id    =>fnd_global.resp_id,
               p_application_id       =>fnd_global.resp_appl_id,
               x_printer              =>l_default_printer,
               x_api_status           =>l_api_status,
               x_error_message        =>l_error_message
               );

            IF l_api_status <> 'S' THEN
               IF (l_debug = 1) THEN
                  trace(' Error in getting the default printer: '|| l_error_message , TRACE_PROMPT, TRACE_LEVEL);
               END IF;
               l_default_printer := null;
            END IF;

            x_types_to_print(l_count).default_printer   := l_default_printer;
            x_types_to_print(l_count).default_no_of_copies := nvl(p_no_of_copies,1);
            x_types_to_print(l_count).business_flow_code := p_business_flow;
            x_types_to_print(l_count).label_type_id := v_type.label_type_id;
            x_types_to_print(l_count).label_type := v_type.label_type_name;
            IF (l_debug = 1) THEN
               trace(' Found type to print, '||
                  ' type id='|| x_types_to_print(l_count).label_type_id ||
                  ' type name='|| x_types_to_print(l_count).label_type ||
                  ' formatId=' || x_types_to_print(l_count).default_format_id ||
                  ' formatName='||x_types_to_print(l_count).default_format_name||
                  ' printer='||x_types_to_print(l_count).default_printer
                  -- Bug 3836484. Remove the following line for performance reason
                  -- ||' setupLevel='||v_type.level_type_name
                  , TRACE_PROMPT, TRACE_LEVEL);
            END IF;


            -- Get next label type
            l_prev_level := v_type.level_type_code;
            FETCH c_types INTO v_type;
         END LOOP;
         CLOSE c_types;
      END IF;
   END IF;
    -- End :Giving business flow code, find label type
END GET_TYPE_TO_PRINT;


PROCEDURE get_variable_data(
    x_variable_content  OUT NOCOPY label_tbl_type
,   x_msg_count     OUT NOCOPY NUMBER
,   x_msg_data      OUT NOCOPY VARCHAR2
,   x_return_status     OUT NOCOPY VARCHAR2
,   p_label_type_info   IN label_type_rec
,   p_transaction_id    IN NUMBER
,   p_input_param       IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,   p_transaction_identifier IN NUMBER
) IS

    l_transaction_id NUMBER;
    x_variable_content_long LONG;
BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_label_type_info.label_type_id = 1 THEN
    BEGIN
           INV_LABEL_PVT1.get_variable_data(
                 x_variable_content       => x_variable_content
                ,x_msg_count              => x_msg_count
                ,x_msg_data               => x_msg_data
                ,x_return_status          => x_return_status
                ,p_label_type_info        => p_label_type_info
                ,p_transaction_id         => p_transaction_id
                ,p_input_param            => p_input_param
                ,p_transaction_identifier => p_transaction_identifier
                );
        IF (l_debug = 1) THEN
        trace('Got variable from type 1, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

   ELSIF p_label_type_info.label_type_id = 2 THEN
    BEGIN
        INV_LABEL_PVT2.get_variable_data(
         x_variable_content       => x_variable_content
        ,x_msg_count          => x_msg_count
        ,x_msg_data       => x_msg_data
        ,x_return_status      => x_return_status
        ,p_label_type_info    => p_label_type_info
        ,p_transaction_id     => p_transaction_id
        ,p_input_param        => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 2, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

   ELSIF p_label_type_info.label_type_id = 3 THEN
    BEGIN
        INV_LABEL_PVT3.get_variable_data(
         x_variable_content       => x_variable_content
        ,x_msg_count          => x_msg_count
        ,x_msg_data       => x_msg_data
        ,x_return_status      => x_return_status
        ,p_label_type_info    => p_label_type_info
        ,p_transaction_id     => p_transaction_id
        ,p_input_param        => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 3, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 4 THEN
    BEGIN
        INV_LABEL_PVT4.get_variable_data(
         x_variable_content       => x_variable_content
        ,x_msg_count          => x_msg_count
        ,x_msg_data       => x_msg_data
        ,x_return_status      => x_return_status
        ,p_label_type_info    => p_label_type_info
        ,p_transaction_id     => p_transaction_id
        ,p_input_param        => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 4, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 5 THEN
    BEGIN
        INV_LABEL_PVT5.get_variable_data(
             x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status        => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 5, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 6 THEN
    BEGIN
        INV_LABEL_PVT6.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 6, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 7 THEN
    BEGIN
        INV_LABEL_PVT7.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 7, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 8 THEN
    BEGIN
        INV_LABEL_PVT8.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 8, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('Error in calling PVT8 get_variable_data, ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 9 THEN
    BEGIN
        INV_LABEL_PVT9.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 9, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 10 THEN
    BEGIN
        INV_LABEL_PVT10.get_variable_data(
                 x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 10, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

   -- fabdi GMO changes start
    ELSIF p_label_type_info.label_type_id in (11,12) THEN
    BEGIN
        INV_LABEL_PVT11.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 11/12, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id IN (13,14) THEN
    BEGIN
        INV_LABEL_PVT13.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 13/14, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSIF p_label_type_info.label_type_id = 15 THEN
    BEGIN
        INV_LABEL_PVT15.get_variable_data(
         x_variable_content     => x_variable_content
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_return_status    => x_return_status
        ,p_label_type_info  => p_label_type_info
        ,p_transaction_id   => p_transaction_id
        ,p_input_param      => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
        trace('Got variable from type 15, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;
    -- FABDI END (GMO changes)...

    -- hjogleka, Bug #6417575, Label Printing Support for WIP Move Transactions (12.1)
    ELSIF p_label_type_info.label_type_id = 16 THEN
    BEGIN
        INV_LABEL_PVT16.get_variable_data(
         x_variable_content       => x_variable_content
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        ,x_return_status          => x_return_status
        ,p_label_type_info        => p_label_type_info
        ,p_transaction_id         => p_transaction_id
        ,p_input_param            => p_input_param
        ,p_transaction_identifier => p_transaction_identifier
        );
        IF (l_debug = 1) THEN
          trace('Got variable from type 16, # of rec: '|| x_variable_content.count(), TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
          trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
          trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END;

    ELSE
        IF (l_debug = 1) THEN
          trace(' Wrong value of label_type_id : '||p_label_type_info.label_type_id , TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END IF;
    IF(x_variable_content.count() = 0) THEN
        IF (l_debug = 1) THEN
          trace('Did not get variable data ', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END IF;
END get_variable_data;


PROCEDURE get_date_time_user IS
    l_date      VARCHAR2(20);
    l_time      VARCHAR2(20);
BEGIN
    -- Get Sysdate in Date/Time
    SELECT to_char(sysdate, G_DATE_FORMAT_MASK), to_char(sysdate, 'HH24:MI:SS')
    INTO l_date, l_time FROM dual;

    -- Set the global variables
    G_DATE := l_date;
    G_TIME := l_time;

    SELECT user_name INTO G_USER
    FROM FND_USER WHERE user_id = fnd_global.user_id;

EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
           trace('Error in get_date_time_user', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END get_date_time_user;

/**************************************************
 * Procedure to check the xml string with
 * XML standards and replace the characters
 * that are not legal according to the XML standard
 * The data for the <variable> .. </variable> is checked
 * and the replacements are
 *   & => &amp;
 *   ' => &apos;
 *   \ => \\
 *   " => \"
 *   < => &lt;
 *   > => &gt;
 **************************************************/
PROCEDURE check_xml(p_xml IN OUT NOCOPY LONG) IS
    l_xml LONG;
    -- Fix for BUG: 4731922. Increased the length of l_substr.
    l_substr VARCHAR2(2000); -- VARCHAR2(254);
    -- End of Fix for BUG: 4731922.
    i NUMBER;
    l_last_index NUMBER;
    l_begin_index NUMBER;
    l_end_index NUMBER;

BEGIN
    --Find the first <vaiable tag
    l_last_index := instr(p_xml, '<variable');
    IF l_last_index = 0 THEN
        -- no variable found, return
        return;
    END IF;

    -- Find the beginning of data
    l_begin_index := instr(p_xml, '>', l_last_index) + 1;
    l_xml := substr(p_xml, 1, l_begin_index -1);
    WHILE l_begin_index <> 0 LOOP
        l_end_index := instr(p_xml, '</variable>', l_begin_index);
        l_substr := substr(p_xml, l_begin_index, l_end_index-l_begin_index);
        -- replace special characters
        l_substr := replace(l_substr, '&', '&'||'amp;');
        l_substr := replace(l_substr, '''', '&' || 'apos;');
        --
        -- @@@ Start of Fix for bug 3551132
        --l_substr := replace(l_substr, '\', '\\');
        l_substr := replace(l_substr, '"', '&' || 'quot;');
        --l_substr := replace(l_substr, '"', '\"');
        -- @@@ End of Fix for bug 3551132
        --
        l_substr := replace(l_substr, '<', '&'||'lt;');
        l_substr := replace(l_substr, '>', '&'||'gt;');

        l_begin_index := instr(p_xml, '<variable', l_end_index);
        IF l_begin_index <> 0 THEN
            l_begin_index := instr(p_xml, '>', l_begin_index) + 1;
            l_xml := l_xml || l_substr || substr(p_xml, l_end_index, l_begin_index-l_end_index);
        ELSE
            l_xml := l_xml || l_substr || substr(p_xml, l_end_index);
        END IF;
    END LOOP;
    p_xml := l_xml ;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
            trace('Error in check_xml, xml unchanged', TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        p_xml := p_xml;
END check_xml;

/***************************************************
 * Function to get the XML encoding
 *  based on the character set at the database level
 * The default encoding is UTF-8 for Unicode 2.0
 ***************************************************/
PROCEDURE get_xml_encoding IS
    l_character_set VARCHAR2(50) := null;
    l_xml_encoding VARCHAR2(50) := null;

BEGIN

    l_character_set := G_CHARACTER_SET;
    l_xml_encoding := G_XML_ENCODING;

    IF (l_debug = 1) THEN
        trace('Current charac set and encoding: '||l_character_set|| ','||l_xml_encoding, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    IF (l_character_set IS NULL) THEN
        -- Get character set
        SELECT value INTO l_character_set
        FROM nls_database_parameters
        WHERE parameter = 'NLS_CHARACTERSET';
        IF SQL%NOTFOUND THEN
            IF (l_debug = 1) THEN
                trace('Error in getting character set', TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            l_character_set := null;
        END IF;
        IF (l_debug = 1) THEN
            trace('Got character set='||l_character_set, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

    END IF;
    G_CHARACTER_SET := l_character_set;

    IF l_character_set IS NULL THEN
        IF (l_debug = 1) THEN
           trace('Character Set is null, return default xml encoding', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        l_xml_encoding := G_DEFAULT_XML_ENCODING;
    ELSIF l_xml_encoding IS NULL THEN
        -- get new xml_encoding
        SELECT tag INTO l_xml_encoding
        FROM FND_LOOKUP_VALUES_VL
        WHERE LOOKUP_TYPE = 'FND_ISO_CHARACTER_SET_MAP'
        AND LOOKUP_CODE = l_character_set;

        IF SQL%NOTFOUND THEN
            IF (l_debug = 1) THEN
                trace('Can not find character set: '||l_character_set, TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            l_xml_encoding := NULL;
        ELSE
            IF (l_debug = 1) THEN
                trace('Found xml encoding: '||l_xml_encoding, TRACE_PROMPT, TRACE_LEVEL);
            END IF;
        END IF;

        IF l_xml_encoding IS NULL THEN
            l_xml_encoding := G_DEFAULT_XML_ENCODING;
        END IF;
        G_XML_ENCODING := l_xml_encoding;

    END IF;

    IF (l_debug = 1) THEN
        trace('New charac set and encoding: '||l_character_set|| ','||l_xml_encoding, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    XML_HEADER1 := '<?xml version="1.0" encoding="' || l_xml_encoding || XML_HEADER1_2;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
            trace('Error in get_xml_encoding, return default UTF-8', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        XML_HEADER1 := '<?xml version="1.0" encoding="' || G_DEFAULT_XML_ENCODING || XML_HEADER1_2;
END get_xml_encoding;

/******************************
 * Get Profile values
 *****************************/
PROCEDURE get_profile_values IS
    l_print_mode VARCHAR2(10);
    l_file_prefix VARCHAR2(100);
    l_output_dir VARCHAR2(200);
    l_date_mask VARCHAR2(100);
BEGIN
    FND_PROFILE.GET('WMS_PRINT_MODE', l_print_mode);
    IF (l_debug = 1) THEN
           trace('l_print_mode => ' || l_print_mode, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    FND_PROFILE.GET('WMS_LABEL_FILE_PREFIX', l_file_prefix);
    IF (l_debug = 1) THEN
           trace('l_file_prefix => ' || l_file_prefix, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    FND_PROFILE.GET('WMS_LABEL_OUTPUT_DIRECTORY', l_output_dir);
    IF (l_debug = 1) THEN
           trace('l_output_dir => ' || l_output_dir, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    FND_PROFILE.GET('ICX_DATE_FORMAT_MASK',l_date_mask);
    IF (l_debug = 1) THEN
           trace('l_date_mask => ' || l_date_mask, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    G_PROFILE_PRINT_MODE := to_number(l_print_mode);
    G_PROFILE_PREFIX := l_file_prefix;
    G_PROFILE_OUT_DIR := l_output_dir;
    G_DATE_FORMAT_MASK := l_date_mask;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
        trace('Error in get_profile_values', TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END get_profile_values;


/***************************************************
 * Update the label content
 * with the new job name, printer name, no of copies
 ***************************************************/
FUNCTION update_label_content(
    p_label_content LONG
,   p_job_name VARCHAR2
,   p_printer_name VARCHAR2
,   p_no_of_copy NUMBER) RETURN LONG IS


    l_index NUMBER;
    l_begin_index NUMBER;
    l_end_index NUMBER;

    l_begin_index_label NUMBER;
    l_end_index_label NUMBER;
    l_begin_index_pq NUMBER;
    l_end_index_pq NUMBER;

    l_label_str VARCHAR2(1000);
    l_new_label_str VARCHAR2(1000);
    l_label_content LONG := '';

BEGIN

    IF (p_job_name IS NULL) AND (p_printer_name IS NULL) AND (p_no_of_copy IS NULL) THEN
        -- no more change needed
        RETURN p_label_content;
    END IF;

    --Find the beginning of JOBNAME
    l_index := instr(p_label_content, 'JOBNAME=');
    IF l_index = 0 THEN
        IF (l_debug = 1) THEN
        trace('Can not find JOBNAME, return', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        RETURN p_label_content;
    END IF;

    --Find the first " and second "
    l_begin_index := instr(p_label_content, '"', l_index, 1);
    l_end_index := instr(p_label_content, '"', l_index, 2);

    IF p_job_name IS NOT NULL THEN
        l_label_content := substr(p_label_content, 1, l_begin_index) || p_job_name;
    ELSE
        l_label_content := substr(p_label_content, 1, l_begin_index)
            || substr(p_label_content, l_begin_index+1, l_end_index-l_begin_index-1);
    END IF;


    IF (p_printer_name IS NULL) AND (p_no_of_copy IS NULL) THEN
            -- no more change needed
            l_label_content := l_label_content || substr(p_label_content, l_end_index);
            RETURN l_label_content;
    END IF;

    --Find <label, starting from l_end_index
    l_begin_index_label := instr(p_label_content, '<label', l_end_index, 1);
    l_end_index_label := instr(p_label_content, '>', l_begin_index_label, 1);
    --Get the string of <label ....., with out the '>'
    l_label_str := substr(p_label_content, l_begin_index_label, l_end_index_label-l_begin_index_label);

    IF p_printer_name IS NOT NULL THEN
    --Find the _PRINTERNAME part
        l_index := instr(l_label_str, 'PRINTERNAME', 1, 1);
        IF l_index = 0 THEN
            l_new_label_str := l_label_str || ' _PRINTERNAME="'||p_printer_name||'"';
        ELSE
            --found printername, replace
            l_begin_index_pq := instr(l_label_str, '"', l_index, 1);
            l_end_index_pq := instr(l_label_str, '"', l_index, 2);
            l_new_label_str := substr(l_label_str, 1, l_begin_index_pq) || p_printer_name
                                ||substr(l_label_str, l_end_index_pq);
        END IF;
        l_label_str := l_new_label_str;
    END IF;

    IF p_no_of_copy IS NOT NULL THEN
        --Find the _PRINTERNAME part
        l_index := instr(l_label_str, 'QUANTITY', 1, 1);
        IF l_index = 0 THEN
            l_new_label_str := l_label_str || ' _QUANTITY="'||p_no_of_copy||'"';
        ELSE
            --found printername, replace
            l_begin_index_pq := instr(l_label_str, '"', l_index, 1);
            l_end_index_pq := instr(l_label_str, '"', l_index, 2);
            l_new_label_str := substr(l_label_str, 1, l_begin_index_pq) || p_no_of_copy
                                ||substr(l_label_str, l_end_index_pq);
        END IF;
        l_label_str := l_new_label_str;
    END IF;

    l_label_content := l_label_content
            || substr(p_label_content, l_end_index, l_begin_index_label-l_end_index)
            || l_label_str
            || substr(p_label_content, l_end_index_label);

    RETURN l_label_content;

EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
           trace('Error in updating label content, return the same', TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        RETURN p_label_content;
END update_label_content;
/*-----------------------------------------
 *  PUBLIC API
 *---------------------------------------*/
PROCEDURE trace(p_message IN VARCHAR2,
                p_prompt IN VARCHAR2,
                p_level IN NUMBER ) IS
BEGIN
      INV_LOG_UTIL.trace(p_message, p_prompt, p_level);

END trace;

/**************************************
 * Get default format for a label type
 **************************************/
PROCEDURE GET_DEFAULT_FORMAT
  (p_label_type_id IN number,
   p_label_format OUT NOCOPY VARCHAR2,
   p_label_format_id OUT NOCOPY NUMBER
   ) IS
BEGIN
        SELECT label_format_id,label_format_name
        INTO p_label_format_id,p_label_format FROM WMS_LABEL_FORMATS
        WHERE document_id = p_label_type_id
        AND default_format_flag = 'Y';
        IF SQL%NOTFOUND THEN
             p_label_format_id := null;
             p_label_format := null;

        END IF;
EXCEPTION
     when no_data_found then
     p_label_format_id := null;
     p_label_format := null;
     when others then
     p_label_format_id := null;
     p_label_format := null;
END GET_DEFAULT_FORMAT;


/*****************************************************
 * API to get the label fields defined for a specific
 * format. This get called from the individual label
 * API's often.
 *****************************************************/
PROCEDURE GET_VARIABLES_FOR_FORMAT(
    x_variables         OUT NOCOPY label_field_variable_tbl_type
,   x_variables_count   OUT NOCOPY NUMBER
,   p_format_id         IN  NUMBER
) IS
    l_is_variable_exist VARCHAR2(1);
BEGIN
    GET_VARIABLES_FOR_FORMAT(
        x_variables => x_variables
    ,   x_variables_count => x_variables_count
    ,   x_is_variable_exist => l_is_variable_exist
    ,   p_format_id => p_format_id
    ,   p_exist_variable_name => null);

END GET_VARIABLES_FOR_FORMAT;
/******************************************************
 * Overloaded procedure GET_VARIABLES_FOR_FORMAT
 * Also it can check whether a given variable is included
 * in the given format
 * p_exist_variable_name has the name of the variable
 *  that will be checked for existence
 * x_is_variable_exist returns whether the given variable exists
 *  possible value is 'Y' or 'N'
 *******************************************************/
PROCEDURE GET_VARIABLES_FOR_FORMAT(
    x_variables         OUT NOCOPY label_field_variable_tbl_type
,   x_variables_count   OUT NOCOPY NUMBER
,   x_is_variable_exist OUT NOCOPY VARCHAR2
,   p_format_id         IN  NUMBER
,   p_exist_variable_name IN VARCHAR2 DEFAULT NULL
) IS

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   1: Included sql_Stmt to cursor c_variable cursor to fetch the 'Custom Query'            |
--   2: Added code in the loop to include sql_stmt also.                                     |

-- R12 RFID PROJECT :  p_exist_variable_name is matched against
--                      v_variables.column_name now
---------------------------------------------------------------------------------------------
    CURSOR c_variable IS
        select wlfv.label_field_id field_id,
               wlfv.field_variable_name variable_name,
               wlf.column_name column_name,
               wlf.sql_stmt
        from wms_label_field_variables wlfv, wms_label_fields_b wlf
        where wlfv.label_field_id = wlf.label_field_id
        and wlfv.label_format_id = p_format_id
        order by wlf.column_name;

    i NUMBER;

BEGIN
    x_is_variable_exist := 'N';
    x_variables_count := 0;
    i := 1;
    FOR v_variables IN c_variable LOOP
        x_variables(i).label_field_id := v_variables.field_id;
        x_variables(i).variable_name  := v_variables.variable_name;
        x_variables(i).column_name    := v_variables.column_name;
        x_variables(i).sql_stmt       := v_variables.sql_stmt;
        i := i+1;
        IF p_exist_variable_name IS NOT NULL AND
           UPPER(v_variables.column_name) = UPPER(p_exist_variable_name) THEN
           x_is_variable_exist := 'Y';
        END IF;
    END LOOP;

    x_variables_count := i - 1 ;

EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
           trace('Error in GET_VARIABLES_FOR_FORMAT', TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END GET_VARIABLES_FOR_FORMAT;

PROCEDURE write_xml_header(label_type_header label_type_rec, p_label_request_id NUMBER) IS
    l_file_prefix VARCHAR2(100);
    l_job_name  VARCHAR2(200);
    l_request_id NUMBER;
BEGIN
    g_xml_header := XML_HEADER1 ||XML_HEADER2|| LABELS_B;
    IF nvl(label_type_header.manual_format_name, label_type_header.default_format_name) IS NOT NULL THEN
        g_xml_header := g_xml_header || ' _FORMAT="' || nvl(label_type_header.manual_format_name, label_type_header.default_format_name) || '"';
    END IF;
    IF label_type_header.default_no_of_copies IS NOT NULL then
        g_xml_header := g_xml_header||' _QUANTITY="'||label_type_header.default_no_of_copies||'"';
    END IF;
    IF nvl(label_type_header.manual_printer,label_type_header.default_printer) IS NOT NULL then
        g_xml_header := g_xml_header||' _PRINTERNAME="'||  nvl(label_type_header.manual_printer,label_type_header.default_printer) ||'"';
    END IF;

    l_request_id := p_label_request_id;

    l_job_name := G_PROFILE_PREFIX || l_request_id;

    IF (l_debug = 1) THEN
    trace('l_request_id:'||l_request_id, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    IF  l_job_name IS NOT NULL THEN
        g_xml_header := g_xml_header||' _JOBNAME="'||l_job_name||'"';
    END IF;
    g_xml_header := g_xml_header||TAG_E;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
           trace('Error in write_xml_header', TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END write_xml_header;


-- This procedure is to write label xml data into LABEL_XML.log
-- This is not used anymore from Patchset I (11.5.9) because
--  the label data will be inserted into WMS_LABEL_REQUESTS_HIST table
PROCEDURE writeIntoFile(xml LONG) IS
   l_dir VARCHAR2(128);
   l_debug_trace NUMBER;
   l_file_name VARCHAR2(100) := 'LABEL_XML.log';
    l_dir_seperator VARCHAR2(1);

    l_length NUMBER;
    l_file UTL_FILE.FILE_TYPE;
    l_substr VARCHAR2(254);
    i NUMBER;
    l_last_index NUMBER;
    l_cur_index NUMBER;

BEGIN
    -- Bug 2449358 : LABELING: LABEL_XML.LOG SHOULD ONLY BE CREATED IF DEBUG IS ON
    -- The fnd_profile.get, gets the value for the
    -- input('INV_DEBUG_TRACE') based on the current fnd_global.user_id.
    -- According to the new design, the LABEL_XML.log will only be generated if the profile option
    -- INV: Debug Trace is set to 'Yes'. Hence the IF clause around the existing code.

    -- Get INV_DEBUG_TRACE profile for the current user.
    fnd_profile.get('INV_DEBUG_TRACE',l_debug_trace);

    --l_debug_trace := fnd_profile.value_specific('INV_DEBUG_TRACE',fnd_global.user_id);
    IF (l_debug = 1) THEN
    trace('INV_DEBUG_TRACE = ' || l_debug_trace, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    IF (l_debug_trace = 1) THEN
    -- l_debug_trace = 1 means 'Yes' and 2 means 'No'

        --Get directory from INV_DEBUG_FILE profile
        fnd_profile.get('INV_DEBUG_FILE',l_dir);
        --l_dir := fnd_profile.value_specific('INV_DEBUG_FILE',fnd_global.user_id);
        IF (l_debug = 1) THEN
        trace('INV_DEBUG_FILE = ' || l_dir, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Seperate the filename from the directory
        l_dir_seperator := '/';
        -- The following IF checks if the directory patch contains a '/'(forward slash) or a
        -- '\' (backward slash). The forward slash is the directory separator for Unix while
        --  the backward slash is for NT.
        -- Bug 2695116 : "instr(l_dir, l_dir_seperator) = 0" means that the directory is an NT
        -- directory. Removed hardcoded instances of '/' and replaced with "l_dir_seperator".
        IF(instr(l_dir, l_dir_seperator) = 0) THEN
            l_dir_seperator := '\';
        END IF;
        l_dir := substr(l_dir, 1, instr(l_dir, l_dir_seperator, -1, 1)-1);

        --Write XML string to file
        l_length := length(xml);
        l_file := UTL_FILE.fopen(rtrim(l_dir,l_dir_seperator), l_file_name, 'a');
        utl_file.put_line(l_file, 'LABEL_XML *** New Session. : '|| To_char(Sysdate, 'DD-MON-YY HH:MI:SS') ||' ***');


        l_last_index :=1;
        l_cur_index := instr(xml, '>', l_last_index);

        WHILE l_cur_index <> 0 LOOP
            l_substr := substr(xml, l_last_index, l_cur_index-l_last_index+1);
            utl_file.put_line(l_file, l_substr);
            l_last_index := l_cur_index + 1;
            IF(substr(xml, l_last_index+1,1) = 'v') THEN
                l_cur_index := instr(xml, '>', l_last_index, 2);
            ELSE
                l_cur_index := instr(xml, '>', l_last_index, 1);
            END IF;
        END LOOP;
        utl_file.fclose(l_file);
    ELSE
        NULL;
    END IF;
EXCEPTION
    WHEN utl_file.invalid_path THEN
        IF (l_debug = 1) THEN
        trace(' Invalid path in ' || G_PKG_NAME||'.WriteIntoFile, can not write into file', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        IF (utl_file.IS_OPEN(l_file)) THEN
            utl_file.fclose(l_file);
        END IF;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
        trace(' Expected Error In '|| G_PKG_NAME||'.WriteIntoFile', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        IF (utl_file.IS_OPEN(l_file)) THEN
            utl_file.fclose(l_file);
        END IF;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
        IF (l_debug = 1) THEN
        trace(' Unexpected Error In '|| G_PKG_NAME||'.WriteIntoFile', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        IF (utl_file.IS_OPEN(l_file)) THEN
            utl_file.fclose(l_file);
        END IF;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

    WHEN others THEN
        IF (l_debug = 1) THEN
        trace(' Other Error In '|| G_PKG_NAME||'.WriteIntoFile', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        IF (utl_file.IS_OPEN(l_file)) THEN
            utl_file.fclose(l_file);
        END IF;
        IF (l_debug = 1) THEN
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

END writeIntoFile;

/*************************************
 * Insert into WMS_LABEL_REQUESTS_HIST
 ************************************/
PROCEDURE insert_history_record(p_history_rec WMS_LABEL_REQUESTS_HIST%ROWTYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO wms_label_requests_hist
    (   label_request_id,
        LABEL_TYPE_ID ,
        LABEL_FORMAT_ID,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        SUBINVENTORY_CODE,
        LOCATOR_ID       ,
        LOT_NUMBER       ,
        REVISION         ,
        SERIAL_NUMBER    ,
        LPN_ID           ,
        SUPPLIER_ID      ,
        SUPPLIER_SITE_ID ,
        SUPPLIER_ITEM_ID ,
        CUSTOMER_ID      ,
        CUSTOMER_SITE_ID ,
        CUSTOMER_ITEM_ID ,
        CUSTOMER_CONTACT_ID ,
        FREIGHT_CODE        ,
        LAST_UPDATE_DATE    ,
        LAST_UPDATED_BY     ,
        CREATION_DATE       ,
        CREATED_BY          ,
        LAST_UPDATE_LOGIN   ,
        REQUEST_ID          ,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID            ,
        PROGRAM_UPDATE_DATE   ,
        ATTRIBUTE_CATEGORY    ,
        ATTRIBUTE1            ,
        ATTRIBUTE2            ,
        ATTRIBUTE3            ,
        ATTRIBUTE4            ,
        ATTRIBUTE5            ,
        ATTRIBUTE6            ,
        ATTRIBUTE7            ,
        ATTRIBUTE8            ,
        ATTRIBUTE9            ,
        ATTRIBUTE10           ,
        ATTRIBUTE11           ,
        ATTRIBUTE12           ,
        ATTRIBUTE13           ,
        ATTRIBUTE14           ,
        ATTRIBUTE15           ,
        PRINTER_NAME         ,
        DELIVERY_ID      ,
        BUSINESS_FLOW_CODE ,
        PACKAGE_ID         ,
        DELIVERY_DETAIL_ID,
        SALES_ORDER_HEADER_ID,
        SALES_ORDER_LINE_ID,
        RULE_ID,
        RULE_WEIGHT,
        STRATEGY_ID,
        LABEL_CONTENT,
        JOB_NAME,
        REQUEST_MODE_CODE,
        REQUEST_DATE,
        REQUEST_USER_ID,
        OUTFILE_NAME,
        OUTFILE_DIRECTORY,
        NO_OF_COPY,
        ENCODING,
        ORIGINAL_REQUEST_ID,
        STATUS_FLAG,
        JOB_STATUS,
        PRINTER_STATUS,
        STATUS_TYPE,
        ERROR_MESSAGE
    )VALUES
    (   p_history_rec.label_request_id,
        p_history_rec.LABEL_TYPE_ID ,
        p_history_rec.LABEL_FORMAT_ID,
        p_history_rec.ORGANIZATION_ID,
        p_history_rec.INVENTORY_ITEM_ID,
        p_history_rec.SUBINVENTORY_CODE,
        p_history_rec.LOCATOR_ID       ,
        p_history_rec.LOT_NUMBER       ,
        p_history_rec.REVISION         ,
        p_history_rec.SERIAL_NUMBER    ,
        p_history_rec.LPN_ID           ,
        p_history_rec.SUPPLIER_ID      ,
        p_history_rec.SUPPLIER_SITE_ID ,
        p_history_rec.SUPPLIER_ITEM_ID ,
        p_history_rec.CUSTOMER_ID      ,
        p_history_rec.CUSTOMER_SITE_ID ,
        p_history_rec.CUSTOMER_ITEM_ID ,
        p_history_rec.CUSTOMER_CONTACT_ID ,
        p_history_rec.FREIGHT_CODE        ,
        p_history_rec.LAST_UPDATE_DATE    ,
        p_history_rec.LAST_UPDATED_BY     ,
        p_history_rec.CREATION_DATE       ,
        p_history_rec.CREATED_BY          ,
        p_history_rec.LAST_UPDATE_LOGIN   ,
        p_history_rec.REQUEST_ID          ,
        p_history_rec.PROGRAM_APPLICATION_ID,
        p_history_rec.PROGRAM_ID            ,
        p_history_rec.PROGRAM_UPDATE_DATE   ,
        p_history_rec.ATTRIBUTE_CATEGORY    ,
        p_history_rec.ATTRIBUTE1            ,
        p_history_rec.ATTRIBUTE2            ,
        p_history_rec.ATTRIBUTE3            ,
        p_history_rec.ATTRIBUTE4            ,
        p_history_rec.ATTRIBUTE5            ,
        p_history_rec.ATTRIBUTE6            ,
        p_history_rec.ATTRIBUTE7            ,
        p_history_rec.ATTRIBUTE8            ,
        p_history_rec.ATTRIBUTE9            ,
        p_history_rec.ATTRIBUTE10           ,
        p_history_rec.ATTRIBUTE11           ,
        p_history_rec.ATTRIBUTE12           ,
        p_history_rec.ATTRIBUTE13           ,
        p_history_rec.ATTRIBUTE14           ,
        p_history_rec.ATTRIBUTE15         ,
        p_history_rec.PRINTER_NAME       ,
        p_history_rec.DELIVERY_ID      ,
        p_history_rec.BUSINESS_FLOW_CODE ,
        p_history_rec.PACKAGE_ID         ,
        p_history_rec.DELIVERY_DETAIL_ID,
        p_history_rec.SALES_ORDER_HEADER_ID,
        p_history_rec.SALES_ORDER_LINE_ID,
        p_history_rec.RULE_ID,
        p_history_rec.RULE_WEIGHT,
        p_history_rec.STRATEGY_ID,
        p_history_rec.LABEL_CONTENT,
        p_history_rec.JOB_NAME,
        p_history_rec.REQUEST_MODE_CODE,
        p_history_rec.REQUEST_DATE,
        p_history_rec.REQUEST_USER_ID,
        p_history_rec.OUTFILE_NAME,
        p_history_rec.OUTFILE_DIRECTORY,
        p_history_rec.NO_OF_COPY,
        p_history_rec.ENCODING,
        p_history_rec.ORIGINAL_REQUEST_ID,
        p_history_rec.STATUS_FLAG,
        p_history_rec.JOB_STATUS,
        p_history_rec.PRINTER_STATUS,
        p_history_rec.STATUS_TYPE,
        p_history_rec.ERROR_MESSAGE
    );

    COMMIT;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
        trace('Error in inserting into WMS_LABEL_REQUESTS_HIST record, Req ID:'|| p_history_rec.label_request_id,TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END insert_history_record;

/************************************
 *  Populate Label Requests History
 ************************************/
PROCEDURE populate_history_record(
          p_label_type_info label_type_rec
        , p_label_content LONG
        , p_label_request_id NUMBER
        , p_status_flag VARCHAR2 DEFAULT 'S'
        , p_error_message VARCHAR2 DEFAULT NULL
) IS

    l_label_req_rec WMS_LABEL_REQUESTS%ROWTYPE;
    CURSOR label_req_rec IS
      SELECT * FROM WMS_LABEL_REQUESTS
      WHERE label_request_id = p_label_request_id;

    l_hist_rec WMS_LABEL_REQUESTS_HIST%ROWTYPE;

    l_job_name VARCHAR2(150) := NULL;

BEGIN
    IF (l_debug = 1) THEN
    trace(' Populate History Record ReqID='||p_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    -- Retrieve WMS_LABEL_REQUESTS record and copy information to history record
    OPEN label_req_rec;
    FETCH label_req_rec INTO l_label_req_rec;
    IF label_req_rec%NOTFOUND THEN
        IF (l_debug = 1) THEN
        trace('Fail to retrieve record from WMS_LABEL_REQUESTS with ID '||p_label_request_id , TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        CLOSE label_req_rec;
        RETURN;
    END IF;
    CLOSE label_req_rec;

    -- Retrieve other information
    l_job_name := G_PROFILE_PREFIX || p_label_request_id;

        l_hist_rec.label_request_id:= l_label_req_rec.label_request_id;
        l_hist_rec.LABEL_TYPE_ID :=l_label_req_rec.DOCUMENT_ID ;
        l_hist_rec.LABEL_FORMAT_ID:=nvl(l_label_req_rec.LABEL_FORMAT_ID, p_label_type_info.default_format_id);
        l_hist_rec.ORGANIZATION_ID:=l_label_req_rec.ORGANIZATION_ID;
        l_hist_rec.INVENTORY_ITEM_ID:=l_label_req_rec.INVENTORY_ITEM_ID;
        l_hist_rec.SUBINVENTORY_CODE:=l_label_req_rec.SUBINVENTORY_CODE;
        l_hist_rec.LOCATOR_ID       :=l_label_req_rec.LOCATOR_ID       ;
        l_hist_rec.LOT_NUMBER       :=l_label_req_rec.LOT_NUMBER       ;
        l_hist_rec.REVISION         :=l_label_req_rec.REVISION         ;
        l_hist_rec.SERIAL_NUMBER    :=l_label_req_rec.SERIAL_NUMBER    ;
        l_hist_rec.LPN_ID           :=l_label_req_rec.LPN_ID           ;
        l_hist_rec.SUPPLIER_ID      :=l_label_req_rec.SUPPLIER_ID      ;
        l_hist_rec.SUPPLIER_SITE_ID :=l_label_req_rec.SUPPLIER_SITE_ID ;
        l_hist_rec.SUPPLIER_ITEM_ID :=l_label_req_rec.SUPPLIER_ITEM_ID ;
        l_hist_rec.CUSTOMER_ID      :=l_label_req_rec.CUSTOMER_ID      ;
        l_hist_rec.CUSTOMER_SITE_ID :=l_label_req_rec.CUSTOMER_SITE_ID ;
        l_hist_rec.CUSTOMER_ITEM_ID :=l_label_req_rec.CUSTOMER_ITEM_ID ;
        l_hist_rec.CUSTOMER_CONTACT_ID :=l_label_req_rec.CUSTOMER_CONTACT_ID ;
        l_hist_rec.FREIGHT_CODE        :=l_label_req_rec.FREIGHT_CODE        ;
        l_hist_rec.LAST_UPDATE_DATE    :=l_label_req_rec.LAST_UPDATE_DATE    ;
        l_hist_rec.LAST_UPDATED_BY     :=l_label_req_rec.LAST_UPDATED_BY     ;
        l_hist_rec.CREATION_DATE       :=l_label_req_rec.CREATION_DATE       ;
        l_hist_rec.CREATED_BY          :=l_label_req_rec.CREATED_BY          ;
        l_hist_rec.LAST_UPDATE_LOGIN   :=l_label_req_rec.LAST_UPDATE_LOGIN   ;
        l_hist_rec.REQUEST_ID          :=l_label_req_rec.REQUEST_ID          ;
        l_hist_rec.PROGRAM_APPLICATION_ID:=l_label_req_rec.PROGRAM_APPLICATION_ID;
        l_hist_rec.PROGRAM_ID            :=l_label_req_rec.PROGRAM_ID            ;
        l_hist_rec.PROGRAM_UPDATE_DATE   :=l_label_req_rec.PROGRAM_UPDATE_DATE   ;
        l_hist_rec.ATTRIBUTE_CATEGORY    :=l_label_req_rec.ATTRIBUTE_CATEGORY    ;
        l_hist_rec.ATTRIBUTE1            :=l_label_req_rec.ATTRIBUTE1            ;
        l_hist_rec.ATTRIBUTE2            :=l_label_req_rec.ATTRIBUTE2            ;
        l_hist_rec.ATTRIBUTE3            :=l_label_req_rec.ATTRIBUTE3            ;
        l_hist_rec.ATTRIBUTE4            :=l_label_req_rec.ATTRIBUTE4            ;
        l_hist_rec.ATTRIBUTE5            :=l_label_req_rec.ATTRIBUTE5            ;
        l_hist_rec.ATTRIBUTE6            :=l_label_req_rec.ATTRIBUTE6            ;
        l_hist_rec.ATTRIBUTE7            :=l_label_req_rec.ATTRIBUTE7            ;
        l_hist_rec.ATTRIBUTE8            :=l_label_req_rec.ATTRIBUTE8            ;
        l_hist_rec.ATTRIBUTE9            :=l_label_req_rec.ATTRIBUTE9            ;
        l_hist_rec.ATTRIBUTE10           :=l_label_req_rec.ATTRIBUTE10           ;
        l_hist_rec.ATTRIBUTE11           :=l_label_req_rec.ATTRIBUTE11           ;
        l_hist_rec.ATTRIBUTE12           :=l_label_req_rec.ATTRIBUTE12           ;
        l_hist_rec.ATTRIBUTE13           :=l_label_req_rec.ATTRIBUTE13           ;
        l_hist_rec.ATTRIBUTE14           :=l_label_req_rec.ATTRIBUTE14           ;
        l_hist_rec.ATTRIBUTE15           :=l_label_req_rec.ATTRIBUTE15           ;
        l_hist_rec.PRINTER_NAME          :=nvl(l_label_req_rec.PRINTER_NAME,p_label_type_info.default_printer);
        l_hist_rec.DELIVERY_ID           :=l_label_req_rec.DELIVERY_ID      ;
        l_hist_rec.BUSINESS_FLOW_CODE    :=l_label_req_rec.BUSINESS_FLOW_CODE ;
        l_hist_rec.PACKAGE_ID            :=l_label_req_rec.package_id         ;
        l_hist_rec.DELIVERY_DETAIL_ID    :=l_label_req_rec.delivery_detail_id;
        l_hist_rec.SALES_ORDER_HEADER_ID := l_label_req_rec.sales_order_header_id;
        l_hist_rec.SALES_ORDER_LINE_ID   :=l_label_req_rec.sales_order_line_id;
        l_hist_rec.RULE_ID               :=l_label_req_rec.RULE_ID;
        l_hist_rec.RULE_WEIGHT           :=l_label_req_rec.RULE_WEIGHT;
        l_hist_rec.STRATEGY_ID           :=l_label_req_rec.STRATEGY_ID;
        l_hist_rec.LABEL_CONTENT         :=p_label_content;
        l_hist_rec.JOB_NAME              :=l_job_name;
        l_hist_rec.REQUEST_MODE_CODE     :=G_PROFILE_PRINT_MODE;
        l_hist_rec.REQUEST_DATE          :=sysdate;
        l_hist_rec.REQUEST_USER_ID       :=fnd_global.user_id;
        l_hist_rec.OUTFILE_NAME          :=null;
        l_hist_rec.OUTFILE_DIRECTORY     :=null;
        l_hist_rec.NO_OF_COPY            :=p_label_type_info.default_no_of_copies;
        l_hist_rec.ENCODING              :=G_XML_ENCODING;
        l_hist_rec.STATUS_FLAG           :=nvl(p_status_flag, 'S');
        l_hist_rec.JOB_STATUS            :=NULL;
        l_hist_rec.PRINTER_STATUS        :=NULL;
        l_hist_rec.STATUS_TYPE           :=NULL;
        l_hist_rec.ERROR_MESSAGE         :=p_error_message;

    insert_history_record(l_hist_rec);
    IF (l_debug = 1) THEN
    trace('Record Inserted to WDRH', TRACE_PROMPT, TRACE_LEVEL);
    END IF;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
        trace('Other Error in populate_history_record', TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

END populate_history_record;

/***************************************
 * Update history record
 ***************************************/
PROCEDURE update_history_record(
        p_label_request_id IN NUMBER
,       p_status_flag   IN VARCHAR2
,       p_job_status    IN VARCHAR2
,       p_printer_status IN VARCHAR2
,       p_status_type   IN VARCHAR2
,       p_outfile_name  IN VARCHAR2
,       p_outfile_directory IN VARCHAR2
,       p_error_message IN VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    UPDATE wms_label_requests_hist
    SET status_flag = nvl(p_status_flag, status_flag)
    ,   job_status = nvl(p_job_status,job_status)
    ,   printer_status = nvl(p_printer_status, printer_status)
    ,   status_type   = nvl(p_status_type, status_type)
    ,   outfile_name = nvl(p_outfile_name, outfile_name)
    ,   outfile_directory = nvl(p_outfile_directory, outfile_directory)
    ,   error_message = nvl(p_error_message, error_message)
    WHERE label_request_id = p_label_request_id;
    COMMIT;
EXCEPTION
    WHEN others THEN
        IF (l_debug = 1) THEN
        trace('Error in updating history record of '||p_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
END update_history_record;

/*******************************************
 * Call the rules engine to get label format
 * It only apply for WMS installed
 * It will first insert a row into wms_label_requests
 *  then call the rules engine to get the label format
 ******************************************/

PROCEDURE GET_FORMAT_WITH_RULE
(
 P_DOCUMENT_ID                IN    NUMBER,
 P_LABEL_FORMAT_ID            IN    NUMBER ,
 P_ORGANIZATION_ID            IN    NUMBER ,
 P_INVENTORY_ITEM_ID          IN    NUMBER ,
 P_SUBINVENTORY_CODE          IN    VARCHAR2 ,
 P_LOCATOR_ID                 IN    NUMBER ,
 P_LOT_NUMBER                 IN    VARCHAR2 ,
 P_REVISION                   IN    VARCHAR2 ,
 P_SERIAL_NUMBER              IN    VARCHAR2 ,
 P_LPN_ID                     IN    NUMBER ,
 P_SUPPLIER_ID                IN    NUMBER ,
 P_SUPPLIER_SITE_ID           IN    NUMBER ,
 P_SUPPLIER_ITEM_ID           IN    NUMBER ,
 P_CUSTOMER_ID                IN    NUMBER ,
 P_CUSTOMER_SITE_ID           IN    NUMBER ,
 P_CUSTOMER_ITEM_ID           IN    NUMBER ,
 P_CUSTOMER_CONTACT_ID        IN    NUMBER ,
 P_FREIGHT_CODE               IN    VARCHAR2 ,
 P_LAST_UPDATE_DATE           IN    DATE,
 P_LAST_UPDATED_BY            IN    NUMBER,
 P_CREATION_DATE              IN    DATE,
 P_CREATED_BY                 IN    NUMBER,
 P_LAST_UPDATE_LOGIN          IN    NUMBER ,
 P_REQUEST_ID                 IN    NUMBER ,
 P_PROGRAM_APPLICATION_ID     IN    NUMBER ,
 P_PROGRAM_ID                 IN    NUMBER ,
 P_PROGRAM_UPDATE_DATE        IN    DATE ,
 P_ATTRIBUTE_CATEGORY         IN    VARCHAR2 ,
 P_ATTRIBUTE1                 IN    VARCHAR2 ,
 P_ATTRIBUTE2                 IN    VARCHAR2 ,
 P_ATTRIBUTE3                 IN    VARCHAR2 ,
 P_ATTRIBUTE4                 IN    VARCHAR2 ,
 P_ATTRIBUTE5                 IN    VARCHAR2 ,
 P_ATTRIBUTE6                 IN    VARCHAR2 ,
 P_ATTRIBUTE7                 IN    VARCHAR2 ,
 P_ATTRIBUTE8                 IN    VARCHAR2 ,
 P_ATTRIBUTE9                 IN    VARCHAR2 ,
 P_ATTRIBUTE10                IN    VARCHAR2 ,
 P_ATTRIBUTE11                IN    VARCHAR2 ,
 P_ATTRIBUTE12                IN    VARCHAR2 ,
 P_ATTRIBUTE13                IN    VARCHAR2 ,
 P_ATTRIBUTE14                IN    VARCHAR2 ,
 P_ATTRIBUTE15                IN    VARCHAR2 ,
 P_PRINTER_NAME               IN    VARCHAR2 ,
 P_DELIVERY_ID                IN    NUMBER ,
 P_BUSINESS_FLOW_CODE         IN    NUMBER ,
 P_PACKAGE_ID                 IN    NUMBER ,
 p_sales_order_header_id      IN    NUMBER ,  -- bug 2326102
 p_sales_order_line_id        IN    NUMBER ,  -- bug 2326102
 p_delivery_detail_id         IN    NUMBER ,  -- bug 2326102
 p_use_rule_engine            IN    VARCHAR2,
 x_return_status              OUT   NOCOPY VARCHAR2,
 x_label_format_id            OUT   NOCOPY NUMBER,
 x_label_format               OUT   NOCOPY VARCHAR2,
 x_label_request_id           OUT   NOCOPY NUMBER
)IS

    l_wms_installed BOOLEAN := FALSE;
    l_return_status VARCHAR2(240);
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_label_request_id  NUMBER;
    l_label_type NUMBER;


BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    -- If wms is not installed, the rules engine will not
    -- be applied
    -- Get label Request ID

    IF (l_debug = 1) THEN
      trace(' **Input Parameter values in the call to the Rules Engine ', TRACE_PROMPT, TRACE_LEVEL);
      trace(' **document_id :' || p_document_id, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Label Format ID : ' || P_LABEL_FORMAT_ID, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Organization ID : ' || p_organization_id, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Item ID : ' ||p_inventory_item_id, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Lot Number : ' ||P_LOT_NUMBER, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Serial Number : ' ||P_SERIAL_NUMBER, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Revision : '|| P_REVISION, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Business Flow Code : ' ||P_BUSINESS_FLOW_CODE, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Printer Name : ' || P_PRINTER_NAME, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Last Update Date : ' || P_LAST_UPDATE_DATE, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Last Updated By : ' || P_LAST_UPDATED_BY, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Creation Date : ' || P_CREATION_DATE, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Created By : ' || P_CREATED_BY, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Supplier ID : ' || P_SUPPLIER_ID, TRACE_PROMPT, TRACE_LEVEL);
      trace(' **Supplier Site ID : ' || P_SUPPLIER_SITE_ID, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    SELECT wms_label_print_history_s.nextval into l_label_request_id from dual;
    x_label_request_id := l_label_request_id;

    trace(' **Label Request ID : ' || l_label_request_id, TRACE_PROMPT, TRACE_LEVEL);

    IF (l_debug = 1) THEN
       trace(' **Label Request ID inserted in the wms_label_requests table is :'|| l_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    -- 1. insert a record into wms_label_requests
    -- entity to process data for label rules
    INSERT INTO wms_label_requests
      (   label_request_id,
     DOCUMENT_ID ,
     LABEL_FORMAT_ID,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     SUBINVENTORY_CODE,
     LOCATOR_ID       ,
     LOT_NUMBER       ,
     REVISION         ,
     SERIAL_NUMBER    ,
     LPN_ID           ,
     SUPPLIER_ID      ,
     SUPPLIER_SITE_ID ,
     SUPPLIER_ITEM_ID ,
     CUSTOMER_ID      ,
     CUSTOMER_SITE_ID ,
     CUSTOMER_ITEM_ID ,
     CUSTOMER_CONTACT_ID ,
     FREIGHT_CODE        ,
     LAST_UPDATE_DATE    ,
     LAST_UPDATED_BY     ,
     CREATION_DATE       ,
     CREATED_BY          ,
     LAST_UPDATE_LOGIN   ,
     REQUEST_ID          ,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID            ,
     PROGRAM_UPDATE_DATE   ,
     ATTRIBUTE_CATEGORY    ,
     ATTRIBUTE1            ,
     ATTRIBUTE2            ,
     ATTRIBUTE3            ,
     ATTRIBUTE4            ,
     ATTRIBUTE5            ,
     ATTRIBUTE6            ,
     ATTRIBUTE7            ,
     ATTRIBUTE8            ,
     ATTRIBUTE9            ,
     ATTRIBUTE10           ,
     ATTRIBUTE11           ,
     ATTRIBUTE12           ,
      ATTRIBUTE13           ,
      ATTRIBUTE14           ,
      ATTRIBUTE15           ,
      PRINTER_NAME         ,
      DELIVERY_ID      ,
      BUSINESS_FLOW_CODE ,
      package_id         ,
      delivery_detail_id,
      sales_order_header_id,
      sales_order_line_id
      )
      VALUES
      (   l_label_request_id,
     P_DOCUMENT_ID ,
     P_LABEL_FORMAT_ID,
     P_ORGANIZATION_ID,
     P_INVENTORY_ITEM_ID,
     P_SUBINVENTORY_CODE,
     P_LOCATOR_ID       ,
     P_LOT_NUMBER       ,
     P_REVISION         ,
     P_SERIAL_NUMBER    ,
     P_LPN_ID           ,
     P_SUPPLIER_ID      ,
     P_SUPPLIER_SITE_ID ,
     P_SUPPLIER_ITEM_ID ,
     P_CUSTOMER_ID      ,
     P_CUSTOMER_SITE_ID ,
     P_CUSTOMER_ITEM_ID ,
     P_CUSTOMER_CONTACT_ID ,
     P_FREIGHT_CODE        ,
     sysdate,
     FND_GLOBAL.user_id,
     sysdate,
     FND_GLOBAL.user_id,
     P_LAST_UPDATE_LOGIN   ,
     P_REQUEST_ID          ,
     P_PROGRAM_APPLICATION_ID,
     P_PROGRAM_ID            ,
     P_PROGRAM_UPDATE_DATE   ,
     P_ATTRIBUTE_CATEGORY    ,
     P_ATTRIBUTE1            ,
     P_ATTRIBUTE2            ,
     P_ATTRIBUTE3            ,
     P_ATTRIBUTE4            ,
     P_ATTRIBUTE5            ,
     P_ATTRIBUTE6            ,
     P_ATTRIBUTE7            ,
     P_ATTRIBUTE8            ,
     P_ATTRIBUTE9            ,
     P_ATTRIBUTE10           ,
     P_ATTRIBUTE11           ,
      P_ATTRIBUTE12           ,
      P_ATTRIBUTE13           ,
      P_ATTRIBUTE14           ,
      P_ATTRIBUTE15             ,
      P_PRINTER_NAME              ,
      P_DELIVERY_ID           ,
      P_BUSINESS_FLOW_CODE,
      p_package_id,
      p_delivery_detail_id,
      p_sales_order_header_id,
      p_sales_order_line_id
      );

    IF (l_debug = 1) THEN
       trace('Inserted into WMS_LABEL_REQUESTS table, label_request_id=' ||l_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    x_label_request_id := l_label_request_id;

     l_wms_installed :=  wms_install.check_install(
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data,
                     p_organization_id => P_ORGANIZATION_ID);

     IF p_label_format_id IS NOT NULL THEN
   -- The P_LABEL_FORMAT_ID(manual_format_id) is the one  passed from the manual page.
   -- As per the design, if a format ID is passed from the manual page, the rules engine will
   -- not be called.
   x_label_format_id := p_label_format_id;
         BEGIN
       select label_format_name
         into x_label_format
         from wms_label_formats
         where label_format_id = x_label_format_id;
    EXCEPTION
       when others then
          IF (l_debug = 1) THEN
        trace('No format found for ID:'||x_label_format_id, TRACE_PROMPT, TRACE_LEVEL);
          END IF;
          x_label_format:= null;
    END;

      ELSIF nvl(p_use_rule_engine, 'Y') <> 'N' THEN
          -- If indicate not to use rules engine
          -- Manual format is not specified. Check WMS installed
          -- For WMS user, call rules engine
          -- otherwise, return null
          IF (l_wms_installed = FALSE) OR (l_return_status <> 'S') THEN
        IF (l_debug = 1) THEN
           trace('WMS is not installed or enabled for org ' || P_ORGANIZATION_ID || ', will not apply rules engine.', TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Added this as part of the fix for Bug 2810264. The Rules Engine is called only for WMS enabled Orgs.
        -- Earlier, in case of MSCA Orgs, the GET_FORMAT_WITH_RULE would return a null label_format_id.
        -- In this fix, for MSCA Orgs, the default format ID and default foamrat name is derived and passed back.
        -- This change only needs to be done in the main package while the individual label API's remain
        -- untouched.
        -- Get default format
        get_default_format
          ( p_label_type_id => P_DOCUMENT_ID,
            p_label_format => x_label_format,
            p_label_format_id => x_label_format_id);

        IF (l_debug = 1) THEN
           trace('**Default Format ID in the get_format_with_rule ' || x_label_format_id, TRACE_PROMPT, TRACE_LEVEL);
           trace('**Default Format in the get_format_with_rule ' || x_label_format, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

        -- Bug 3841820
        -- When rules engine is not used, update the label request record with label format ID
             BEGIN
      update wms_label_requests
        set label_format_id = x_label_format_id
        where label_request_id = l_label_request_id;
        EXCEPTION
                WHEN others THEN
         IF l_debug =1 THEN
            trace('error when updating wms_label_requests with label format,req_id='||x_label_request_id,TRACE_PROMPT, TRACE_LEVEL);
         END IF;
        END;

      ELSE
         -- WMS is installed, apply rules engine
         -- IF clause Added for Add format/printer for manual request
         IF (l_debug = 1) THEN
            trace(' In applying rules engine, row inserted, req_id='|| l_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
         END IF;
         -- Then apply rules engine to obtain the label format
         WMS_RULE_PVT.ApplyLabel(
                  p_api_version   =>1.0,
                  p_init_msg_list =>fnd_api.g_false,
                  p_commit        =>fnd_api.g_false,
                  p_validation_level=>0,
                  p_LABEL_REQUEST_id=>l_LABEL_REQUEST_id,
                  x_return_status   =>l_return_status,
                  x_msg_count       =>l_msg_count,
                  x_msg_data        =>l_msg_data,
                  x_label_format_id =>x_label_format_id,
                  x_label_format_name =>x_label_format
                  );
         IF (l_debug = 1) THEN
            trace('  Applyed rules engine, label_format:'|| x_label_format || 'format_id='|| x_label_format_id, TRACE_PROMPT, TRACE_LEVEL);
         END IF;
          END IF;
     END IF;

     --R12 label-set changes
     --if the format_id is label set thn delete this record
     IF (l_debug = 1) THEN
   trace('Deleting row from wms_label_request, if this is a label-set', TRACE_PROMPT, TRACE_LEVEL);
     END IF;

     /*  With the label-set changes in PVT1,2,3,4,5. This record can be
       deleted for both label-set and label-format. Because the driver to
       populate in the history table is returned number of records from
       respective PVT. But since this label set feature is NOT implemented
       in other remaining PVT packages and this API does not get called
       twice, This should only be delete for label-set.

       FOR PVT1,2,3,4,5, there will be one extra record in the
       wms_label_request table for each transaction but it will NOT be
       transferred  to hist rec or to generated xml as the respective
       PVT1,2,3,4,5 does not return the first pseudo record.

       We need to insert it for each time as rules engine works of
       wms_label_request table
       */

     DELETE FROM wms_label_requests
       WHERE label_request_id = l_label_request_id
       AND exists (SELECT label_format_id FROM wms_label_formats
     WHERE label_format_id = x_label_format_id
     AND document_id = p_document_id
     AND  Nvl(label_entity_type,0) = 1);

     IF (l_debug = 1) THEN
   trace('Number of rows deleted for label-set :'||SQL%rowcount, TRACE_PROMPT, TRACE_LEVEL);
     END IF;



EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (l_debug = 1) THEN
    trace('error in calling rules engine',TRACE_PROMPT, TRACE_LEVEL);
    trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
    trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
      END IF;

END GET_FORMAT_WITH_RULE;


/********************************************
 * Wrapper API for calling printing from Java
 * This wrapper is for giving transaction ID
 *******************************************/

PROCEDURE PRINT_LABEL_WRAP
(
    x_return_status     OUT NOCOPY VARCHAR2
,   x_msg_count         OUT NOCOPY NUMBER
,   x_msg_data          OUT NOCOPY VARCHAR2
,   x_label_status      OUT NOCOPY VARCHAR2
,   p_business_flow_code    IN NUMBER
,   p_transaction_id        IN number
,   p_transaction_identifier        IN number
) IS
   l_return_status  VARCHAR2(240);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(240);
   l_no_of_copies   NUMBER   :=1;
   l_label_status   varchar2(300);
   l_transaction_id INV_LABEL.transaction_id_rec_type;
   l_transaction_identifier  NUMBER ;

BEGIN
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    IF (l_debug = 1) THEN
    trace('Begin: print_label_wrap() ' || 'p_bus_flow, txn_id, p_transaction_identifier: '
    ||p_business_flow_code||','||p_transaction_id||','|| p_transaction_identifier  , TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_transaction_id(1) := p_transaction_id;
    l_transaction_identifier := p_transaction_identifier;


    IF (l_transaction_identifier IS NULL)  AND
       (p_business_flow_code = 35) THEN
       -- =====================================
       -- Transaction is processed from MMTT
       -- =====================================
       l_transaction_identifier := 1;
       IF (l_debug = 1) THEN
          trace('Business Code 35. Set transaction_identifier to 1  ' , TRACE_PROMPT, TRACE_LEVEL);
       END IF;
    END IF;

    inv_label.print_label(
    x_return_status          => x_return_status
,   x_msg_count              => x_msg_count
,   x_msg_data               => x_msg_data
,   x_label_status           => x_label_status
,   p_api_version            => 1.0
,   p_print_mode             => 1
,   p_business_flow_code     => p_business_flow_code
,   p_transaction_id         => l_transaction_id
,   p_transaction_identifier => l_transaction_identifier
);
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('error in PRINT_LABEL_WRAP',TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

END PRINT_LABEL_WRAP;


/********************************************
 * Wrapper API for calling printing from Java
 * This wrapper is for Manual Mode
 *******************************************/
PROCEDURE PRINT_LABEL_MANUAL_WRAP
(
    x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   x_label_status          OUT NOCOPY VARCHAR2
,   p_business_flow_code    IN  NUMBER
,   p_label_type            IN  NUMBER
,   p_organization_id       IN  NUMBER
,   p_inventory_item_id     IN  NUMBER
,   p_revision              IN  VARCHAR2
,   p_lot_number            IN  VARCHAR2
,   p_fm_serial_number      IN  VARCHAR2
,   p_to_serial_number      IN  VARCHAR2
,   p_lpn_id                IN  NUMBER
,   p_subinventory_code     IN  VARCHAR2
,   p_locator_id            IN  NUMBER
,   p_delivery_id           IN  NUMBER
,   p_quantity              IN  NUMBER
,   p_uom                   IN  VARCHAR2
,   p_wip_entity_id         IN  NUMBER          --Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
,   p_no_of_copies          IN  NUMBER
,   p_fm_schedule_number    IN  VARCHAR2
,   p_to_schedule_number    IN  VARCHAR2
,   p_format_id             IN  NUMBER
,   p_printer_name          IN  VARCHAR2
) IS
   l_return_status  VARCHAR2(240);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(240);
   l_label_status   varchar2(300);
   l_input_param    input_parameter_rec_type;
   l_range_serial_numbers serial_tab_type;
   i NUMBER;
   l_lot_number MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
   l_total_schedule_number NUMBER;
   l_schedule_number NUMBER;
   l_to_schedule_number NUMBER;
   l_wip_entity_id  WIP_FLOW_SCHEDULES.WIP_ENTITY_ID%TYPE;
   l_range_schedule_numbers serial_tab_type;
   l_lot_control_code NUMBER := 1;
   --Bug8329454
   l_rev_control_code NUMBER := 1;
   l_revision mtl_item_revisions_b.REVISION%TYPE;
BEGIN


   l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   IF (l_debug = 1) THEN
      trace('Begin : print_label_manual_wrap() input parameters are ' , TRACE_PROMPT, TRACE_LEVEL);
      trace('  BusFlow,labelType: '||p_business_flow_code||','||p_label_type,TRACE_PROMPT, TRACE_LEVEL);
      trace('  Org,Item,Rev,Lot,fmSer,toSer: '||p_organization_id||','||p_inventory_item_id||','||p_revision||','
        ||p_lot_number||','||p_fm_serial_number||','||p_to_serial_number,TRACE_PROMPT, TRACE_LEVEL);
      trace('  LPN,Sub,Loc,Del,Qty,UOM,Copy: '||p_lpn_id||','||p_subinventory_code||','||p_locator_id
        ||','||p_delivery_id||','||p_quantity||','||p_uom||','||p_no_of_copies,TRACE_PROMPT, TRACE_LEVEL);
      trace('  fmSchedul,toSched,wipEntityId: '||p_fm_schedule_number||','||p_to_schedule_number||','
        ||p_wip_entity_id,TRACE_PROMPT, TRACE_LEVEL);
      trace('  formatID, printerName: '||p_format_id||','||p_printer_name, TRACE_PROMPT, TRACE_LEVEL);
   END IF;


   -- Initialize the l_input_param
   i := 1;
   l_input_param(i).organization_id        := p_organization_id;
   l_input_param(i).inventory_item_id      := p_inventory_item_id;
   l_input_param(i).revision               := p_revision;
   l_input_param(i).lot_number             := p_lot_number;
   l_input_param(i).lpn_id                 := p_lpn_id;
   l_input_param(i).subinventory_code      := p_subinventory_code;
   l_input_param(i).locator_id             := p_locator_id;
   l_input_param(i).transaction_temp_id    := p_delivery_id;
   l_input_param(i).transaction_quantity   := p_quantity;
   l_input_param(i).transaction_uom        := p_uom;

   --hjogleka, Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
   --  populate transaction_source_id with wip_entity_id.
   --  It will be read in get_variable_data of INV_LABEL_PVT2 and INV_LABEL_PVT9
   l_input_param(i).transaction_source_id  := p_wip_entity_id;

   IF (l_debug = 1) THEN
     trace('**Values to parameters passed to the PRINT_LABEL_MANUAL_WRAP',TRACE_PROMPT, TRACE_LEVEL);
     trace('**Org ID passed in : ' ||l_input_param(i).organization_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**inventory_item_id passed in : ' ||l_input_param(i).inventory_item_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**revision passed in : ' ||l_input_param(i).revision,TRACE_PROMPT, TRACE_LEVEL);
     trace('**lot_number passed in : ' ||l_input_param(i).lot_number,TRACE_PROMPT, TRACE_LEVEL);
     trace('**lpn_id passed in : ' ||l_input_param(i).lpn_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**subinventory_code passed in : ' ||l_input_param(i).subinventory_code,TRACE_PROMPT, TRACE_LEVEL);
     trace('**locator_id passed in : '||l_input_param(i).locator_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**transaction_temp_id passed in : ' ||l_input_param(i).transaction_temp_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**transaction_quantity passed in : ' ||l_input_param(i).transaction_quantity,TRACE_PROMPT, TRACE_LEVEL);
     trace('**transaction_uom passed in : ' ||l_input_param(i).transaction_uom,TRACE_PROMPT, TRACE_LEVEL);
     trace('**transaction_source_id passed in : ' ||l_input_param(i).transaction_source_id,TRACE_PROMPT, TRACE_LEVEL);
     trace('**From Serial Number pased in : ' || p_fm_serial_number,TRACE_PROMPT, TRACE_LEVEL);
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (p_fm_serial_number IS NOT NULL) THEN
      IF (p_to_serial_number IS NOT NULL)
        AND (p_fm_serial_number <> p_to_serial_number) THEN
        Begin
          -- Range serial number is provided
          GET_NUMBER_BETWEEN_RANGE(
            fm_x_number     => p_fm_serial_number
          , to_x_number     => p_to_serial_number
          , x_return_status => l_return_status
          , x_number_table  => l_range_serial_numbers
          );

        Exception
            when no_data_found then
              IF (l_debug = 1) THEN
                trace('error in GET_NUMBER_BETWEEN_RANGE : no_data_found ',TRACE_PROMPT, TRACE_LEVEL);
              END IF;

            when others then
              IF (l_debug = 1) THEN
                trace('error in PRINT_LABEL_MANUAL_WRAP',TRACE_PROMPT, TRACE_LEVEL);
                trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
                trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
              END IF;

        End;

        IF l_return_status <> 'S' THEN
            IF (l_debug = 1) THEN
            trace(' Error in getting range serial numbers from '|| p_fm_serial_number ||' to '|| p_to_serial_number || ', set serial number as null', TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            l_range_serial_numbers(1) := null;
        ELSE
            IF (l_debug = 1) THEN
            trace('  Found ' || l_range_serial_numbers.count || ' serial numbers from '|| p_fm_serial_number ||' to '|| p_to_serial_number, TRACE_PROMPT, TRACE_LEVEL);
            END IF;
        END IF;
      ELSE
        l_range_serial_numbers(1) := p_fm_serial_number;
      END IF;

    -- Check whether item is lot controlled
    -- Only if the item is lot controlled, then get lot_number
    -- joabraha :Added an exception around this select so that the exception when the item is is not Lot Cotrolled is caught
    -- and the API can proceed executing.
      Begin
          --Bug8329454
          SELECT lot_control_code,revision_qty_control_code
          INTO l_lot_control_code,l_rev_control_code
          FROM MTL_SYSTEM_ITEMS_B
          WHERE organization_id = p_organization_id
          AND inventory_item_id = p_inventory_item_id;

      Exception
        when no_data_found then
          IF (l_debug = 1) THEN
            trace('error in getting  lot_control_code : no_data_found ',TRACE_PROMPT, TRACE_LEVEL);
          END IF;

        when others then
          IF (l_debug = 1) THEN
            trace('error in PRINT_LABEL_MANUAL_WRAP',TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
          END IF;
      END;

      IF SQL%NOTFOUND THEN
        IF(l_debug=1) THEN
            trace('No item found for Org='||p_organization_id||',itemId='||p_inventory_item_id , TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        l_lot_control_code := 1;
      END IF;

      FOR i IN 1..l_range_serial_numbers.count LOOP
        l_input_param(i).organization_id := p_organization_id;
        l_input_param(i).inventory_item_id:=p_inventory_item_id;
        l_input_param(i).serial_number := l_range_serial_numbers(i);
        -- Fix bug 1797307, obtain lot_number from serial number
        -- in manual print request
        --Bug8329454
        l_revision := p_revision;
        l_lot_number := p_lot_number;
        IF (l_range_serial_numbers(i) is not null)
          AND (    ( (p_lot_number is null or p_lot_number='') AND (l_lot_control_code <> 1) )
                OR ( (p_revision is null or p_revision='')     AND (l_rev_control_code <> 1) )
              )
        THEN
            --Bug8329454
            SELECT lot_number,revision
            INTO l_lot_number,l_revision
            FROM mtl_serial_numbers
            WHERE current_organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id
            AND serial_number = l_range_serial_numbers(i);

            IF SQL%NOTFOUND THEN
                l_lot_number := null;
            END IF;
        END IF;
        --Bug8329454
        l_input_param(i).lot_number             := l_lot_number;
        l_input_param(i).revision               := l_revision;
        l_input_param(i).lpn_id                 := p_lpn_id;
        l_input_param(i).subinventory_code      := p_subinventory_code;
        l_input_param(i).locator_id             := p_locator_id;
        l_input_param(i).transaction_temp_id    := p_delivery_id;
        l_input_param(i).transaction_quantity   := p_quantity;
        l_input_param(i).transaction_uom        := p_uom;

        --hjogleka, Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
        l_input_param(i).transaction_source_id  := p_wip_entity_id;
      END LOOP;
        /* =============================================================
           Add Codes for Manual Print Of Flow Schedule Number
           =============================================================
         */
    ELSIF (p_fm_schedule_number IS NOT NULL) THEN
       l_range_schedule_numbers(1) := p_fm_schedule_number;
       IF (p_to_schedule_number IS NOT NULL)
          AND (p_fm_schedule_number <> p_to_schedule_number) THEN
         -- Range number is provided
         GET_NUMBER_BETWEEN_RANGE(
            fm_x_number     => p_fm_schedule_number
         ,   to_x_number => p_to_schedule_number
         ,   x_return_status     => l_return_status
         ,   x_number_table=> l_range_schedule_numbers
         );

         IF l_return_status <> 'S' THEN
           IF (l_debug = 1) THEN
             trace(' Error in getting range schedule numbers from '|| p_fm_schedule_number ||' to '|| p_to_schedule_number || ', set serial number as null', TRACE_PROMPT, TRACE_LEVEL);
           END IF;
           l_range_schedule_numbers(1) := null;
         ELSE
           IF (l_debug = 1) THEN
               trace('  Found ' || l_range_schedule_numbers.count || ' schedule numbers from '|| p_fm_schedule_number || ' to '|| p_to_schedule_number, TRACE_PROMPT, TRACE_LEVEL);
           END IF;
         END IF;
       END IF;

       FOR i IN 1..l_range_schedule_numbers.count LOOP
                /* retrieve wip_entity_id from wip_flow_schedule */
                BEGIN
                   SELECT wip_entity_id into l_wip_entity_id
                   FROM  WIP_FLOW_SCHEDULES
                   WHERE organization_id = p_organization_id
                   AND   schedule_number = l_range_schedule_numbers(i);

                EXCEPTION
                      WHEN OTHERS THEN
                       IF (l_debug = 1) THEN
                          trace('EXCEPTION : No data found for wip_flow_schedule', TRACE_PROMPT, TRACE_LEVEL);
                          trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
              trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
                       END IF;
                       l_wip_entity_id := null;
                END ;
        l_input_param(i).organization_id := p_organization_id;
        l_input_param(i).transaction_temp_id := l_wip_entity_id;
        l_schedule_number := l_schedule_number + i;
       END LOOP;
    END IF ;
    inv_label.print_label(
            x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,x_label_status       => x_label_status
           ,p_api_version        => 1.0
           ,p_print_mode         => 2
           ,p_label_type_id      => p_label_type
           ,p_business_flow_code => p_business_flow_code
           ,p_input_param_rec    => l_input_param
           ,p_no_of_copies       => nvl(p_no_of_copies, 1)
           ,p_format_id          => p_format_id      -- Added for the Add Printer and Format Project.
           ,p_printer_name       => p_printer_name); -- Added for the Add Printer and Format Project.
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 1) THEN
        trace('error in PRINT_LABEL_MANUAL_WRAP',TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

END PRINT_LABEL_MANUAL_WRAP;

/*********************************************
*   Print Label
*    This can be called from transaction process or manual
*     p_print_mode:  1 => Transaction Driven
*                    2 => Manual print
*       If it is transaction driven, business flow code
*           and transaction are required
*       If it is manual print, label type and input record are required
**********************************************/
PROCEDURE PRINT_LABEL
(
    x_return_status           OUT NOCOPY VARCHAR2
,   x_msg_count               OUT NOCOPY NUMBER
,   x_msg_data                OUT NOCOPY VARCHAR2
,   x_label_status            OUT NOCOPY VARCHAR2
,   p_api_version             IN         NUMBER
,   p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
,   p_commit                  IN         VARCHAR2 := fnd_api.g_false
,   p_print_mode              IN         NUMBER
,   p_business_flow_code      IN         NUMBER
,   p_transaction_id          IN         transaction_id_rec_type
,   p_input_param_rec         IN         input_parameter_rec_type
,   p_label_type_id           IN         NUMBER
,   p_no_of_copies            IN         NUMBER :=1
,   p_transaction_identifier  IN         NUMBER
,   p_format_id               IN         NUMBER    -- Added for the Add Printer and Format Project.
,   p_printer_name            IN         VARCHAR2  -- Added for the Add Printer and Format Project.
) IS


l_label_request_id      NUMBER;

BEGIN


PRINT_LABEL
(
    x_return_status           => x_return_status
,   x_msg_count               => x_msg_count
,   x_msg_data                => x_msg_data
,   x_label_status            => x_label_status
,   x_label_request_id        => l_label_request_id
,   p_api_version             => p_api_version
,   p_init_msg_list           => p_init_msg_list
,   p_commit                  => p_commit
,   p_print_mode              => p_print_mode
,   p_business_flow_code      => p_business_flow_code
,   p_transaction_id          => p_transaction_id
,   p_input_param_rec         => p_input_param_rec
,   p_label_type_id           => p_label_type_id
,   p_no_of_copies            => p_no_of_copies
,   p_transaction_identifier  => p_transaction_identifier
,   p_format_id               => p_format_id
,   p_printer_name            => p_printer_name );


end PRINT_LABEL;

/*********************************************
*   Print Label - Overloaded version with new para added (x_label_request_id)
*
*  Wrapper API to call the print label api above...
*
**********************************************/

PROCEDURE PRINT_LABEL
(
    x_return_status      OUT NOCOPY VARCHAR2
,   x_msg_count          OUT NOCOPY NUMBER
,   x_msg_data           OUT NOCOPY VARCHAR2
,   x_label_status       OUT NOCOPY VARCHAR2
,   x_label_request_id   OUT NOCOPY NUMBER -- added by fabdi
,   p_api_version        IN         NUMBER
,   p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
,   p_commit             IN         VARCHAR2 := fnd_api.g_false
,   p_print_mode         IN         NUMBER
,   p_business_flow_code IN         NUMBER
,   p_transaction_id     IN         transaction_id_rec_type
,   p_input_param_rec    IN         input_parameter_rec_type
,   p_label_type_id      IN         NUMBER
,   p_no_of_copies       IN         NUMBER :=1
,   p_transaction_identifier  IN    NUMBER
,   p_format_id          IN NUMBER    -- Added for the Add Printer and Format Project.
,   p_printer_name       IN VARCHAR2  -- Added for the Add Printer and Format Project.

) IS
    l_api_version        CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(100) := 'PRINT_LABEL';
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(240);
    l_return_status      VARCHAR2(10);
    l_type_msg_count     NUMBER;
    l_type_msg_data      VARCHAR2(240);
    l_type_return_status VARCHAR2(10);

    l_label_types        label_type_tbl_type;

    l_variable_data      label_tbl_type;
    l_job_status         VARCHAR2(2000); -- Bug 3328061 increased the size
    l_printer_status     VARCHAR2(2000); -- Bug 3328061 increased the size
    l_status_type        NUMBER;

    l_request_id         NUMBER;

    l_xml_request_id     NUMBER;
    l_lpn_table          lpn_table_type; --BUG#3055877
    l_print_lpn_label    VARCHAR2(10);   --BUG#3055877
    lpn_table_populated  VARCHAR2(10);   --BUG#3055877
    l_patch_level        NUMBER; -- indicates the current patchset level

    /* bug 3417450 */
    l_lpn_sum_rec        label_type_tbl_type;
    l_found_sum_rec      BOOLEAN := FALSE;
    cntr                 BINARY_INTEGER;

BEGIN

    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    IF (l_debug = 1) THEN
        trace(' **** In Print_label ****', TRACE_PROMPT, TRACE_LEVEL);
        trace(' p_print_mode, p_label_type_id, p_business_flow_code: '
           || p_print_mode ||','||p_label_type_id||','||p_business_flow_code, TRACE_PROMPT, TRACE_LEVEL);
        trace(' Number of p_input_param_rec, p_transaction_id: '|| p_input_param_rec.count ||','||p_transaction_id.count, TRACE_PROMPT, TRACE_LEVEL);
        trace(' p_no_of_copies, p_transaction_identifier, p_format_id, p_printer_name: '
           || p_no_of_copies||','||p_transaction_identifier ||','||p_format_id||','||p_printer_name, TRACE_PROMPT, TRACE_LEVEL);

        FOR i IN 1..p_transaction_id.count LOOP
            IF (l_debug = 1) THEN
                 trace(' For txn_id rec ' || i ||', trx_id = '|| p_transaction_id(i), TRACE_PROMPT, TRACE_LEVEL);
            END IF;
        END LOOP;
    END IF;
    /* Get the current patchset level*/
    IF (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po
       OR inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j
       ) THEN
           l_patch_level := 1; --Patchset J level or above
           IF (l_debug = 1) THEN
           trace('Patchset J level or above' , TRACE_PROMPT, TRACE_LEVEL);
           END IF;
    ELSE
           l_patch_level := 0; -- Below Patchset J
           IF (l_debug = 1) THEN
           trace(' Below Patchset J level ' , TRACE_PROMPT, TRACE_LEVEL);
           END IF;
    END IF;

    IF p_print_mode =1 THEN
        -- Transaction driven, should provide transaction_id and business_flow_code
        IF (p_business_flow_code IS NULL) OR (p_business_flow_code <=0)
            OR (p_transaction_id.count = 0) THEN
            IF (l_debug = 1) THEN
            trace('     Not enough input, missing transaction_id or business_flow_code' , TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF p_print_mode =2 THEN
        -- On demand, should provide input_param_rec and label_type
        IF (p_input_param_rec.count = 0 ) OR
            ((p_label_type_id IS NULL OR p_label_type_id=0) AND (p_business_flow_code IS NULL)) THEN
            IF (l_debug = 1) THEN
            trace('     Not enough input, missing input_param or label_type' , TRACE_PROMPT, TRACE_LEVEL);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        IF (l_debug = 1) THEN
        trace(' Invalid value for p_print_mode, should be 1 or 2' , TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_debug = 1) THEN
      trace(' Passed input parameter validation, Start ' , TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT   CREATE_XML_LABEL;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
        (   l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
      --FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_INCOMPATIBLE_API_CALL');
      --FND_MSG_PUB.ADD;
      IF (l_debug = 1) THEN
      trace(' Incompatible API ' , TRACE_PROMPT, TRACE_LEVEL);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get global variables
    IF (l_debug = 1) THEN
    trace(' Set and get global variables for date,time,user,encoding,profile values', TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    get_profile_values;
    get_date_time_user;
    get_xml_encoding;

    IF (l_debug = 1) THEN
    trace(' Profile-Print Mode:'||G_PROFILE_PRINT_MODE||',Prefix: '||G_PROFILE_PREFIX
                   ||',Out Directory: '||G_PROFILE_OUT_DIR
                   ||',Date Mask: '||G_DATE_FORMAT_MASK, TRACE_PROMPT, TRACE_LEVEL);
    trace(' Request time: '||G_DATE||' '||G_TIME, TRACE_PROMPT, TRACE_LEVEL);
    trace(' Request user: '||G_USER, TRACE_PROMPT, TRACE_LEVEL);
    trace(' XML encoding: '||G_XML_ENCODING, TRACE_PROMPT, TRACE_LEVEL);
    END IF;


    GET_TYPE_TO_PRINT(
          x_return_status  => l_return_status
        , x_msg_count      => l_msg_count
        , x_msg_data       => l_msg_data
        , x_types_to_print => l_label_types -- This is passed to the get_variable_data.
        , p_business_flow  => p_business_flow_code
        , p_label_type_id  => p_label_type_id
        , p_no_of_copies   => p_no_of_copies
        , p_format_id      => p_format_id    -- Added for Add Format/Printer project
        , p_printer_name   => p_printer_name -- Added for Add Format/Printer project
        );

    IF (l_debug = 1) THEN
    trace('     Got label types, count = ' || l_label_types.count(), TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    IF l_return_status <> 'S' THEN
        IF (l_debug = 1) THEN
        trace(' Get Type Failed ', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --BUG#3055877
    /* inline branch the code so that we select the records from rti for *
     * patchset level below J, and from rt for Patchset J and above      *
     */
    IF l_patch_level = 0 THEN
      IF p_business_flow_code in (1,2,3,4) THEN
         lpn_table_populated := 'N';
         FOR l IN 1..l_label_types.count() LOOP
           IF (l_label_types(l).label_type_id in (3,4,5) and lpn_table_populated = 'N') THEN
             IF (l_debug = 1) THEN
               trace(' LABEL TYPE- LPN/LPN CONTENT/LPN SUMMARY exists getting lpn_id from rti', TRACE_PROMPT, TRACE_LEVEL);
             END IF;
             FOR m IN 1..p_transaction_id.count() LOOP
               IF (l_debug = 1) THEN
                 trace(' b4 patchset J: interface_transaction_id: '||p_transaction_id(m), TRACE_PROMPT, TRACE_LEVEL);
               END IF;
                  SELECT nvl(DECODE(p_business_flow_code,2,rti.transfer_lpn_id,rti.lpn_id),0)
                    INTO   l_lpn_table(m)
                    FROM   rcv_transactions_interface rti
                  WHERE  rti.interface_transaction_id = p_transaction_id(m);
               IF (l_debug = 1) THEN
                 trace(' Got LPN_ID: '||l_lpn_table(m), TRACE_PROMPT, TRACE_LEVEL);
                 trace(' for interface_transaction_id: '||p_transaction_id(m), TRACE_PROMPT, TRACE_LEVEL);
               END IF;
               lpn_table_populated := 'Y';
             END LOOP;
           END IF;
         END LOOP;
      END IF;
    END IF;
    --BUG#3055877

   /*Fix for bug 3858504. For cartonization we will store
       the table of LPN IDs for shipping content label */
     IF p_business_flow_code = 22 THEN
         --INV_LABEL_PVT8.g_carton_table := p_transaction_id;
         -- 4645826, call set_carton_count to count the total number of cartons for delivery
         -- Pick release can be run for multiple deliveries
         -- The count of p_transaction_id can be for multiple deliveries
         -- Need to count the total for each delivery
         FOR i IN 1..p_transaction_id.count LOOP
            INV_LABEL_PVT8.set_carton_count(p_transaction_id(i));
         END LOOP;
     END IF; --End of Fix for bug 3858504.


       -- Added for R12 RFID Compliance project
       -- Set value for global variable EPC_GROUP_ID
       -- The value will be set to null at the end of label printing code
     SELECT WMS_EPC_S2.nextval INTO EPC_GROUP_ID FROM DUAL;
     IF (l_debug = 1) THEN
       trace(' Set EPC_GROUP_ID = '||EPC_GROUP_ID, TRACE_PROMPT, TRACE_LEVEL);
     END IF;

    IF (l_debug = 1) THEN
    trace(' # Start to loop and print each label ', TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    IF p_print_mode = 1 THEN
        -- Transaction process driven
        g_xml_content := '';
        <<TxnRowLoop>>
        FOR i IN 1..p_transaction_id.count() LOOP
            <<LabelTypeLoop>>
            l_print_lpn_label := 'Y'; --BUG#3055877
            FOR j IN 1..l_label_types.count() LOOP
                --BUG#3055877
                IF l_patch_level = 0 THEN
                    IF p_business_flow_code in (1,2,3,4) THEN
                        IF ( (l_label_types(j).label_type_id in (3,4,5)) and i >= 2) THEN
                            FOR k IN REVERSE 2..i LOOP
                                IF l_lpn_table(i) = l_lpn_table(k-1) THEN
                                    IF (l_debug = 1) THEN
                                        trace('LPN releated labels(LPN/CONTENT/SUMMARY) already printed for this lpn_id: ' ||l_lpn_table(i),  TRACE_PROMPT, TRACE_LEVEL);
                                    END IF;
                                    l_print_lpn_label := 'N';
                                    exit;
                                END IF;
                            END LOOP;
                        END IF;
                    END IF;
                END IF;
                --BUG#3055877

                IF (l_debug = 1) THEN
                    trace(' ## In Loop , for trx rec ' || i || ' , type '|| j, TRACE_PROMPT, TRACE_LEVEL);
                    trace('     Going to get variable data ', TRACE_PROMPT, TRACE_LEVEL);
                    trace('      value of l_print_lpn_label ' || l_print_lpn_label, TRACE_PROMPT, TRACE_LEVEL);
                END IF;

                IF l_patch_level = 1 THEN
                    l_print_lpn_label := 'Y';
                    trace(' The value of l_print_lpn_label is now ' || l_print_lpn_label, TRACE_PROMPT, TRACE_LEVEL);
                END IF;

                IF (l_label_types(j).label_type_id not in (3,4,5)) OR (l_print_lpn_label = 'Y') THEN --BUG#3055877
                   IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 1 ', TRACE_PROMPT, TRACE_LEVEL);
                   END IF;
                    get_variable_data(
                         x_variable_content => l_variable_data
                        ,x_msg_count=>l_msg_count
                        ,x_msg_data => l_msg_data
                        ,x_return_status => l_return_status
                        ,p_label_type_info => l_label_types(j)
                        ,p_transaction_id => p_transaction_id(i)
                        ,p_input_param => null
                        ,p_transaction_identifier => p_transaction_identifier
                    );



                    IF (l_debug = 1) THEN
                        trace('     got variable data # rec count ='||l_variable_data.count(), TRACE_PROMPT, TRACE_LEVEL);
                        trace('     return status = '||l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                        trace('     x_msg_count= '||l_msg_count , TRACE_PROMPT, TRACE_LEVEL);
                        trace('     x_msg_data= '||l_msg_data, TRACE_PROMPT, TRACE_LEVEL);
                    END IF;

                    IF l_return_status <> 'S' THEN
                        x_msg_data := l_msg_data;
                        IF (l_debug = 1) THEN
                           trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 2 ', TRACE_PROMPT, TRACE_LEVEL);
                           trace('Custom Labels Trace [INVLABPB.pls]: Unexpected Error returned by get_variable_data()', TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                     RETURN;
                    END IF;


                    FOR k IN 1..l_variable_data.count() LOOP
                        IF (l_debug = 1) THEN
                            trace(' write xml header,check_xml,populate_history ', TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        write_xml_header(l_label_types(j),l_variable_data(k).label_request_id );
                        x_label_request_id := l_variable_data(k).label_request_id; -- added by fabdi
                        IF (l_debug = 1) THEN
                            trace('x_label_request_id is >> '|| x_label_request_id, TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        g_xml_content := g_xml_header || l_variable_data(k).label_content || LABELS_E;
                        check_xml(g_xml_content);
                        IF (l_debug = 1) THEN
                           trace('Custom Labels Trace [INVLABPB.pls]: Before populate_history_record() ', TRACE_PROMPT, TRACE_LEVEL);
                           trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                           trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).error_message: ' || l_variable_data(k).error_message, TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        populate_history_record(
                            p_label_type_info => l_label_types(j)
                          , p_label_content => g_xml_content
                          , p_label_request_id => l_variable_data(k).label_request_id
                          , p_status_flag => l_variable_data(k).label_status
                          , p_error_message => l_variable_data(k).error_message
                        );

                        IF (l_debug = 1) THEN
                           trace('Custom Labels Trace [INVLABPB.pls]: After populate_history_record() ', TRACE_PROMPT, TRACE_LEVEL);
                        END IF;

                        IF G_PROFILE_PRINT_MODE = 1 THEN
                        -- Synchronize Mode, send request for each label

                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 3 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Inside TXN Driven -> Synchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            -- Proceed sending request for printing only if the label status is not an ERROR
                            -- Bug Fix 5330030, put a NVL around l_variable_data(k).label_statu since null value for
                            -- l_variable_data(k).label_status would indicate success.
                            -- IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                            IF (nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 4 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Before calling SYNC_PRINT_REQUEST() ', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               INV_PRINT_REQUEST.SYNC_PRINT_REQUEST(
                                   p_xml_content       => g_xml_content
                                  ,x_job_status        => l_job_status
                                  ,x_printer_status    => l_printer_status
                                  ,x_status_type       => l_status_type);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 5 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: After calling SYNC_PRINT_REQUEST() ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_job_status is: ' || l_job_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_printer_status is: ' || l_printer_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_status_type is: ' || l_status_type, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               update_history_record(
                                  p_label_request_id => l_variable_data(k).label_request_id
                               --,p_status_flag => 'S'
                               --Change made for 4179593
                                 ,p_status_flag => l_variable_data(k).label_status
                                 ,p_error_message => l_variable_data(k).error_message
                                 ,p_job_status => l_job_status
                                 ,p_printer_status => l_printer_status
                                 ,p_status_type => l_status_type);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: AFTER update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                            ELSE
                            -- Do nothing (Avoid sending request to the printer)
                              IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 6 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: ERROR: Print Request Not Sent', TRACE_PROMPT, TRACE_LEVEL);
                              END IF;
                            END IF;
                        ELSIF G_PROFILE_PRINT_MODE  = 2 THEN
                        -- Asynchronize Mode, calling write_xml to write into a xml file

                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 7 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Inside TXN Driven -> Asynchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            -- Proceed writing the XML file only if the label status is not an ERROR
                            -- Bug Fix 5330030, put a NVL around l_variable_data(k).label_statu since null value for
                            -- l_variable_data(k).label_status would indicate success.
                            -- IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                            IF (nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 8 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Before calling WRITE_XML() ', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               INV_PRINT_REQUEST.WRITE_XML(
                                p_xml_content       => g_xml_content
                               ,p_request_id        => l_variable_data(k).label_request_id
                               ,x_return_status     => l_return_status
                               ,x_msg_count         => l_msg_count
                               ,x_msg_data          => l_msg_data);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 9 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: After calling WRITE_XML() ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_return_status is: ' || l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               update_history_record(
                                    p_label_request_id => l_variable_data(k).label_request_id
                                 --,p_status_flag => 'S'
                                 --Change made for 4179593
                                   ,p_status_flag => l_variable_data(k).label_status
                                   ,p_error_message => l_variable_data(k).error_message
                                   ,p_outfile_name => G_PROFILE_PREFIX||l_variable_data(k).label_request_id ||'.xml'
                                   ,p_outfile_directory => G_PROFILE_OUT_DIR
                                );
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 10 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: AFTER update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_return_status is: ' || l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                            ELSE
                            -- Do nothing (Avoid writing the XML file)
                              IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 11 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: ERROR: XML File Not Written', TRACE_PROMPT, TRACE_LEVEL);
                              END IF;
                            END IF;

                           /*
                            The following piece of the code is now moved after the call TO WRITE_XML() above.
                            XML file will be written and the history record will now be updated only if there was
                            no ERROR returned by the get_variable_data() from the relevant Label Type files.

                            IF nvl(l_return_status,'E') <> 'S' THEN
                                   update_history_record(
                                   p_label_request_id => l_variable_data(k).label_request_id
                                  ,p_status_flag => 'E');
                            ELSE
                                   update_history_record(
                                   p_label_request_id => l_variable_data(k).label_request_id
                                   ,p_status_flag => 'S'
                                   ,p_outfile_name => G_PROFILE_PREFIX||l_variable_data(k).label_request_id ||'.xml'
                                   ,p_outfile_directory => G_PROFILE_OUT_DIR);
                          */

                        -- New Printer Mode in Patchset J for Synchronize TCPIP printing
                        ELSIF G_PROFILE_PRINT_MODE  = 3 THEN
                            -- Synchronize TCPIP Mode, calling SYNC_PRINT_TCPIP to print label through TCPIP mode
                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 12 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Inside TXN Driven -> TCP/IP Synchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            -- Proceed TCP/IP printing only if the label status is not an ERROR
                            -- Bug Fix 5330030, put a NVL around l_variable_data(k).label_statu since null value for
                            -- l_variable_data(k).label_status would indicate success.
                            -- IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                            IF (nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 13 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Before calling SYNC_PRINT_TCPIP() ', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               INV_PRINT_REQUEST.SYNC_PRINT_TCPIP(
                                p_xml_content       => g_xml_content
                               ,x_job_status        => l_job_status
                               ,x_printer_status    => l_printer_status
                               ,x_status_type       => l_status_type
                               ,x_return_status     => l_return_status
                               ,x_return_msg        => l_msg_data);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 14 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: After calling SYNC_PRINT_TCPIP() ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_job_status is: ' || l_job_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_printer_status is: ' || l_printer_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_status_type is: ' || l_status_type, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               update_history_record(
                                   p_label_request_id => l_variable_data(k).label_request_id
                                --,p_status_flag => 'S'
                                --Change made for 4179593
                                  ,p_status_flag => l_variable_data(k).label_status
                                  ,p_error_message => l_variable_data(k).error_message
                                  ,p_job_status => l_job_status
                                  ,p_printer_status => l_printer_status
                                  ,p_status_type => l_status_type);
                            ELSE
                            -- Do nothing (Avoid sending TCP/IP request to printer)
                              IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 15 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: ERROR: TCP/IP Print Request Not Sent', TRACE_PROMPT, TRACE_LEVEL);
                              END IF;
                            END IF;
                           /*
                            The following piece of the code is now moved after the call TO SYNC_PRINT_TCPIP() above.
                            TCP/IP Print Request will be sent and the history record will now be updated only if there was
                            were no ERROR returned by the get_variable_data() from the relevant Label Type files.

                            IF nvl(l_return_status,'E') <> 'S' THEN
                                 update_history_record(
                                 p_label_request_id => l_variable_data(k).label_request_id
                                ,p_status_flag => 'E'
                                ,p_error_message => l_msg_data);
                            ELSE
                                 trace('update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                                 update_history_record(
                                 p_label_request_id => l_variable_data(k).label_request_id
                                ,p_status_flag => 'S'
                                ,p_job_status => l_job_status
                                ,p_printer_status => l_printer_status
                                ,p_status_type => l_status_type);
                            END IF;
                           */
                        ELSE
                            IF (l_debug = 1) THEN
                            trace('wrong profile value for WMS_PRINT_MODE = '||G_PROFILE_PRINT_MODE, TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                        END IF;
                        -- clear g_xml_content , ready for the next xml
                        g_xml_content := '';
                    END LOOP;
                END IF; --BUG#3055877
            END LOOP LabelTypeLoop;
        END LOOP TxnRowLoop;
        CLEAR_GLOBALS;

    ELSIF p_print_mode = 2 THEN
        -- On Demand mode
        g_xml_content := '';
        <<InputParamLoop>>
        FOR i IN 1..p_input_param_rec.count() LOOP
            <<LabelTypeLoop2>>
            FOR j IN 1..l_label_types.count() LOOP

                IF (l_debug = 1) THEN
                trace(' ## In Loop , for txn rec ' || i || ' , type '|| j, TRACE_PROMPT, TRACE_LEVEL);
                trace('     Going to get variable data ', TRACE_PROMPT, TRACE_LEVEL);
                END IF;
                /* Bug 3417450 Delete the global table g_label_request_tbl before calling
                 * get_variable_data
                 */
                g_label_request_tbl.DELETE;

                IF (l_debug = 1) THEN
                        trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 16 ', TRACE_PROMPT, TRACE_LEVEL);
                END IF;
                get_variable_data(
                    x_variable_content => l_variable_data
                ,   x_msg_count => l_msg_count
                ,   x_msg_data  => l_msg_data
                ,   x_return_status => l_return_status
                ,   p_label_type_info => l_label_types(j)
                ,   p_transaction_id => null
                ,   p_input_param   => p_input_param_rec(i)
                ,   p_transaction_identifier => null
                );

                IF (l_debug = 1) THEN
                    trace('      got variable data', TRACE_PROMPT, TRACE_LEVEL);
                    trace('      return status = '||l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                    trace('      x_msg_count='||l_msg_count , TRACE_PROMPT, TRACE_LEVEL);
                    trace('      x_msg_data='||l_msg_data, TRACE_PROMPT, TRACE_LEVEL);
                END IF;

                IF l_return_status <> 'S' THEN
                  x_msg_data := l_msg_data;
                  IF (l_debug = 1) THEN
                     trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 17 ', TRACE_PROMPT, TRACE_LEVEL);
                     trace('Custom Labels Trace [INVLABPB.pls]: Unexpected Error returned by get_variable_data()', TRACE_PROMPT, TRACE_LEVEL);
                  END IF;
                 RETURN;
                END IF;

                /* Bug 3417450 Get the info for LPN Summary label, if a call was
                 * made for LPN Content label and the table g_label_request_tbl
                 * is already populated
                 */
                IF l_label_types(j).label_type_id = 4 AND g_label_request_tbl.count() > 0 THEN
                    IF (l_debug = 1) THEN
                        trace('calling get_type_to_print, with label type id as 5 ',TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
                    get_type_to_print(
                       x_return_status   => l_return_status
                    ,  x_msg_count       => l_msg_count
                    ,  x_msg_data        => l_msg_data
                    ,  x_types_to_print  => l_lpn_sum_rec
                    ,  p_business_flow   => NULL
                    ,  p_label_type_id   => 5
                    ,  p_no_of_copies    => p_no_of_copies
                    ,  p_format_id       => p_format_id
                    ,  p_printer_name    => p_printer_name);
                    IF nvl(l_return_status,'E') <> 'S' THEN
                        IF l_debug =1 THEN
                            trace('returned error from get_type_to_print ' || l_msg_data,TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                    END IF;
                END IF;

                FOR k IN 1..l_variable_data.count() LOOP
                    IF (l_debug = 1) THEN
                        trace('         write xml header,check_xml,populate_history ', TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
                    /* Bug 3417450 */
                    IF l_label_types(j).label_type_id = 4 THEN /* LPN Content label */
                        IF (l_debug = 1) THEN
                            trace('label type is LPN Content ',TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        IF g_label_request_tbl.count() > 0 THEN
                            IF (l_debug = 1) THEN
                                trace('label request table is populated ' || g_label_request_tbl.count,TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            cntr := g_label_request_tbl.first;
                            /* Loop through each record in g_label_request_tbl to get
                             * the header information for LPN SUmmary label type
                             */
                            LOOP
                                IF (l_debug = 1) THEN
                                    trace(' g_label_request_tbl(cntr).label_type ' || g_label_request_tbl(cntr).label_type_id,TRACE_PROMPT, TRACE_LEVEL);
                                    trace(' g_label_request_tbl(cntr).label_request_id ' || g_label_request_tbl(cntr).label_request_id,TRACE_PROMPT, TRACE_LEVEL);
                                END IF;
                                IF (g_label_request_tbl(cntr).label_request_id = l_variable_data(k).label_request_id
                                    AND g_label_request_tbl(cntr).label_type_id = 5) THEN
                                    l_found_sum_rec := TRUE;
                                END IF;
                                EXIT WHEN cntr = g_label_request_tbl.last OR l_found_sum_rec = TRUE;
                                cntr := g_label_request_tbl.next(cntr);
                            END LOOP;
                        END IF; -- end if count > 0
                        IF l_found_sum_rec = TRUE THEN --this is an lpn summary label
                            l_found_sum_rec := FALSE;
                            IF (l_debug = 1) THEN
                                trace('calling write_xml_header for lpn_sum_rec ',TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            write_xml_header(l_lpn_sum_rec(1), l_variable_data(k).label_request_id);
                        ELSE
                            IF (l_debug = 1) THEN
                                trace(' no summary record found. calling for lpn content label ',TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            write_xml_header(l_label_types(j),l_variable_data(k).label_request_id);
                        END IF;
                    ELSE --label type is not 4
                        IF (l_debug = 1) THEN
                            trace('label type is not 4 ' || l_label_types(j).label_type_id,TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        write_xml_header(l_label_types(j),l_variable_data(k).label_request_id);
                    END IF;
                    g_xml_content := g_xml_header || l_variable_data(k).label_content || LABELS_E;
                    check_xml(g_xml_content);
                    IF (l_debug = 1) THEN
                       trace('Custom Labels Trace [INVLABPB.pls]: Before populate_history_record() ', TRACE_PROMPT, TRACE_LEVEL);
                       trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                       trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).error_message: ' || l_variable_data(k).error_message, TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
                    populate_history_record(
                        p_label_type_info => l_label_types(j)
                      , p_label_content => g_xml_content
                      , p_label_request_id => l_variable_data(k).label_request_id
                      , p_status_flag => l_variable_data(k).label_status
                      , p_error_message => l_variable_data(k).error_message
                    );

                    IF (l_debug = 1) THEN
                       trace('Custom Labels Trace [INVLABPB.pls]: After populate_history_record() ', TRACE_PROMPT, TRACE_LEVEL);
                    END IF;

                    IF G_PROFILE_PRINT_MODE = 1 THEN
                    -- Synchronize Mode, send request for each label

                        IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 18 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Inside DEMAND Driven -> Synchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        -- Proceed sending request for printing only if the label status is not an ERROR

                        -- Bug Fix 4552112, put a NVL around l_variable_data(k).label_statu since null value for
                        -- l_variable_data(k).label_status would indicate success.
                        --IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                        IF ( nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 19 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Before calling SYNC_PRINT_REQUEST() ', TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            INV_PRINT_REQUEST.SYNC_PRINT_REQUEST(
                               p_xml_content       => g_xml_content
                              ,x_job_status        => l_job_status
                              ,x_printer_status    => l_printer_status
                              ,x_status_type       => l_status_type);
                            IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 20 ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: After calling SYNC_PRINT_REQUEST() ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Value of l_job_status is: ' || l_job_status, TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Value of l_printer_status is: ' || l_printer_status, TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Value of l_status_type is: ' || l_status_type, TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            update_history_record(
                                p_label_request_id => l_variable_data(k).label_request_id
                             --,p_status_flag => 'S'
                              --Change made for 4179593
                               ,p_status_flag => l_variable_data(k).label_status
                               ,p_error_message => l_variable_data(k).error_message
                               ,p_job_status => l_job_status
                               ,p_printer_status => l_printer_status
                               ,p_status_type => l_status_type);
                           IF (l_debug = 1) THEN
                             trace('Custom Labels Trace [INVLABPB.pls]: After update_history_record() ', TRACE_PROMPT, TRACE_LEVEL);
                           END IF;
                            ELSE
                            -- Do nothing (Avoid sending request to the printer)
                        IF (l_debug = 1) THEN
                         trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 21 ', TRACE_PROMPT, TRACE_LEVEL);
                         trace('Custom Labels Trace [INVLABPB.pls]: ERROR: Print Request Not Sent', TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                      END IF;
                    ELSIF G_PROFILE_PRINT_MODE  = 2 THEN
                    -- Asynchronize Mode, calling write_xml to write into a xml file
                        IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 22', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: Inside DEMAND Driven -> Asynchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                        -- Proceed writing the XML file only if the label status is not an ERROR
                        -- Bug Fix 5330030, put a NVL around l_variable_data(k).label_statu since null value for
                        -- l_variable_data(k).label_status would indicate success.
                        -- IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                        IF (nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 23 ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Before calling WRITE_XML() ', TRACE_PROMPT, TRACE_LEVEL);
                           END IF;
                           INV_PRINT_REQUEST.WRITE_XML(
                               p_xml_content       => g_xml_content
                              ,p_request_id        => l_variable_data(k).label_request_id
                              ,x_return_status     => l_return_status
                              ,x_msg_count     => l_msg_count
                              ,x_msg_data      => l_msg_data);
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 24 ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: After calling WRITE_XML() ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Value of l_return_status is: ' || l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                           END IF;
                           update_history_record(
                                    p_label_request_id => l_variable_data(k).label_request_id
                                 --,p_status_flag => 'S'
                                 --Change made for 4179593
                                   ,p_status_flag => l_variable_data(k).label_status
                                   ,p_error_message => l_variable_data(k).error_message
                                   ,p_outfile_name => G_PROFILE_PREFIX||l_variable_data(k).label_request_id ||'.xml'
                                   ,p_outfile_directory => G_PROFILE_OUT_DIR);
                           IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 25 ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: AFTER update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Value of l_return_status is: ' || l_return_status, TRACE_PROMPT, TRACE_LEVEL);
                           END IF;
                            ELSE
                            -- Do nothing (Avoid writing the XML file)
                              IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 26 ', TRACE_PROMPT, TRACE_LEVEL);
                               trace('Custom Labels Trace [INVLABPB.pls]: ERROR: XML File Not Written', TRACE_PROMPT, TRACE_LEVEL);
                              END IF;
                        END IF;

                        /*
                         The following piece of the code is now moved after the call TO WRITE_XML() above.
                         XML file will be written and the history record will now be updated only if there was
                         no ERROR returned by the get_variable_data() from the relevant Label Type files.

                         IF nvl(l_return_status,'E') <> 'S' THEN
                                update_history_record(
                                p_label_request_id => l_variable_data(k).label_request_id
                               ,p_status_flag => 'E');
                         ELSE
                                update_history_record(
                                p_label_request_id => l_variable_data(k).label_request_id
                                ,p_status_flag => 'S'
                                ,p_outfile_name => G_PROFILE_PREFIX||l_variable_data(k).label_request_id ||'.xml'
                                ,p_outfile_directory => G_PROFILE_OUT_DIR);
                       */

                    -- New Printer Mode in Patchset J for Synchronize TCPIP printing
                    ELSIF G_PROFILE_PRINT_MODE  = 3 THEN
                    -- Synchronize TCPIP Mode, calling SYNC_PRINT_TCPIP to print label through TCPIP mode
                         IF (l_debug = 1) THEN
                            trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 27 ', TRACE_PROMPT, TRACE_LEVEL);
                            trace('Custom Labels Trace [INVLABPB.pls]: Inside DEMAND Driven -> TCP/IP Synchronous mode code', TRACE_PROMPT, TRACE_LEVEL);
                            trace('Custom Labels Trace [INVLABPB.pls]: l_variable_data(k).label_status: ' || l_variable_data(k).label_status, TRACE_PROMPT, TRACE_LEVEL);
                         END IF;
                         -- Proceed TCP/IP printing only if the label status is not an ERROR
                         -- Bug Fix 5330030, put a NVL around l_variable_data(k).label_statu since null value for
                         -- l_variable_data(k).label_status would indicate success.
                         --IF ( l_variable_data(k).label_status <> FND_API.G_RET_STS_ERROR ) THEN
                         IF (nvl(l_variable_data(k).label_status, FND_API.G_RET_STS_SUCCESS) = FND_API.G_RET_STS_SUCCESS ) THEN
                            IF (l_debug = 1) THEN
                              trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 28 ', TRACE_PROMPT, TRACE_LEVEL);
                              trace('Custom Labels Trace [INVLABPB.pls]: Before calling SYNC_PRINT_TCPIP() ', TRACE_PROMPT, TRACE_LEVEL);
                            END IF;
                            INV_PRINT_REQUEST.SYNC_PRINT_TCPIP(
                               p_xml_content       => g_xml_content
                              ,x_job_status        => l_job_status
                              ,x_printer_status    => l_printer_status
                              ,x_status_type       => l_status_type
                              ,x_return_status     => l_return_status
                              ,x_return_msg        => l_msg_data);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 29 ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: After calling SYNC_PRINT_TCPIP() ', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_job_status is: ' || l_job_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_printer_status is: ' || l_printer_status, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: Value of l_status_type is: ' || l_status_type, TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: BEFORE update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                                 trace('Custom Labels Trace [INVLABPB.pls]: update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                               update_history_record(
                                   p_label_request_id => l_variable_data(k).label_request_id
                                --,p_status_flag => 'S'
                                --Change made for 4179593
                                  ,p_status_flag => l_variable_data(k).label_status
                                  ,p_error_message => l_variable_data(k).error_message
                                  ,p_job_status => l_job_status
                                  ,p_printer_status => l_printer_status
                                  ,p_status_type => l_status_type);
                               IF (l_debug = 1) THEN
                                 trace('Custom Labels Trace [INVLABPB.pls]: AFTER update_history_record()', TRACE_PROMPT, TRACE_LEVEL);
                               END IF;
                            ELSE
                            -- Do nothing (Avoid sending TCP/IP request to printer)
                              IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLABPB.pls]: At Breadcrumb 30 ', TRACE_PROMPT, TRACE_LEVEL);

                               trace('Custom Labels Trace [INVLABPB.pls]: ERROR: TCP/IP Print Request Not Sent', TRACE_PROMPT, TRACE_LEVEL);
                              END IF;
                            END IF;
                           /*
                            The following piece of the code is now moved after the call TO SYNC_PRINT_TCPIP() above.
                            TCP/IP Print Request will be sent and the history record will now be updated only if there was
                            were no ERROR returned by the get_variable_data() from the relevant Label Type files.

                            IF nvl(l_return_status,'E') <> 'S' THEN
                                 update_history_record(
                                 p_label_request_id => l_variable_data(k).label_request_id
                                ,p_status_flag => 'E'
                                ,p_error_message => l_msg_data);
                            ELSE
                                 trace('update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
                                 update_history_record(
                                 p_label_request_id => l_variable_data(k).label_request_id
                                ,p_status_flag => 'S'
                                ,p_job_status => l_job_status
                                ,p_printer_status => l_printer_status
                                ,p_status_type => l_status_type);
                            END IF;
                           */
                    ELSE
                        IF (l_debug = 1) THEN
                        trace('wrong profile value for WMS_PRINT_MODE = '||G_PROFILE_PRINT_MODE, TRACE_PROMPT, TRACE_LEVEL);
                        END IF;
                    END IF;
             --END IF;
                    -- clear g_xml_content , ready for the next xml
                    g_xml_content := '';
                END LOOP;

            END LOOP LabelTypeLoop2;
        END LOOP InputParamLoop;
    ELSE
        IF (l_debug = 1) THEN
        trace(' Wrong value for p_print_mode ' || p_print_mode , TRACE_PROMPT, TRACE_LEVEL);
        END IF;
    END IF;

    -- Added for R12 RFID Compliance project
    -- Reset the EPC_GROUP_ID
    EPC_GROUP_ID := null;
EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
            trace(' Expected Error In '|| G_PKG_NAME||'.' || l_api_name, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

      WHEN fnd_api.g_exc_unexpected_error THEN
        IF (l_debug = 1) THEN
            trace(' Unexpected Error In '|| G_PKG_NAME||'.' || l_api_name, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

      WHEN others THEN
        IF (l_debug = 1) THEN
            trace(' Other Error In '|| G_PKG_NAME||'.' || l_api_name , TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;

END PRINT_LABEL;


PROCEDURE RESUBMIT_LABEL_REQUEST(
    x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_hist_label_request_id IN NUMBER
,   p_printer_name          IN VARCHAR2
,   p_no_of_copy            IN NUMBER
) IS

    l_api_name VARCHAR2(25) := 'RESUBMIT_LABEL_REQUEST';
    l_return_status VARCHAR2(10);
    l_job_status        VARCHAR2(2000); -- Bug 3328061 increased the size
    l_printer_status    VARCHAR2(2000); -- Bug 3328061 increased the size
    l_status_type       NUMBER;

    l_history_rec WMS_LABEL_REQUESTS_HIST%ROWTYPE;
    CURSOR c_hist IS
    SELECT * FROM wms_label_requests_hist
    WHERE label_request_id = p_hist_label_request_id;

    l_label_content LONG;
    l_printer_name VARCHAR2(50);
    l_no_of_copy NUMBER;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);
    l_sysdate DATE;

BEGIN
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    IF (l_debug = 1) THEN
    trace('In resubmit label request',TRACE_PROMPT, TRACE_LEVEL);
    trace('resubmit, hist_request_id='||p_hist_label_request_id
      ||', printer_name='||p_printer_name
      ||', no_of_copy='||p_no_of_copy,TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_profile_values;
    get_date_time_user;

    OPEN c_hist;
    FETCH c_hist INTO l_history_rec;
    IF c_hist%NOTFOUND THEN
        IF (l_debug = 1) THEN
        trace('Can not find history record with request_id='||p_hist_label_request_id,TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        CLOSE c_hist;
        RAISE fnd_api.g_exc_error;
    ELSE
        CLOSE c_hist;
    END IF;
    IF (l_debug = 1) THEN
    trace('Found history record',TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    -- populate original request id and get new label_request_id;
    l_history_rec.original_request_id := p_hist_label_request_id;
    select wms_label_print_history_s.nextval into l_history_rec.label_request_id
    from dual;
    select sysdate into l_sysdate from dual;
    l_history_rec.request_date := l_sysdate;
    l_history_rec.creation_date := l_sysdate;
    l_history_rec.last_update_date := l_sysdate;

    l_history_rec.request_user_id := fnd_global.user_id;
    l_history_rec.created_by := fnd_global.user_id;
    l_history_rec.last_updated_by := fnd_global.user_id;

    IF (l_debug = 1) THEN
    trace('Set original request ID='||l_history_rec.original_request_id,TRACE_PROMPT, TRACE_LEVEL);
    trace('Set new label_request_id='||l_history_rec.label_request_id, TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    l_history_rec.job_name := G_PROFILE_PREFIX||l_history_rec.label_request_id;

    l_printer_name := p_printer_name;
    --Modified for bug# 9379941 start
    IF ((p_printer_name IS NULL) OR
          (p_printer_name = l_history_rec.printer_name)) THEN
       l_printer_name := NULL;
    END IF;
    l_no_of_copy := p_no_of_copy;
    IF (  (p_no_of_copy IS NULL) OR
          (p_no_of_copy = l_history_rec.no_of_copy) ) THEN
       l_no_of_copy := NULL;
    END IF;
    --Modified for bug# 9379941 end


    --Update the label_content

    l_label_content := update_label_content(
                        l_history_rec.label_content,
                        l_history_rec.job_name,
                        l_printer_name,
                        l_no_of_copy);

    l_history_rec.label_content := l_label_content;
    IF l_printer_name IS NOT NULL THEN
        l_history_rec.printer_name := l_printer_name;
    END IF;
    IF l_no_of_copy IS NOT NULL THEN
        l_history_rec.no_of_copy := l_no_of_copy;
    END IF;

    --Fix for FP Bug: 4629816 Start
    -- Reset the default columns so that new values are recorded

    l_history_rec.error_message     := NULL;
    l_history_rec.status_flag       := NULL;
    l_history_rec.job_status        := NULL;
    l_history_rec.printer_status    := NULL;
    l_history_rec.request_mode_code := G_PROFILE_PRINT_MODE;
    l_history_rec.outfile_directory := G_PROFILE_OUT_DIR;
    l_history_rec.outfile_name      := l_history_rec.job_name || '.xml';

    --Fix for FP Bug: 4629816 End

    IF (l_debug = 1) THEN
    trace('Inserting into history table for the reprint request', TRACE_PROMPT, TRACE_LEVEL);
    END IF;

    insert_history_record(l_history_rec);

    IF (l_debug = 1) THEN
    trace('Send reprint request',TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    IF G_PROFILE_PRINT_MODE = 1 THEN
        -- Synchronize Mode, send request for each label
        IF (l_debug = 1) THEN
        trace('Calling sync_print_req', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        INV_PRINT_REQUEST.SYNC_PRINT_REQUEST(
            p_xml_content       => l_label_content
        ,   x_job_status        => l_job_status
        ,   x_printer_status    => l_printer_status
        ,   x_status_type       => l_status_type
        );

        IF (l_debug = 1) THEN
        trace('Status type returned from the sync_print_req ' ||  l_status_type, TRACE_PROMPT, TRACE_LEVEL);
        trace('update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        update_history_record(
            p_label_request_id => l_history_rec.label_request_id
        ,   p_status_flag => 'S'
        ,   p_job_status => l_job_status
        ,   p_printer_status => l_printer_status
        ,   p_status_type => l_status_type);

    ELSIF G_PROFILE_PRINT_MODE  = 2 THEN
    -- Asynchronize Mode, calling write_xml to write into a xml file
        IF (l_debug = 1) THEN
        trace('Calling WRITE_XML', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        INV_PRINT_REQUEST.WRITE_XML(
            p_xml_content       => l_label_content
        ,   p_request_id        => l_history_rec.label_request_id
        ,   x_return_status     => l_return_status
        ,   x_msg_count     => l_msg_count
        ,   x_msg_data      => l_msg_data
        );

        IF nvl(l_return_status,'E') <> 'S' THEN
            update_history_record(
                p_label_request_id => l_history_rec.label_request_id
            ,   p_status_flag => 'E'
            );

        ELSE
            update_history_record(
                p_label_request_id => l_history_rec.label_request_id
            ,   p_status_flag => 'S'
            ,   p_outfile_name => l_history_rec.job_name ||'.xml'
            ,   p_outfile_directory => G_PROFILE_OUT_DIR
            );

        END IF;
    -- New Printer Mode in Patchset J for Synchronize TCPIP printing
    ELSIF G_PROFILE_PRINT_MODE  = 3 THEN
    -- Synchronize TCPIP Mode, calling SYNC_PRINT_TCPIP to print label through TCPIP mode
        IF (l_debug = 1) THEN
        trace('Calling SYNC_PRINT_TCPIP', TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        INV_PRINT_REQUEST.SYNC_PRINT_TCPIP(
            p_xml_content       => l_label_content
        ,   x_job_status        => l_job_status
        ,   x_printer_status    => l_printer_status
        ,   x_status_type       => l_status_type
        ,   x_return_status     => l_return_status
        ,   x_return_msg        => l_msg_data
        );

        IF (l_debug = 1) THEN
        trace('Called INV_PRINT_REQUEST.SYNC_PRINT_TCPIP', TRACE_PROMPT, TRACE_LEVEL);
        trace('x_return_status='||l_return_status||',x_return_msg='||l_msg_data, TRACE_PROMPT, TRACE_LEVEL);
        trace('x_job_status='||l_job_status||',x_printer_status='||l_printer_status||',x_status_type='||l_status_type, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        IF nvl(l_return_status,'E') <> 'S' THEN
            update_history_record(
                p_label_request_id => l_history_rec.label_request_id
            ,   p_status_flag => 'E'
            ,   p_error_message => l_msg_data
            );

        ELSE
            trace('update WMS_LABEL_REQUEST_HIST record with job status, printer status, status type', TRACE_PROMPT, TRACE_LEVEL);
            update_history_record(
                p_label_request_id => l_history_rec.label_request_id
            ,   p_status_flag => 'S'
            ,   p_job_status => l_job_status
            ,   p_printer_status => l_printer_status
            ,   p_status_type => l_status_type);

        END IF;
    END IF;


EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF (l_debug = 1) THEN
        trace(' Expected Error In '|| G_PKG_NAME||'.' || l_api_name, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        x_return_status := fnd_api.g_ret_sts_error ;

    WHEN fnd_api.g_exc_unexpected_error THEN
        IF (l_debug = 1) THEN
            trace(' Unexpected Error In '|| G_PKG_NAME||'.' || l_api_name, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        x_return_status := fnd_api.g_ret_sts_error ;

    WHEN others THEN
        IF (l_debug = 1) THEN
        trace(' Other Error In '|| G_PKG_NAME||'.' || l_api_name , TRACE_PROMPT, TRACE_LEVEL);
            trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
        trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
        END IF;
        x_return_status := fnd_api.g_ret_sts_error ;

END RESUBMIT_LABEL_REQUEST;

/*************************************
 * Obtain Label Request Print Hist
 *************************************/
PROCEDURE INV_LABEL_REQUESTS_REPRINT (
               x_label_rep_hist_inqs    OUT NOCOPY t_genref,
               p_printer_Name           IN  VARCHAR2,
               p_bus_flow_Code          IN  NUMBER,
               p_label_type_Id          IN  NUMBER,
               p_lpn_Id                 IN  NUMBER,
               p_Requests               IN  NUMBER,
               p_created_By             IN  NUMBER,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2
) IS
BEGIN
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    x_Status := FND_API.G_RET_STS_SUCCESS;
    IF (l_debug = 1) THEN
        trace('Querying label request hist with Printer='|| p_printer_Name||
               ',BusFlow=' || p_bus_flow_Code ||
               ',LabelTypeID=' || p_label_type_Id ||
               ',LPNID=' || p_lpn_Id ||
               ',Requests=' || p_Requests ||
               ',User=' || p_created_By, 'LABEL_REPRINT_QUERY', 9);
    END IF;

    OPEN x_label_rep_hist_inqs FOR
    select request_date, request_time, printer, label_format,
           lpn,  item, bus_flow, label_type, label_request_id
    from
    (select     to_char(wlrh.creation_date, 'DD-MON-YY') request_date,
            to_char(wlrh.creation_date, 'HH:MI:SS') request_time,
            wlrh.printer_name printer,
            wlf.label_format_name label_format,
            wlpn.license_plate_number lpn,
            msik.concatenated_segments item,
            mfglkup1.meaning bus_flow,
            mfglkup2.meaning label_type,
            wlrh.label_request_id label_request_id
    from    wms_label_requests_hist wlrh,
            wms_label_formats wlf,
            wms_license_plate_numbers wlpn,
            mtl_system_items_kfv msik,
            mfg_lookups mfglkup1,
            mfg_lookups mfglkup2
        where   wlrh.label_format_id = wlf.label_format_id (+)
    and     wlrh.lpn_id = wlpn.lpn_id (+)
    and   wlrh.inventory_item_id = msik.inventory_item_id (+)
    and   wlrh.organization_id = msik.organization_id (+)
    and   (wlrh.business_flow_code = mfglkup1.lookup_code (+)
    and   mfglkup1.lookup_type(+) = 'WMS_BUSINESS_FLOW')
    and   (wlrh.label_type_id = mfglkup2.lookup_code (+)
    and   mfglkup2.lookup_type(+) = 'WMS_LABEL_TYPE')
    and   nvl(wlrh.printer_name, '@@@') = nvl(p_printer_Name, nvl(wlrh.printer_name, '@@@'))
    and   nvl(wlrh.business_flow_code, -99) = nvl(p_bus_flow_Code, nvl(wlrh.business_flow_code, -99))
    and   nvl(wlrh.label_type_id, -99) = nvl(p_label_type_Id, nvl(wlrh.label_type_id, -99))
    and   nvl(wlrh.lpn_id, -99) = nvl(p_lpn_Id, nvl(wlrh.lpn_id, -99))
    and   wlrh.created_by = p_created_By
    order by wlrh.creation_date desc) wlrha
    where   rownum <= p_Requests;

        x_Message := 'Selection Criteria Returned Records';
EXCEPTION
    WHEN no_data_found THEN
    x_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_Message := 'Selection Criteria Returned No Records';

    WHEN others THEN
    x_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_Message := 'Selection Criteria Returned No Records';

END INV_LABEL_REQUESTS_REPRINT;


-- Bug #3067059
/**************************************
 * Checks if there is a GTIN defined for the
 * Item + UOM + Rev combination.
 * Also fetches  GTIN and GTIN Desc. if it is
 * defined for the given Org, Item, UOM, Rev
**************************************/
PROCEDURE IS_ITEM_GTIN_ENABLED(
        x_return_status      OUT NOCOPY VARCHAR2
      , x_gtin_enabled       OUT NOCOPY BOOLEAN
      , x_gtin           OUT NOCOPY VARCHAR2
      , x_gtin_desc          OUT NOCOPY VARCHAR2
      , p_organization_id    IN NUMBER
      , p_inventory_item_id  IN NUMBER
      , p_unit_of_measure    IN VARCHAR2
      , p_revision       IN VARCHAR2
)
IS
   l_revision_id  NUMBER;
   l_uom_code VARCHAR2(3);
BEGIN
    trace('p_inventory_item_id  : p_organization_id : p_unit_of_measure : p_revision'
           || p_inventory_item_id ||','||p_organization_id||','||p_unit_of_measure||','||p_revision, TRACE_PROMPT, TRACE_LEVEL);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   G_PROFILE_GTIN  := FND_PROFILE.value('INV:GTIN_CROSS_REFERENCE_TYPE');
   trace('Profile INV:GTIN_CROSS_REFERENCE_TYPE : '||G_PROFILE_GTIN,TRACE_PROMPT, TRACE_LEVEL);
   IF(G_PROFILE_GTIN IS NOT NULL) THEN

      -- Bug 6917861, Bifurcating the code for revision and non-revision controlled items.
      -- Bug 8580309, correcting the fix made through bug 6795743. Replacing by NVL(p_unit_of_measure, NVL(MCR.UOM_CODE,'@@@'))
      --              It used to query all GTIN's defined for an item due to the changes done through bug 6795743
      -- Bug 6795743, replacing NVL(p_unit_of_measure,'@@@') by NVL(MCR.UOM_CODE, NVL(p_unit_of_measure,'@@@'))
      IF (p_revision IS NOT NULL) THEN

          SELECT MCR.CROSS_REFERENCE, MCR.DESCRIPTION, MCR.REVISION_ID, MCR.UOM_CODE
          INTO   x_gtin, x_gtin_desc, l_revision_id, l_uom_code
          FROM   MTL_CROSS_REFERENCES MCR, MTL_ITEM_REVISIONS_B MIR
          WHERE  CROSS_REFERENCE_TYPE  = G_PROFILE_GTIN
            AND  MIR.INVENTORY_ITEM_ID = MCR.INVENTORY_ITEM_ID
            AND  MIR.INVENTORY_ITEM_ID = p_inventory_item_id
            AND  MIR.REVISION_ID       = nvl(MCR.REVISION_ID,MIR.REVISION_ID)
            AND  MIR.REVISION          = p_revision
            AND  (
                   ( MCR.ORG_INDEPENDENT_FLAG = 'Y' AND MCR.ORGANIZATION_ID IS NULL AND MIR.ORGANIZATION_ID = p_organization_id) OR
                   ( MCR.ORG_INDEPENDENT_FLAG = 'N' AND MCR.ORGANIZATION_ID = p_organization_id AND MCR.ORGANIZATION_ID = MIR.ORGANIZATION_ID)
                 )
            AND NVL(MCR.UOM_CODE, NVL(p_unit_of_measure,'@@@')) = NVL(p_unit_of_measure, NVL(MCR.UOM_CODE,'@@@'));

      ELSE

          SELECT MCR.CROSS_REFERENCE, MCR.DESCRIPTION, MCR.REVISION_ID, MCR.UOM_CODE
          INTO   x_gtin, x_gtin_desc, l_revision_id, l_uom_code
          FROM   MTL_CROSS_REFERENCES MCR
          WHERE  CROSS_REFERENCE_TYPE   = G_PROFILE_GTIN
            AND  MCR.INVENTORY_ITEM_ID  = p_inventory_item_id
            AND  MCR.REVISION_ID       IS NULL
            AND  (
                   ( MCR.ORG_INDEPENDENT_FLAG = 'Y' AND MCR.ORGANIZATION_ID IS NULL ) OR
                   ( MCR.ORG_INDEPENDENT_FLAG = 'N' AND MCR.ORGANIZATION_ID = p_organization_id )
                 )
            AND NVL(MCR.UOM_CODE,NVL(p_unit_of_measure,'@@@')) = NVL(p_unit_of_measure, NVL(MCR.UOM_CODE,'@@@'));

      END IF;

      trace('l_revision_id, l_uom_code : '||l_revision_id ||','||l_uom_code, TRACE_PROMPT, TRACE_LEVEL);
      IF(p_revision IS NOT NULL) THEN
      -- revision controlled item
         IF(l_revision_id IS NULL OR l_uom_code IS NULL) THEN
            x_gtin_enabled := FALSE;
         ELSE
            x_gtin_enabled := TRUE;
         END IF;
      ELSE
      -- non-revision controlled item
         IF(l_uom_code IS NULL) THEN
            x_gtin_enabled := FALSE;
         ELSE
            x_gtin_enabled := TRUE;
         END IF;
      END IF;
   END IF;

EXCEPTION
   WHEN no_data_found THEN
   -- this is an expected exception if no cross-reference values defined in mtl_cross_refererences
    x_gtin_enabled := FALSE;
    IF (l_debug = 1) THEN
       trace('No GTIN cross-reference defined ',TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    NULL;
   WHEN OTHERS THEN
    -- When no data found or Mutiple Rows or others l_gtin_enabled := FASLE;
    x_gtin_enabled := FALSE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (l_debug = 1) THEN
       trace('error in IS_ITEM_GTIN_ENABLED',TRACE_PROMPT, TRACE_LEVEL);
       trace('ERROR CODE = ' || SQLCODE, TRACE_PROMPT, TRACE_LEVEL);
       trace('ERROR MESSAGE = ' || SQLERRM, TRACE_PROMPT, TRACE_LEVEL);
    END IF;

END IS_ITEM_GTIN_ENABLED;

--added for lpn status project to get the status of the lpn after the transaction has been commited
FUNCTION get_txn_lpn_status
         (p_lpn_id IN NUMBER,
          p_transaction_id IN NUMBER,
          p_organization_id IN NUMBER,
          p_business_flow IN NUMBER)
          RETURN VARCHAR2 IS
cursor wlc_cur is
          SELECT  wlc.parent_lpn_id ,wlc.inventory_item_id , wlc.lot_number
          FROM    wms_lpn_contents wlc
          WHERE   wlc.parent_lpn_id IN
                  (SELECT lpn_id
                   FROM wms_license_plate_numbers plpn
                   start with lpn_id = p_lpn_id
                   connect by parent_lpn_id = prior lpn_id
                  )
           ORDER BY wlc.serial_summary_entry DESC ;

 CURSOR msnt_cur is
        SELECT msnt.status_id status_id
        FROM mtl_serial_numbers_temp msnt , mtl_serial_numbers msn
        WHERE msnt.transaction_temp_id = p_transaction_id
        AND msnt.status_id is not null
        UNION
        SELECT msn.status_id status_id
        FROM mtl_serial_numbers_temp msnt , mtl_serial_numbers msn
        WHERE msnt.transaction_temp_id = p_transaction_id
        AND msn.serial_number BETWEEN msnt.fm_serial_number AND msnt.to_serial_number
        AND msn.current_organization_id = p_organization_id
        AND msnt.status_id is NULL;

 CURSOR msn_cur(l_lpn_id NUMBER) IS
        SELECT status_id
        FROM mtl_serial_numbers  msn
        WHERE msn.lpn_id = l_lpn_id
        AND msn.current_organization_id = p_organization_id
        AND serial_number not in (select serial_number from
                                  mtl_serial_numbers msn1,mtl_serial_numbers_temp msnt
                                  where msnt.transaction_temp_id = p_transaction_id
                                  and msn1.serial_number BETWEEN msnt.fm_serial_number AND msnt.to_serial_number);

  CURSOR mmtt_cur(l_inventory_item_id NUMBER , l_lot_number VARCHAR2) IS
  SELECT mmtt.organization_id , mmtt.subinventory_code , mmtt.locator_id ,
                 NVL(mmtt.lpn_id,mmtt.content_lpn_id) lpn_id , mmtt.transaction_action_id
          FROM   mtl_material_transactions_temp mmtt
          WHERE  mmtt.transaction_temp_id =p_transaction_id
          AND    mmtt.inventory_item_id = l_inventory_item_id
          AND   Nvl(mmtt.item_lot_control_code,-99) <> 2
          UNION
SELECT mmtt.organization_id , mmtt.subinventory_code , mmtt.locator_id ,
                 NVL(mmtt.lpn_id,mmtt.content_lpn_id) lpn_id , mmtt.transaction_action_id
          FROM   mtl_material_transactions_temp mmtt , mtl_transaction_lots_temp mtlt
          WHERE  mmtt.transaction_temp_id =p_transaction_id
          AND    mmtt.inventory_item_id = l_inventory_item_id
          AND   Nvl(mmtt.item_lot_control_code,-99) = 2
          AND   mtlt.transaction_temp_id = mmtt.transaction_temp_id
          AND    nvl(mtlt.lot_number,'@@@@') = nvl(l_lot_number,'@@@@');

       l_return_status_id NUMBER;
       l_return_status_code VARCHAR2(30);
       l_organization_id NUMBER;
       l_subinventory_code  VARCHAR2(30);
       l_locator_id NUMBER ;
       l_lpn_context NUMBER;
       l_counter NUMBER := 0;
       l_src_status NUMBER;
       l_src_locator_id NUMBER;
       l_src_organization_id NUMBER;
       l_src_subinventory_code VARCHAR2(30);
       l_status_id NUMBER;
       l_lpn_id NUMBER;
       l_transaction_action_id NUMBER;
       l_src_lpn_id NUMBER;
       l_query_mmtt NUMBER := 1;
       l_serial_status_enabled NUMBER := 0;
       l_serial_controlled NUMBER := 0;
       l_lot_number VARCHAR2(30) := NULL;
       l_inventory_item_id NUMBER;
BEGIN
   l_organization_id := p_organization_id;

    IF(l_debug=1) THEN
      trace('inside get_txn_lpn_status', TRACE_PROMPT, TRACE_LEVEL);
    END IF;

 SELECT wlpn.lpn_context ,  wlpn.subinventory_code , wlpn.locator_id
 INTO l_lpn_context ,  l_subinventory_code , l_locator_id
 FROM wms_license_plate_numbers wlpn
 WHERE wlpn.lpn_id = p_lpn_id;
 IF l_lpn_context IN  (WMS_Container_PUB.LPN_CONTEXT_PREGENERATED,
                       WMS_Container_PUB.LPN_CONTEXT_VENDOR,
                       WMS_Container_PUB.LPN_CONTEXT_STORES,
                       WMS_Container_PUB.LPN_CONTEXT_INTRANSIT ,
                       WMS_Container_PUB.LPN_CONTEXT_PACKING,
                       WMS_Container_PUB.LPN_CONTEXT_WIP,
                       WMS_Container_PUB.LPN_CONTEXT_RCV
                       )
                       OR (p_transaction_id is NULL)
                       OR (p_business_flow in (1,2,3,4))THEN
                       -- no need to check src status for these transaction so calling get_lpn_status

    IF(l_debug=1) THEN
           trace('calling get_lpn_status', TRACE_PROMPT, TRACE_LEVEL);
    END IF;
    INV_MATERIAL_STATUS_GRP.get_lpn_status
            (
            p_organization_id =>l_organization_id,
            p_lpn_id =>p_lpn_id ,
            p_sub_code =>l_subinventory_code ,
            p_loc_id =>l_locator_id           ,
            p_lpn_context=>l_lpn_context       ,
            x_return_status_id=> l_return_status_id,
            x_return_status_code=> l_return_status_code
            );
    RETURN l_return_status_code;


 ELSE
 --need to check source status for all other type of stauses

    FOR l_wlc_cur in wlc_cur LOOP
       --inside wlc loop
       l_serial_controlled := 0;
       l_serial_status_enabled := 0;
       l_src_status := NULL;
       l_transaction_action_id := NULL;
       IF inv_cache.set_item_rec(l_organization_id, l_wlc_cur.inventory_item_id) THEN
          IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                l_serial_controlled := 1; -- Item is serial controlled
          END IF;
          IF (NVL(inv_cache.item_rec.serial_status_enabled,'Y') = 'Y') THEN
               l_serial_status_enabled := 1;
          END IF;
       END IF;
      FOR l_mmtt_cur in mmtt_cur(l_wlc_cur.inventory_item_id , l_wlc_cur.lot_number) loop
            l_transaction_action_id := l_mmtt_cur.transaction_action_id;
            IF (l_serial_controlled = 1) THEN
              IF (l_serial_status_enabled = 1) THEN
                  FOR l_msnt_cur IN msnt_cur LOOP
                       --item is serial controlled and status is also enabled therefore calling msnt_cur
                      l_counter := l_counter + 1;
                      l_return_status_id := l_msnt_cur.status_id;
                      IF(l_counter = 1 ) THEN
                         IF(l_debug=1) THEN
                          trace('status returned for first time from 1  = '||l_return_status_id, TRACE_PROMPT, TRACE_LEVEL);
                         END IF;
                        l_status_id := l_return_status_id;
                      END IF;
                      IF (l_return_status_id <> l_status_id) THEN
                         l_return_status_id := -1;
                          IF(l_debug=1) THEN
                            trace('lpn has status mixed so exiting 1', TRACE_PROMPT, TRACE_LEVEL);
                          END IF;
                          EXIT;
                      END IF;
                  END LOOP;
              END IF;



        ELSE
          IF l_transaction_action_id IN (inv_globals.G_ACTION_SUBXFR,
                                         inv_globals.G_ACTION_ORGXFR,
                                         inv_globals.G_ACTION_STGXFR,
                                         inv_globals.G_ACTION_CONTAINERPACK,
                                         inv_globals.G_ACTION_CONTAINERUNPACK) THEN
            BEGIN
                    IF(l_debug=1) THEN
                    trace(' querying moqd for the source status', TRACE_PROMPT, TRACE_LEVEL);
                    trace ('source organization_id = '||l_mmtt_cur.organization_id, TRACE_PROMPT, TRACE_LEVEL);
                    trace ('source subinventory = '||l_mmtt_cur.subinventory_code, TRACE_PROMPT, TRACE_LEVEL);
                    trace ('source locator_id = '||l_mmtt_cur.locator_id, TRACE_PROMPT, TRACE_LEVEL);
                    trace ('source lpn is = '||l_mmtt_cur.lpn_id, TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
                    SELECT moqd.status_id into l_src_status
                    FROM mtl_onhand_quantities_detail moqd
                    WHERE moqd.inventory_item_id = l_wlc_cur.inventory_item_id
                    AND moqd.organization_id = l_mmtt_cur.organization_id
                    AND nvl(moqd.lpn_id,-9999) = Nvl(l_mmtt_cur.lpn_id,-9999)
                    AND moqd.subinventory_code = l_mmtt_cur.subinventory_code
                    AND NVL(moqd.locator_id,-9999) = NVL(l_mmtt_cur.locator_id,-9999)
                    AND NVL(moqd.lot_number,'@@@@') = NVL(l_wlc_cur.lot_number,'@@@@')
                    AND ROWNUM = 1;
            EXCEPTION
                    WHEN No_Data_Found THEN
                    l_src_status := NULL;
                    if(l_debug = 1)THEN
                    trace('here p_src_status_id =>' || l_src_status, TRACE_PROMPT, TRACE_LEVEL);
                    END IF;
            END;
         END IF;
        END IF;


      END LOOP;
       IF (NVL(l_return_status_id , 0)<>-1)THEN
         --came here to check for the rest of the data
           IF(l_debug=1) THEN
           trace(' came here 1', TRACE_PROMPT, TRACE_LEVEL);
           END IF;
         IF(l_serial_controlled<>1) THEN
            l_counter := l_counter + 1;
            IF(l_debug=1) THEN
            trace('not serial controlled so calling INV_MATERIAL_STATUS_GRP.get_default_status', TRACE_PROMPT, TRACE_LEVEL);
            END IF;

            l_return_status_id := INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                                            (p_organization_id   => l_organization_id,
                                            p_inventory_item_id => l_wlc_cur.inventory_item_id,
                                            p_sub_code => l_subinventory_code,
                                            p_loc_id => l_locator_id,
                                            p_lot_number => l_wlc_cur.lot_number,
                                            p_lpn_id => p_lpn_id,
                                            p_transaction_action_id=> l_transaction_action_id,
                                            p_src_status_id => l_src_status);
      --END;
             IF(l_counter = 1) THEN
                  IF(l_debug=1) THEN
                    trace('status returned for first time from 2= '||l_return_status_id, TRACE_PROMPT, TRACE_LEVEL);
                  END IF;
                 l_status_id := l_return_status_id;
             END IF;
             IF (l_return_status_id <> l_status_id) THEN
                 l_return_status_id := -1;
                  IF(l_debug=1) THEN
                       trace('lpn has status mixed so exiting 2', TRACE_PROMPT, TRACE_LEVEL);
                  END IF ;
             END IF;
          ELSE
            IF(l_serial_status_enabled = 1) THEN
               FOR l_msn_cur IN msn_cur(l_wlc_cur.parent_lpn_id) LOOP
                  l_counter := l_counter + 1;
                  l_return_status_id := l_msn_cur.status_id;
                  IF (l_counter = 1) THEN
                      IF(l_debug=1) THEN
                    trace('status returned for first time from 3 = '||l_return_status_id, TRACE_PROMPT, TRACE_LEVEL);
                     END IF;
                     l_status_id := l_return_status_id;
                   END IF;
                  IF (l_return_status_id <> l_status_id) THEN
                      IF(l_debug=1) THEN
                       trace('lpn has status mixed so exiting 3', TRACE_PROMPT, TRACE_LEVEL);
                      END IF;
                     l_return_status_id := -1;
                     EXIT;
                  END IF;
               END LOOP;
             END IF;
          END IF;
        END IF;
       IF (l_return_status_id = -1)THEN
            EXIT;
       END IF;
     END LOOP;
  END IF;
     IF (l_return_status_id IS NOT NULL AND l_return_status_id <>-1) THEN
      BEGIN
          SELECT status_code into l_return_status_code
          from mtl_material_statuses
          where status_id = l_return_status_id;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
          l_return_status_code := NULL;
     END;

          ELSIF l_return_status_id = -1 THEN
              l_return_status_code := fnd_message.get_string('WMS', 'WMS_LPN_STATUS_MIXED');
          ELSE
              l_return_status_code := NULL;
          END IF;


     RETURN l_return_status_code;
END get_txn_lpn_status ;


END INV_LABEL;

/
