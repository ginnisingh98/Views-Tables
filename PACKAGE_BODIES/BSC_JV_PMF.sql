--------------------------------------------------------
--  DDL for Package Body BSC_JV_PMF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_JV_PMF" AS
/* $Header: BSCJPFB.pls 120.0 2005/06/01 16:06:56 appldev noship $ */

PROCEDURE get_pmf_measure(
    p_Measure_ShortName      IN   VARCHAR2,
    x_function_name          OUT NOCOPY  VARCHAR2,
    x_region_code            OUT NOCOPY  VARCHAR2
) IS

    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);
    l_Measure_ID                  NUMBER ;
    l_Measure_Short_Name          VARCHAR2(30);
    l_Measure_Name                bsc_sys_datasets_tl.name%TYPE;
    l_Description                 bsc_sys_datasets_tl.help%TYPE;
    l_Dimension1_ID               NUMBER  ;
    l_Dimension2_ID               NUMBER  ;
    l_Dimension3_ID               NUMBER  ;
    l_Dimension4_ID               NUMBER  ;
    l_Dimension5_ID               NUMBER  ;
    l_Dimension6_ID               NUMBER  ;
    l_Dimension7_ID               NUMBER  ;
    l_Unit_Of_Measure_Class       VARCHAR2(10) ;
    l_actual_data_source_type     VARCHAR2(30) ;
    l_actual_data_source          VARCHAR2(240);
    l_attribute_code              VARCHAR2(240);
    l_function_name               VARCHAR2(240) ;
    l_comparison_source           VARCHAR2(240) ;
    l_increase_in_measure         VARCHAR2(1);

    l_index NUMBER;
    l_region_code          VARCHAR2(240);
BEGIN

--dbms_output.put_line('before calling BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure, p_Measure_ShortName=>' || p_Measure_ShortName);

 BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure(p_Measure_Short_Name =>  p_Measure_ShortName
     ,x_return_status => l_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data   => l_msg_data
     ,x_Measure_ID  => l_Measure_ID
     ,x_Measure_Short_Name  => l_Measure_Short_Name
     ,x_Measure_Name      => l_Measure_Name
     ,x_Description       => l_Description
     ,x_Dimension1_ID     => l_Dimension1_ID
     ,x_Dimension2_ID     => l_Dimension2_ID
     ,x_Dimension3_ID     => l_Dimension3_ID
     ,x_Dimension4_ID     => l_Dimension4_ID
     ,x_Dimension5_ID     => l_Dimension5_ID
     ,x_Dimension6_ID     => l_Dimension6_ID
     ,x_Dimension7_ID    => l_Dimension7_ID
     ,x_Unit_Of_Measure_Class    => l_Unit_Of_Measure_Class
     ,x_actual_data_source_type  => l_actual_data_source_type
     ,x_actual_data_source   => l_actual_data_source
     ,x_region_code    =>       x_region_code
     ,x_attribute_code      => l_attribute_code
     ,x_function_name         => x_function_name
     ,x_comparison_source     => l_comparison_source
     ,x_increase_in_measure   => l_increase_in_measure);


--     l_index := INSTRB(l_actual_data_source, '.', 1);
 --    x_region_code := SUBSTRB(l_actual_data_source, l_index+1);


    --dbms_output.put_line('l_actual_data_source=>' || l_actual_data_source);
    --dbms_output.put_line('region=' || x_region_code);
    --dbms_output.put_line('x_function_name=>' || x_function_name);

END get_pmf_measure;




PROCEDURE get_pmf_measure(
    p_Measure_ShortName      IN   VARCHAR2,
    x_function_name          OUT NOCOPY  VARCHAR2,
    x_region_code            OUT NOCOPY  VARCHAR2,
    x_graph_no               OUT NOCOPY NUMBER
) IS

    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);
    l_Measure_ID                  NUMBER ;
    l_Measure_Short_Name          VARCHAR2(30);
    l_Measure_Name                bsc_sys_datasets_tl.name%TYPE;
    l_Description                 bsc_sys_datasets_tl.help%TYPE;
    l_Dimension1_ID               NUMBER  ;
    l_Dimension2_ID               NUMBER  ;
    l_Dimension3_ID               NUMBER  ;
    l_Dimension4_ID               NUMBER  ;
    l_Dimension5_ID               NUMBER  ;
    l_Dimension6_ID               NUMBER  ;
    l_Dimension7_ID               NUMBER  ;
    l_Unit_Of_Measure_Class       VARCHAR2(10) ;
    l_actual_data_source_type     VARCHAR2(30) ;
    l_actual_data_source          VARCHAR2(240);
    l_attribute_code              VARCHAR2(240);
    l_function_name               VARCHAR2(240) ;
    l_comparison_source           VARCHAR2(240) ;
    l_increase_in_measure         VARCHAR2(1);

    l_graph_no NUMBER;
    l_region_code          VARCHAR2(240);


BEGIN

--dbms_output.put_line('before calling BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure, p_Measure_ShortName=>' || p_Measure_ShortName);


  BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure(p_Measure_Short_Name =>  p_Measure_ShortName
     ,x_return_status => l_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data   => l_msg_data
     ,x_Measure_ID  => l_Measure_ID
     ,x_Measure_Short_Name  => l_Measure_Short_Name
     ,x_Measure_Name      => l_Measure_Name
     ,x_Description       => l_Description
     ,x_Dimension1_ID     => l_Dimension1_ID
     ,x_Dimension2_ID     => l_Dimension2_ID
     ,x_Dimension3_ID     => l_Dimension3_ID
     ,x_Dimension4_ID     => l_Dimension4_ID
     ,x_Dimension5_ID     => l_Dimension5_ID
     ,x_Dimension6_ID     => l_Dimension6_ID
     ,x_Dimension7_ID    => l_Dimension7_ID
     ,x_Unit_Of_Measure_Class    => l_Unit_Of_Measure_Class
     ,x_actual_data_source_type  => l_actual_data_source_type
     ,x_actual_data_source   => l_actual_data_source
     ,x_region_code    =>       x_region_code
     ,x_attribute_code      => l_attribute_code
     ,x_function_name         => x_function_name
     ,x_comparison_source     => l_comparison_source
     ,x_increase_in_measure   => l_increase_in_measure);


    IF ( (x_region_code IS NULL ) OR ( l_attribute_code IS NULL) ) THEN
      RETURN;
    END IF;

    -- both region code and attribute code is not null
    -- find the graph number for this measure

    SELECT attribute5 INTO x_graph_no
    FROM ak_region_items
    WHERE region_code = x_region_code
    AND ATTRIBUTE_CODE = l_attribute_code;

    IF ( x_graph_no IS NULL) THEN
      x_graph_no := 1;  -- default to 1
    END IF;

    --dbms_output.put_line('l_actual_data_source=>' || l_actual_data_source);
    --dbms_output.put_line('region=' || x_region_code);
    --dbms_output.put_line('x_function_name=>' || x_function_name);

END get_pmf_measure;



END bsc_jv_pmf;

/
