--------------------------------------------------------
--  DDL for Package Body WSH_ITM_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_RESPONSE_PKG" AS
/* $Header: WSHITRAB.pls 120.0.12010000.2 2010/02/16 17:22:54 skanduku ship $ */

    SUCCESS            CONSTANT VARCHAR2(10) := 'SUCCESS';
    DATA_ERROR         CONSTANT VARCHAR2(10) := 'DATA';
    SYSTEM_ERROR       CONSTANT VARCHAR2(10) := 'SYSTEM';
    -- Name
    --   INTERPRET_ERROR
    --
    -- Purpose
    --   Internal. On passing the interpreted error, it sets the result code.
    --
    -- Arguments
    --   p_fetch_interpreted_code      Interpreted code got from the rule
    --   x_interpreted_code            Interpreted code to be returned

    PROCEDURE INTERPRET_ERROR
    (
        p_fetch_interpreted_code   IN     WSH_ITM_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE,
        x_interpreted_code         IN OUT NOCOPY  WSH_ITM_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE
    ) IS

    BEGIN
        --Bug9277386:In response classification, an Error can be classified as 'FAILURE'.
        --           Considering 'FAILURE' as 'SYSTEM' Error.

        IF p_fetch_interpreted_code = SYSTEM_ERROR OR p_fetch_interpreted_code = 'FAILURE' THEN
            x_interpreted_code := SYSTEM_ERROR;
        ELSIF p_fetch_interpreted_code = DATA_ERROR AND nvl(x_interpreted_code,'X') <> SYSTEM_ERROR THEN
            x_interpreted_code := DATA_ERROR;
        END IF;
    END;


    PROCEDURE ONT_RESPONSE_ANALYSER
    (
        p_request_control_id     IN     NUMBER,
        x_interpreted_value      OUT NOCOPY     VARCHAR2,
        x_SrvTab                 OUT NOCOPY     WSH_ITM_RESPONSE_PKG.SrvTabTyp,
        x_return_status          OUT NOCOPY     VARCHAR2
    )
    IS

    l_fetch_interpreted_code  WSH_ITM_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE;
    l_fetch_error_code        WSH_ITM_RESPONSE_LINES.ERROR_CODE%TYPE;
    l_fetch_error_type        WSH_ITM_RESPONSE_LINES.ERROR_TYPE%TYPE;
    l_response_hdr_id         NUMBER;
    l_vendor_id               NUMBER;
    l_sql_error               VARCHAR2(2000);
    --AJPRABHA - Modified service_type to VARCHAR(30)
    l_service_type            VARCHAR2(30);
    l_exp_Compl_Resl	       VARCHAR2(30);
    i                         NUMBER := 0;


    CURSOR Get_Response_Header( req_control_id NUMBER) IS
        SELECT wrh.response_header_id,
            wrh.vendor_id,
            wrh.error_type,
            wrh.error_code,
            wrr.interpreted_value_code,
            wrh.EXPORT_COMPLIANCE_STATUS,
            wrh.SERVICE_TYPE_CODE
        FROM   WSH_ITM_REQUEST_CONTROL WRC,
            WSH_ITM_RESPONSE_HEADERS WRH,
            WSH_ITM_RESPONSE_RULES WRR
        WHERE  wrc.request_control_id = req_control_id
            AND    wrc.response_header_id = wrh.response_header_id
            AND    nvl(wrh.error_code,-99) = nvl(wrr.error_code,nvl(wrh.error_code,-99))
            AND    wrh.error_type = wrr.error_type(+)
            AND    wrh.vendor_id = wrr.vendor_id(+);


    CURSOR Get_Response_Line( resp_header_id NUMBER) IS
        SELECT response_line_id,
            error_code error_code,
            error_type error_type,
            denied_party_flag,
            embargo_flag,
            service_type_code
        FROM   WSH_ITM_RESPONSE_LINES
        WHERE  response_header_id = resp_header_id
        ORDER BY  service_type_code;

    CURSOR Get_Interpreted_code(p_error_code VARCHAR2, p_error_type VARCHAR2,
                            p_vendor_id NUMBER) IS
        SELECT interpreted_value_code
        FROM   WSH_ITM_RESPONSE_RULES
        WHERE  error_type = p_error_type
            AND    nvl(error_code,-99) = nvl(p_error_code,nvl(error_code,-99))
            AND    vendor_id = p_vendor_id
            ORDER BY error_code;

    BEGIN
        OE_DEBUG_PUB.Add('***Inside the procedure ONT_RESPONSE_ANALYSER***');

        x_return_status             := FND_API.G_RET_STS_SUCCESS;

        OPEN Get_Response_Header(p_request_control_id);
        FETCH Get_Response_Header INTO
            l_response_hdr_id,
            l_vendor_id,
            l_fetch_error_type,
            l_fetch_error_code,
            l_fetch_interpreted_code,
            l_exp_Compl_Resl,
            l_service_type;

        IF Get_Response_Header%NOTFOUND THEN
            OE_DEBUG_PUB.Add('Request Control is not Found');
            --Invalid trans control
            x_interpreted_value:= SYSTEM_ERROR;
            CLOSE Get_Response_Header;
            RETURN;
        END IF;
        CLOSE Get_Response_Header;

        OE_DEBUG_PUB.Add('Procesing Response Header :' || l_response_hdr_id);
        IF l_fetch_interpreted_code is NULL THEN

            IF l_fetch_error_type IS NULL AND
                l_fetch_error_code IS NULL THEN
                ---------------------------------------------------------
                --  Error Code and Error Type is NULL in Response Headers
                --  Interpreted Value will be SUCCESS
                ---------------------------------------------------------
                OE_DEBUG_PUB.Add('Error code and Error Type is Response Headers is null');
                x_interpreted_value := SUCCESS;
            ELSE
                --Bug 9277386:If response rule is not defined, default to SYSTEM ERROR
                ---------------------------------------------------------------
                --  If not Response Rule is defined, then default in SYSTEM ERROR
                ---------------------------------------------------------------
                OE_DEBUG_PUB.Add('Error in the Request Control. There is no Rule Defined');
                x_interpreted_value := SYSTEM_ERROR;
            END IF;
        ELSE

            OE_DEBUG_PUB.Add('Interpreted Error from Get_Response_Headers Cursor - ' || l_fetch_interpreted_code );
            OE_DEBUG_PUB.Add('Calling PROCEDURE Interpret_Error');

            interpret_error(l_fetch_interpreted_code, x_interpreted_value ) ;
            IF(x_interpreted_value = SYSTEM_ERROR) THEN
                OE_DEBUG_PUB.Add('Procedure Interpret_Error returned SYSTEM Error');
                RETURN;
            END IF;

        END IF;
        i := 1;
        --Added by AJPRABHA for OM_EXPORT_COMPLIANCE
        IF (l_exp_Compl_Resl IS NOT NULL and l_service_type='OM_EXPORT_COMPLIANCE') THEN

        OE_DEBUG_PUB.Add('For Service OM_EXPORT_COMPLIANCE');
        x_SrvTab(i).Service_Type 	:= 	'OM_EXPORT_COMPLIANCE';

        IF (l_exp_Compl_Resl = 'NOT_COMPLIANT') THEN
            x_SrvTab(i).Service_Result	:=	'Y';
            OE_DEBUG_PUB.Add('Done with EXPORT_COMPLIANCE : ' || l_exp_Compl_Resl);
            RETURN;
        END IF;

        END IF;
        i := 0; --Resetting the index for Other Services.
        --End of Code added by AJPRABHA

        --Fix for bug #3876344 for setting ServiceType to apply hold for DP.
        l_service_type := 'X';
        FOR resp IN Get_Response_Line(l_response_hdr_id) LOOP

            OE_DEBUG_PUB.Add('Processing Line :' || resp.response_line_id);

            IF ((resp.error_code is not NULL) OR (resp.error_type is not NULL)) THEN

                OPEN Get_Interpreted_code(resp.error_code, resp.error_type, l_vendor_id);
                FETCH Get_Interpreted_code INTO l_fetch_interpreted_code;

                IF l_fetch_interpreted_code is null THEN     --Rule not found
                    x_interpreted_value := SYSTEM_ERROR;  --Bug 9277386 : Default is SYSTEM ERROR
                    OE_DEBUG_PUB.Add('Response Line Error, Rule Not Found for interrepted code '||l_fetch_interpreted_code);
                    OE_DEBUG_PUB.Add(' -> Error Code : ' || resp.error_code);
                    OE_DEBUG_PUB.Add(' -> Error Type :  '|| resp.error_type );
                END IF;
                CLOSE Get_Interpreted_Code;

                OE_DEBUG_PUB.Add('Reponse Line Error, Interpreted Code - ' || l_fetch_interpreted_code );
                OE_DEBUG_PUB.Add('Calling PROCEDURE Interpret_Error');

                interpret_error(l_fetch_interpreted_code, x_interpreted_value);
                --Bug9277386:When response Status is 'ERROR', and error code is not specified, default to SYSTEM_ERROR
            ELSE
                IF  l_exp_Compl_Resl = 'ERROR' THEN
                    x_interpreted_value := SYSTEM_ERROR;
                    RETURN;
                END IF;
            END IF;

            IF (nvl(l_service_type,'X') <> resp.service_type_code and l_service_type <> 'WSH_EXPORT_COMPLIANCE') THEN

                OE_DEBUG_PUB.Add('Service Type for Response Line ' || resp.response_line_id || ' is '|| resp.service_type_code);
                i := i + 1;
                l_service_type := resp.service_type_code;
                x_SrvTab(i).Service_Type := resp.service_type_code;
                x_SrvTab(i).Service_Result := 'N';
            END IF;

            IF l_service_type = 'DP' AND
                resp.denied_party_flag = 'Y' THEN
                OE_DEBUG_PUB.Add('Denied Party is found' );
                x_SrvTab(i).Service_Result := 'Y';
            ELSIF
                l_service_type = 'EM' AND
                resp.embargo_flag = 'Y' THEN
                OE_DEBUG_PUB.Add('Embargo is found' );
                x_SrvTab(i).Service_Result := 'Y';
            END IF;

            IF(x_interpreted_value = SYSTEM_ERROR) THEN
                RETURN;
            END IF;

        END LOOP;

        IF x_interpreted_value = SUCCESS THEN
            UPDATE wsh_itm_request_control
                SET process_flag = 1
                WHERE request_control_id = p_request_control_id;
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                l_sql_error := SQLERRM;
                OE_DEBUG_PUB.Add('Processing Failed with an Error');
                OE_DEBUG_PUB.Add('The unexpected error is :' || l_sql_error);
                x_interpreted_value := SYSTEM_ERROR;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END ONT_RESPONSE_ANALYSER;

    PROCEDURE ONT_RESPONSE_ANALYSER
    (
        p_reference_id      IN  NUMBER,
        p_reference_line_id IN  NUMBER,
        x_interpreted_value  OUT NOCOPY  VARCHAR2,
        x_SrvTab             OUT NOCOPY  WSH_ITM_RESPONSE_PKG.SrvTabTyp,
        x_return_status      OUT NOCOPY  VARCHAR2
    ) IS
    CURSOR Get_Request_Control IS
        SELECT
            DISTINCT wrc.request_control_id
        FROM
            WSH_ITM_REQUEST_CONTROL wrc,
            WSH_ITM_RESPONSE_HEADERS wrh,
            WSH_ITM_PARTIES wp
        WHERE
            wrc.response_header_id  = wrh.response_header_id
            AND     wrc.request_control_id  = wp.request_control_id
            AND     wrc.original_system_reference = nvl(p_reference_id, wrc.original_system_reference)
            AND     wrc.original_system_line_reference = nvl ( p_reference_line_id, wrc.original_system_line_reference)
            AND     wrc.process_flag  IN (1,2)
        UNION
        SELECT
            DISTINCT wrc.request_control_id
        FROM
            WSH_ITM_REQUEST_CONTROL wrc,
            WSH_ITM_RESPONSE_HEADERS wrh,
            WSH_ITM_RESPONSE_LINES wrl,
            WSH_ITM_PARTIES wp
        WHERE
            wrc.response_header_id  = wrh.response_header_id
            AND     wrh.response_header_id  = wrl.response_header_id
            AND     wrc.request_control_id  = wp.request_control_id
            AND     wrc.original_system_reference = nvl(p_reference_id, wrc.original_system_reference)
            AND     wrc.original_system_line_reference = nvl ( p_reference_line_id, wrc.original_system_line_reference)
            AND     wrc.process_flag IN (1,2);

    BEGIN
        OE_DEBUG_PUB.Add('Inside ONT_RESPONSE_ANALYSER');
        ------------------------------------------
        -- Print the values of all the parameters.
        ------------------------------------------
        OE_DEBUG_PUB.Add('Reference ID ' || p_reference_id);
        OE_DEBUG_PUB.Add('Reference Line ID ' || p_reference_line_id);

        FOR cur_rec in Get_Request_Control LOOP
            OE_DEBUG_PUB.Add(' Calling ONT_RESPONSE_ANALYSER for reqID' || cur_rec.request_control_id);

            ONT_RESPONSE_ANALYSER (
                p_request_control_id => cur_rec.request_control_id,
                x_interpreted_value => x_interpreted_value,
                x_return_status     => x_return_status,
                x_SrvTab            => x_SrvTab
            );
        END LOOP;
        OE_DEBUG_PUB.Add(' Done with ONT_RESPONSE_ANALYSER');

    END ONT_RESPONSE_ANALYSER;

END WSH_ITM_RESPONSE_PKG;

/
