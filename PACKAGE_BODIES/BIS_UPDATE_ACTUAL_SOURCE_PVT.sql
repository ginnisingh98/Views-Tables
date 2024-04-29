--------------------------------------------------------
--  DDL for Package Body BIS_UPDATE_ACTUAL_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_UPDATE_ACTUAL_SOURCE_PVT" AS
/* $Header: BISVUASB.pls 120.0 2005/06/01 16:35:49 appldev noship $ */

Procedure Update_Actual_Source IS

  CURSOR c_measure_data_source IS
    SELECT a.indicator_id,
           a.short_name,
	   ak.region_code,
	   ak.attribute_code
      FROM  bis_indicators a, bsc_sys_datasets_b b, ak_region_items ak
      WHERE a.dataset_id = b.dataset_id
      AND   a.actual_data_source IS NULL
      AND   b.source = 'PMF'
      AND   ak.attribute1 = 'MEASURE'
      AND   ak.attribute2 = a.short_name;

  l_actual_data_source     VARCHAR2(300);

BEGIN
  FOR measure_data_source_rec IN c_measure_data_source LOOP

    IF measure_data_source_rec.region_code IS NOT NULL AND measure_data_source_rec.attribute_code IS NOT NULL THEN
      l_actual_data_source := measure_data_source_rec.region_code || '.' || measure_data_source_rec.attribute_code;
    END IF;

    IF(l_actual_data_source IS NOT NULL) THEN
      UPDATE bis_indicators SET actual_data_source_type = 'AK'
                              , actual_data_source = l_actual_data_source
        WHERE  short_name = measure_data_source_rec.short_name;
    END IF;

    l_actual_data_source := NULL;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Update_Actual_Source;

PROCEDURE updt_func_types_bistar AS
  CURSOR c_updt IS SELECT type , parameters , function_id
   FROM fnd_form_functions
   WHERE type = 'BISTAR' FOR UPDATE OF type , parameters;

  x_return_status          VARCHAR2(10);
BEGIN
  FOR i IN c_updt LOOP
    IF (i.parameters IS NULL OR i.parameters NOT LIKE '%pFunctionType=BISTAR%') THEN
      UPDATE fnd_form_functions SET type = NULL ,
      parameters = parameters||fnd_global.local_chr(38)||'pFunctionType=BISTAR'
      WHERE current of c_updt;
    ELSE
      UPDATE fnd_form_functions SET type = NULL
      WHERE current of c_updt;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF c_updt%ISOPEN THEN
      CLOSE c_updt;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END updt_func_types_bistar ;

END BIS_UPDATE_ACTUAL_SOURCE_PVT;

/
