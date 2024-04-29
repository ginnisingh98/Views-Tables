--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_SUMMARY2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_SUMMARY2_PKG" as
/* $Header: cefsum2b.pls 120.1 2002/11/12 21:34:37 bhchung ship $ */
PROCEDURE select_summary( X_forecast_id NUMBER,
                R_total41       IN OUT NOCOPY NUMBER, R_total42       IN OUT NOCOPY NUMBER,
                R_total43       IN OUT NOCOPY NUMBER, R_total44       IN OUT NOCOPY NUMBER,
                R_total45       IN OUT NOCOPY NUMBER, R_total46       IN OUT NOCOPY NUMBER,
                R_total47       IN OUT NOCOPY NUMBER, R_total48       IN OUT NOCOPY NUMBER,
                R_total49       IN OUT NOCOPY NUMBER, R_total50       IN OUT NOCOPY NUMBER,
                R_total51       IN OUT NOCOPY NUMBER, R_total52       IN OUT NOCOPY NUMBER,
                R_total53       IN OUT NOCOPY NUMBER, R_total54       IN OUT NOCOPY NUMBER,
                R_total55       IN OUT NOCOPY NUMBER, R_total56       IN OUT NOCOPY NUMBER,
                R_total57       IN OUT NOCOPY NUMBER, R_total58       IN OUT NOCOPY NUMBER,
                R_total59       IN OUT NOCOPY NUMBER, R_total60       IN OUT NOCOPY NUMBER,
                R_total61       IN OUT NOCOPY NUMBER, R_total62       IN OUT NOCOPY NUMBER,
                R_total63       IN OUT NOCOPY NUMBER, R_total64       IN OUT NOCOPY NUMBER,
                R_total65       IN OUT NOCOPY NUMBER, R_total66       IN OUT NOCOPY NUMBER,
                R_total67       IN OUT NOCOPY NUMBER, R_total68       IN OUT NOCOPY NUMBER,
                R_total69       IN OUT NOCOPY NUMBER, R_total70       IN OUT NOCOPY NUMBER,
                R_total71       IN OUT NOCOPY NUMBER, R_total72       IN OUT NOCOPY NUMBER,
                R_total73       IN OUT NOCOPY NUMBER, R_total74       IN OUT NOCOPY NUMBER,
                R_total75       IN OUT NOCOPY NUMBER, R_total76       IN OUT NOCOPY NUMBER,
                R_total77       IN OUT NOCOPY NUMBER, R_total78       IN OUT NOCOPY NUMBER,
                R_total79       IN OUT NOCOPY NUMBER, R_total80       IN OUT NOCOPY NUMBER,
                E_total41       IN OUT NOCOPY NUMBER, E_total42       IN OUT NOCOPY NUMBER,
                E_total43       IN OUT NOCOPY NUMBER, E_total44       IN OUT NOCOPY NUMBER,
                E_total45       IN OUT NOCOPY NUMBER, E_total46       IN OUT NOCOPY NUMBER,
                E_total47       IN OUT NOCOPY NUMBER, E_total48       IN OUT NOCOPY NUMBER,
                E_total49       IN OUT NOCOPY NUMBER, E_total50       IN OUT NOCOPY NUMBER,
                E_total51       IN OUT NOCOPY NUMBER, E_total52       IN OUT NOCOPY NUMBER,
                E_total53       IN OUT NOCOPY NUMBER, E_total54       IN OUT NOCOPY NUMBER,
                E_total55       IN OUT NOCOPY NUMBER, E_total56       IN OUT NOCOPY NUMBER,
                E_total57       IN OUT NOCOPY NUMBER, E_total58       IN OUT NOCOPY NUMBER,
                E_total59       IN OUT NOCOPY NUMBER, E_total60       IN OUT NOCOPY NUMBER,
                E_total61       IN OUT NOCOPY NUMBER, E_total62       IN OUT NOCOPY NUMBER,
                E_total63       IN OUT NOCOPY NUMBER, E_total64       IN OUT NOCOPY NUMBER,
                E_total65       IN OUT NOCOPY NUMBER, E_total66       IN OUT NOCOPY NUMBER,
                E_total67       IN OUT NOCOPY NUMBER, E_total68       IN OUT NOCOPY NUMBER,
                E_total69       IN OUT NOCOPY NUMBER, E_total70       IN OUT NOCOPY NUMBER,
                E_total71       IN OUT NOCOPY NUMBER, E_total72       IN OUT NOCOPY NUMBER,
                E_total73       IN OUT NOCOPY NUMBER, E_total74       IN OUT NOCOPY NUMBER,
                E_total75       IN OUT NOCOPY NUMBER, E_total76       IN OUT NOCOPY NUMBER,
                E_total77       IN OUT NOCOPY NUMBER, E_total78       IN OUT NOCOPY NUMBER,
                E_total79       IN OUT NOCOPY NUMBER, E_total80       IN OUT NOCOPY NUMBER) IS
  CURSOR C_project IS
    SELECT project_id
    FROM   ce_forecasts_v
    WHERE  forecast_id = X_forecast_id;
  l_dummy	NUMBER;
BEGIN
  OPEN C_project;
  FETCH C_project INTO l_dummy;
  CLOSE C_project;

  IF l_dummy IS NULL THEN
    select      sum(column41), sum(column42), sum(column43), sum(column44), sum(column45),
                sum(column46), sum(column47), sum(column48), sum(column49), sum(column50),
                sum(column51), sum(column52), sum(column53), sum(column54), sum(column55),
                sum(column56), sum(column57), sum(column58), sum(column59), sum(column60),
		sum(column61), sum(column62), sum(column63), sum(column64), sum(column65),
		sum(column66), sum(column67), sum(column68), sum(column69), sum(column70),
		sum(column71), sum(column72), sum(column73), sum(column74), sum(column75),
		sum(column76), sum(column77), sum(column78), sum(column79), sum(column80)
    into        R_total41, R_total42, R_total43, R_total44, R_total45,
                R_total46, R_total47, R_total48, R_total49, R_total50,
                R_total51, R_total52, R_total53, R_total54, R_total55,
                R_total56, R_total57, R_total58, R_total59, R_total60,
		R_total61, R_total62, R_total63, R_total64, R_total65,
		R_total66, R_total67, R_total68, R_total69, R_total70,
		R_total71, R_total72, R_total73, R_total74, R_total75,
		R_total76, R_total77, R_total78, R_total79, R_total80
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('ARI', 'ARR', 'ASF', 'UDI', 'OEO', 'XTR', 'OII');

    select      sum(column41), sum(column42), sum(column43), sum(column44), sum(column45),
                sum(column46), sum(column47), sum(column48), sum(column49), sum(column50),
                sum(column51), sum(column52), sum(column53), sum(column54), sum(column55),
                sum(column56), sum(column57), sum(column58), sum(column59), sum(column60),
		sum(column61), sum(column62), sum(column63), sum(column64), sum(column65),
		sum(column66), sum(column67), sum(column68), sum(column69), sum(column70),
		sum(column71), sum(column72), sum(column73), sum(column74), sum(column75),
		sum(column76), sum(column77), sum(column78), sum(column79), sum(column80)
    into        E_total41, E_total42, E_total43, E_total44, E_total45,
                E_total46, E_total47, E_total48, E_total49, E_total50,
                E_total51, E_total52, E_total53, E_total54, E_total55,
                E_total56, E_total57, E_total58, E_total59, E_total60,
		E_total61, E_total62, E_total63, E_total64, E_total65,
		E_total66, E_total67, E_total68, E_total69, E_total70,
		E_total71, E_total72, E_total73, E_total74, E_total75,
		E_total76, E_total77, E_total78, E_total79, E_total80
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('APP', 'API', 'UDO',
                             'APX', 'PAY', 'POP', 'POR', 'OIO');
  ELSE
    select      sum(column41), sum(column42), sum(column43), sum(column44), sum(column45),
                sum(column46), sum(column47), sum(column48), sum(column49), sum(column50),
                sum(column51), sum(column52), sum(column53), sum(column54), sum(column55),
                sum(column56), sum(column57), sum(column58), sum(column59), sum(column60),
		sum(column61), sum(column62), sum(column63), sum(column64), sum(column65),
		sum(column66), sum(column67), sum(column68), sum(column69), sum(column70),
		sum(column71), sum(column72), sum(column73), sum(column74), sum(column75),
		sum(column76), sum(column77), sum(column78), sum(column79), sum(column80)
    into        R_total41, R_total42, R_total43, R_total44, R_total45,
                R_total46, R_total47, R_total48, R_total49, R_total50,
                R_total51, R_total52, R_total53, R_total54, R_total55,
                R_total56, R_total57, R_total58, R_total59, R_total60,
		R_total61, R_total62, R_total63, R_total64, R_total65,
		R_total66, R_total67, R_total68, R_total69, R_total70,
		R_total71, R_total72, R_total73, R_total74, R_total75,
		R_total76, R_total77, R_total78, R_total79, R_total80
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('ARI', 'PAI', 'PAB', 'UDI', 'OEO', 'OII');

    select      sum(column41), sum(column42), sum(column43), sum(column44), sum(column45),
                sum(column46), sum(column47), sum(column48), sum(column49), sum(column50),
                sum(column51), sum(column52), sum(column53), sum(column54), sum(column55),
                sum(column56), sum(column57), sum(column58), sum(column59), sum(column60),
		sum(column61), sum(column62), sum(column63), sum(column64), sum(column65),
		sum(column66), sum(column67), sum(column68), sum(column69), sum(column70),
		sum(column71), sum(column72), sum(column73), sum(column74), sum(column75),
		sum(column76), sum(column77), sum(column78), sum(column79), sum(column80)
    into        E_total41, E_total42, E_total43, E_total44, E_total45,
                E_total46, E_total47, E_total48, E_total49, E_total50,
                E_total51, E_total52, E_total53, E_total54, E_total55,
                E_total56, E_total57, E_total58, E_total59, E_total60,
		E_total61, E_total62, E_total63, E_total64, E_total65,
		E_total66, E_total67, E_total68, E_total69, E_total70,
		E_total71, E_total72, E_total73, E_total74, E_total75,
		E_total76, E_total77, E_total78, E_total79, E_total80
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('API', 'PAO', 'PAT', 'UDO',
                             'APX', 'POP', 'POR', 'OIO');
  END IF;

  IF R_total41 IS NULL THEN
    R_total41 := 0; R_total42 := 0; R_total43 := 0; R_total44 := 0; R_total45 := 0;
    R_total46 := 0; R_total47 := 0; R_total48 := 0; R_total49 := 0; R_total50 := 0;
    R_total51 := 0; R_total52 := 0; R_total53 := 0; R_total54 := 0; R_total55 := 0;
    R_total61 := 0; R_total62 := 0; R_total63 := 0; R_total64 := 0; R_total65 := 0;
    R_total66 := 0; R_total67 := 0; R_total68 := 0; R_total69 := 0; R_total70 := 0;
    R_total71 := 0; R_total72 := 0; R_total73 := 0; R_total74 := 0; R_total75 := 0;
    R_total76 := 0; R_total77 := 0; R_total78 := 0; R_total79 := 0; R_total80 := 0;
  ELSIF E_total41 IS NULL THEN
    E_total41 := 0; E_total42 := 0; E_total43 := 0; E_total44 := 0; E_total45 := 0;
    E_total46 := 0; E_total47 := 0; E_total48 := 0; E_total49 := 0; E_total50 := 0;
    E_total51 := 0; E_total52 := 0; E_total53 := 0; E_total54 := 0; E_total55 := 0;
    E_total56 := 0; E_total57 := 0; E_total58 := 0; E_total59 := 0; E_total60 := 0;
    E_total61 := 0; E_total62 := 0; E_total63 := 0; E_total64 := 0; E_total65 := 0;
    E_total66 := 0; E_total67 := 0; E_total68 := 0; E_total69 := 0; E_total70 := 0;
    E_total71 := 0; E_total72 := 0; E_total73 := 0; E_total74 := 0; E_total75 := 0;
    E_total76 := 0; E_total77 := 0; E_total78 := 0; E_total79 := 0; E_total80 := 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

END CE_FORECAST_SUMMARY2_PKG;

/
