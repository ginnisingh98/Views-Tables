--------------------------------------------------------
--  DDL for Package Body ASO_LINE_NUM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_LINE_NUM_INT" as
/* $Header: asoilnmb.pls 120.1.12010000.3 2016/08/27 16:54:28 akushwah ship $ */
-- Start of Comments
-- Package name     : aso_line_num_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
--private variable declaration

 G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_LINE_NUM_INT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoilnmb.pls';

    -- Declare counter variables and Interim pl/sql table for line number
    l_top_group number := 0;
    l_cmp_group number := 0;
    l_svc_group number := 0;


    TYPE Line_Number_Tbl_Type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

    Internal_Line_Number_Tbl  Line_Number_Tbl_Type;


    PROCEDURE RESET_LINE_NUM is
    BEGIN

	   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Inside RESET_LINE_NUM procedure');
        END IF;

        l_top_group := 0;
        l_cmp_group := 0;
        l_svc_group := 0;

        Internal_Line_Number_Tbl.Delete;

    END RESET_LINE_NUM;



    PROCEDURE ASO_UI_LINE_NUMBER(
        P_In_Line_Number_Tbl        IN             ASO_LINE_NUM_INT.In_Line_Number_Tbl_Type,
        X_Out_Line_Number_Tbl       OUT NOCOPY /* file.sql.39 change */              ASO_LINE_NUM_INT.Out_Line_Number_Tbl_Type
        )
    IS

    l_temp_line_tbl     ASO_LINE_NUM_INT.Line_Tbl_Type;
    l_quote_header_id   NUMBER;

    CURSOR C_quote_header_id IS
    SELECT quote_header_id FROM ASO_QUOTE_LINES_ALL
    WHERE  quote_line_id = P_In_Line_Number_Tbl(1).Quote_Line_ID;

    CURSOR C_Line_Detail (P_QUOTE_HEADER_ID NUMBER) IS
    SELECT  quote_line_id, ui_line_number
    FROM    ASO_PVT_QUOTE_LINES_BALI_V
    WHERE   quote_header_id  = p_quote_header_id;

	l_mo_id NUMBER; -- code added for Bug 24533047

    BEGIN

	    l_mo_id := mo_global.get_current_org_id; -- code added for Bug 24533047

		MO_GLOBAL.INIT('ASO');

		aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('P_In_Line_Number_Tbl.count: '||P_In_Line_Number_Tbl.count);
            aso_debug_pub.add('Internal_Line_Number_Tbl.count: '||Internal_Line_Number_Tbl.count);
        END IF;

        IF Internal_Line_Number_Tbl.count = 0 THEN

            OPEN C_quote_header_id;
            FETCH C_quote_header_id INTO l_quote_header_id;
            CLOSE C_quote_header_id;

            FOR row IN C_Line_Detail( l_quote_header_id ) LOOP

                Internal_Line_Number_Tbl(row.quote_line_id) := row.ui_line_number;
                X_Out_Line_Number_Tbl(row.quote_line_id)    := row.ui_line_number;

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                    aso_debug_pub.add('Inside IF cond Internal_Line_Number_Tbl('||row.quote_line_id||'): '||Internal_Line_Number_Tbl(row.quote_line_id));
                    aso_debug_pub.add('Inside IF cond X_Out_Line_Number_Tbl('||row.quote_line_id||'): '||X_Out_Line_Number_Tbl(row.quote_line_id));

                END IF;

            END LOOP;

        ELSE

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Inside ELSE cond Internal_Line_Number_Tbl.count: '||Internal_Line_Number_Tbl.count);
            END IF;

            FOR i IN 1..P_In_Line_Number_Tbl.Count  LOOP

                X_Out_Line_Number_Tbl(P_In_Line_Number_Tbl(i).quote_line_id)   := Internal_Line_Number_Tbl(P_In_Line_Number_Tbl(i).quote_line_id);

			 IF aso_debug_pub.g_debug_flag = 'Y' THEN

                    aso_debug_pub.add('Inside ELSE cond P_In_Line_Number_Tbl('||i||').quote_line_id: '||P_In_Line_Number_Tbl(i).quote_line_id );
                    aso_debug_pub.add('Inside ELSE cond X_Out_Line_Number_Tbl('||P_In_Line_Number_Tbl(i).quote_line_id||'): '||X_Out_Line_Number_Tbl(P_In_Line_Number_Tbl(i).quote_line_id));

                END IF;

            END LOOP;

        END IF;

		MO_GLOBAL.set_policy_context('S', l_mo_id) ; -- code added for Bug 24533047

    END ASO_UI_LINE_NUMBER;


    FUNCTION ASO_QUOTE_LINE_NUMBER(
        p_quote_line_id             in  number,
        p_item_type_code            in  varchar2,
        p_serviceable_product_flag  in  varchar2,
        p_service_item_flag         in  varchar2,
        p_service_ref_type_code     in  varchar2,
        p_config_header_id          in  number,
        p_config_revision_num       in  number
        )
    RETURN VARCHAR2
    is
       l_type varchar2(10);
    begin
      /*
      if ( p_rownum = p_quote_line_id ) then

          aso_debug_pub.SetDebugLevel(10);
          aso_debug_pub.G_DIR :='/sqlcom/crmeco/asodev/temp';
          dbms_output.put_line('The File is'|| aso_debug_pub.Set_Debug_Mode('FILE'));
          aso_debug_pub.Initialize;
          aso_debug_pub.debug_on;

    	  l_top_group := 0;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;
      end if;
      */

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('p_item_type_code = ' || p_item_type_code,1,'Y');
          aso_debug_pub.add('p_serviceable_product_flag = ' || p_serviceable_product_flag,1,'Y');
          aso_debug_pub.add('p_service_item_flag = ' || p_service_item_flag,1,'Y');
          aso_debug_pub.add('p_config_header_id = ' || p_config_header_id,1,'Y');
          aso_debug_pub.add('p_config_revision_num = ' ||p_config_revision_num ,1,'Y');
          aso_debug_pub.add('p_quote_line_id = ' || p_quote_line_id,1,'Y');

      END IF;

      if ( p_item_type_code = 'STD' ) then
    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));

      elsif ( NVL(p_serviceable_product_flag,'N') = 'Y' and p_item_type_code <> 'MDL' and  p_item_type_code <> 'CFG') then

    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( p_item_type_code = 'MDL' and p_config_header_id IS NULL AND p_config_revision_num IS NULL ) then
    	  l_top_group := l_top_group+1;
          l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

          return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( p_item_type_code = 'MDL' and p_config_header_id IS NOT NULL AND p_config_revision_num IS NOT NULL ) then
    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( NVL(p_service_item_flag,'N') = 'Y' and NVL(p_service_ref_type_code,'NULL') <> 'QUOTE' ) then
    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( NVL(p_service_item_flag,'N') = 'Y' and NVL(p_service_ref_type_code,'NULL') = 'QUOTE'  ) then
    	  l_svc_group := l_svc_group + 1;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group)||'.'||to_char(l_svc_group));
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group)||'.'||to_char(l_svc_group));
      elsif ( p_item_type_code = 'CFG' ) then
    	  l_cmp_group := l_cmp_group + 1;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
	  END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( p_item_type_code = 'OPT' ) then
    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      elsif ( p_item_type_code = 'PLN' ) then
    	  l_top_group := l_top_group+1;
    	  l_cmp_group := 0;
    	  l_svc_group := 0;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(to_char(l_top_group)||'.'||to_char(l_cmp_group),1,'Y');
       END IF;

    	  return(to_char(l_top_group)||'.'||to_char(l_cmp_group));
      end if;
	 return to_char(-1);
    end ASO_QUOTE_LINE_NUMBER;


    FUNCTION Get_UI_Line_Number(
        P_Quote_Line_Id             IN  NUMBER
        )
    RETURN VARCHAR2 IS

     l_number      VARCHAR2(40);

    BEGIN

    l_number := Internal_Line_Number_Tbl(p_quote_line_id);

    RETURN l_number;

    END Get_UI_Line_Number;


END ASO_LINE_NUM_INT;

/
