--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_SUMMARY_PKG" as
/* $Header: cefssumb.pls 120.1 2002/11/12 21:26:16 bhchung ship $ */
PROCEDURE select_summary( X_forecast_id NUMBER,
                R_total0        IN OUT NOCOPY NUMBER,
                R_total1        IN OUT NOCOPY NUMBER, R_total2        IN OUT NOCOPY NUMBER,
                R_total3        IN OUT NOCOPY NUMBER, R_total4        IN OUT NOCOPY NUMBER,
                R_total5        IN OUT NOCOPY NUMBER, R_total6        IN OUT NOCOPY NUMBER,
                R_total7        IN OUT NOCOPY NUMBER, R_total8        IN OUT NOCOPY NUMBER,
                R_total9        IN OUT NOCOPY NUMBER, R_total10       IN OUT NOCOPY NUMBER,
                R_total11       IN OUT NOCOPY NUMBER, R_total12       IN OUT NOCOPY NUMBER,
                R_total13       IN OUT NOCOPY NUMBER, R_total14       IN OUT NOCOPY NUMBER,
                R_total15       IN OUT NOCOPY NUMBER, R_total16       IN OUT NOCOPY NUMBER,
                R_total17       IN OUT NOCOPY NUMBER, R_total18       IN OUT NOCOPY NUMBER,
                R_total19       IN OUT NOCOPY NUMBER, R_total20       IN OUT NOCOPY NUMBER,
                R_total21       IN OUT NOCOPY NUMBER, R_total22       IN OUT NOCOPY NUMBER,
                R_total23       IN OUT NOCOPY NUMBER, R_total24       IN OUT NOCOPY NUMBER,
                R_total25       IN OUT NOCOPY NUMBER, R_total26       IN OUT NOCOPY NUMBER,
                R_total27       IN OUT NOCOPY NUMBER, R_total28       IN OUT NOCOPY NUMBER,
                R_total29       IN OUT NOCOPY NUMBER, R_total30       IN OUT NOCOPY NUMBER,
                R_total31       IN OUT NOCOPY NUMBER, R_total32       IN OUT NOCOPY NUMBER,
                R_total33       IN OUT NOCOPY NUMBER, R_total34       IN OUT NOCOPY NUMBER,
                R_total35       IN OUT NOCOPY NUMBER, R_total36       IN OUT NOCOPY NUMBER,
                R_total37       IN OUT NOCOPY NUMBER, R_total38       IN OUT NOCOPY NUMBER,
                R_total39       IN OUT NOCOPY NUMBER, R_total40       IN OUT NOCOPY NUMBER,
                E_total0        IN OUT NOCOPY NUMBER,
                E_total1        IN OUT NOCOPY NUMBER, E_total2        IN OUT NOCOPY NUMBER,
                E_total3        IN OUT NOCOPY NUMBER, E_total4        IN OUT NOCOPY NUMBER,
                E_total5        IN OUT NOCOPY NUMBER, E_total6        IN OUT NOCOPY NUMBER,
                E_total7        IN OUT NOCOPY NUMBER, E_total8        IN OUT NOCOPY NUMBER,
                E_total9        IN OUT NOCOPY NUMBER, E_total10       IN OUT NOCOPY NUMBER,
                E_total11       IN OUT NOCOPY NUMBER, E_total12       IN OUT NOCOPY NUMBER,
                E_total13       IN OUT NOCOPY NUMBER, E_total14       IN OUT NOCOPY NUMBER,
                E_total15       IN OUT NOCOPY NUMBER, E_total16       IN OUT NOCOPY NUMBER,
                E_total17       IN OUT NOCOPY NUMBER, E_total18       IN OUT NOCOPY NUMBER,
                E_total19       IN OUT NOCOPY NUMBER, E_total20       IN OUT NOCOPY NUMBER,
                E_total21       IN OUT NOCOPY NUMBER, E_total22       IN OUT NOCOPY NUMBER,
                E_total23       IN OUT NOCOPY NUMBER, E_total24       IN OUT NOCOPY NUMBER,
                E_total25       IN OUT NOCOPY NUMBER, E_total26       IN OUT NOCOPY NUMBER,
                E_total27       IN OUT NOCOPY NUMBER, E_total28       IN OUT NOCOPY NUMBER,
                E_total29       IN OUT NOCOPY NUMBER, E_total30       IN OUT NOCOPY NUMBER,
                E_total31       IN OUT NOCOPY NUMBER, E_total32       IN OUT NOCOPY NUMBER,
                E_total33       IN OUT NOCOPY NUMBER, E_total34       IN OUT NOCOPY NUMBER,
                E_total35       IN OUT NOCOPY NUMBER, E_total36       IN OUT NOCOPY NUMBER,
                E_total37       IN OUT NOCOPY NUMBER, E_total38       IN OUT NOCOPY NUMBER,
                E_total39       IN OUT NOCOPY NUMBER, E_total40       IN OUT NOCOPY NUMBER) IS
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
    SELECT	sum(column0),
		sum(column1), sum(column2), sum(column3), sum(column4), sum(column5),
                sum(column6), sum(column7), sum(column8), sum(column9), sum(column10),
                sum(column11), sum(column12), sum(column13), sum(column14), sum(column15),
                sum(column16), sum(column17), sum(column18), sum(column19), sum(column20),
                sum(column21), sum(column22), sum(column23), sum(column24), sum(column25),
                sum(column26), sum(column27), sum(column28), sum(column29), sum(column30),
                sum(column31), sum(column32), sum(column33), sum(column34), sum(column35),
                sum(column36), sum(column37), sum(column38), sum(column39), sum(column40)
    INTO	R_total0, R_total1, R_total2, R_total3, R_total4, R_total5,
                R_total6, R_total7, R_total8, R_total9, R_total10,
                R_total11, R_total12, R_total13, R_total14, R_total15,
                R_total16, R_total17, R_total18, R_total19, R_total20,
                R_total21, R_total22, R_total23, R_total24, R_total25,
                R_total26, R_total27, R_total28, R_total29, R_total30,
                R_total31, R_total32, R_total33, R_total34, R_total35,
                R_total36, R_total37, R_total38, R_total39, R_total40
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('ARI', 'ARR', 'ASF', 'UDI', 'OEO', 'OII', 'XTR');

    select      sum(column0),
                sum(column1), sum(column2), sum(column3), sum(column4), sum(column5),
                sum(column6), sum(column7), sum(column8), sum(column9), sum(column10),
                sum(column11), sum(column12), sum(column13), sum(column14), sum(column15),
                sum(column16), sum(column17), sum(column18), sum(column19), sum(column20),
                sum(column21), sum(column22), sum(column23), sum(column24), sum(column25),
                sum(column26), sum(column27), sum(column28), sum(column29), sum(column30),
                sum(column31), sum(column32), sum(column33), sum(column34), sum(column35),
                sum(column36), sum(column37), sum(column38), sum(column39), sum(column40)
    INTO        E_total0, E_total1, E_total2, E_total3, E_total4, E_total5,
                E_total6, E_total7, E_total8, E_total9, E_total10,
                E_total11, E_total12, E_total13, E_total14, E_total15,
                E_total16, E_total17, E_total18, E_total19, E_total20,
                E_total21, E_total22, E_total23, E_total24, E_total25,
                E_total26, E_total27, E_total28, E_total29, E_total30,
                E_total31, E_total32, E_total33, E_total34, E_total35,
                E_total36, E_total37, E_total38, E_total39, E_total40
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('APP', 'API', 'UDO',
                             'APX', 'PAY', 'POP', 'POR', 'OIO');
  ELSE
    SELECT	sum(column0),
		sum(column1), sum(column2), sum(column3), sum(column4), sum(column5),
                sum(column6), sum(column7), sum(column8), sum(column9), sum(column10),
                sum(column11), sum(column12), sum(column13), sum(column14), sum(column15),
                sum(column16), sum(column17), sum(column18), sum(column19), sum(column20),
                sum(column21), sum(column22), sum(column23), sum(column24), sum(column25),
                sum(column26), sum(column27), sum(column28), sum(column29), sum(column30),
                sum(column31), sum(column32), sum(column33), sum(column34), sum(column35),
                sum(column36), sum(column37), sum(column38), sum(column39), sum(column40)
    INTO	R_total0, R_total1, R_total2, R_total3, R_total4, R_total5,
                R_total6, R_total7, R_total8, R_total9, R_total10,
                R_total11, R_total12, R_total13, R_total14, R_total15,
                R_total16, R_total17, R_total18, R_total19, R_total20,
                R_total21, R_total22, R_total23, R_total24, R_total25,
                R_total26, R_total27, R_total28, R_total29, R_total30,
                R_total31, R_total32, R_total33, R_total34, R_total35,
                R_total36, R_total37, R_total38, R_total39, R_total40
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('ARI', 'PAI', 'PAB', 'UDI', 'OEO', 'OII');

    select      sum(column0),
                sum(column1), sum(column2), sum(column3), sum(column4), sum(column5),
                sum(column6), sum(column7), sum(column8), sum(column9), sum(column10),
                sum(column11), sum(column12), sum(column13), sum(column14), sum(column15),
                sum(column16), sum(column17), sum(column18), sum(column19), sum(column20),
                sum(column21), sum(column22), sum(column23), sum(column24), sum(column25),
                sum(column26), sum(column27), sum(column28), sum(column29), sum(column30),
                sum(column31), sum(column32), sum(column33), sum(column34), sum(column35),
                sum(column36), sum(column37), sum(column38), sum(column39), sum(column40)
    INTO        E_total0, E_total1, E_total2, E_total3, E_total4, E_total5,
                E_total6, E_total7, E_total8, E_total9, E_total10,
                E_total11, E_total12, E_total13, E_total14, E_total15,
                E_total16, E_total17, E_total18, E_total19, E_total20,
                E_total21, E_total22, E_total23, E_total24, E_total25,
                E_total26, E_total27, E_total28, E_total29, E_total30,
                E_total31, E_total32, E_total33, E_total34, E_total35,
                E_total36, E_total37, E_total38, E_total39, E_total40
    FROM        CE_FORECAST_SUMMARY_V
    WHERE       forecast_id = X_forecast_id
    AND         TRX_TYPE IN ('API', 'PAO', 'PAT', 'UDO',
                             'APX', 'POP', 'POR', 'OIO');
  END IF;

  IF R_total0 IS NULL THEN
    R_total0 := 0;  R_total1 := 0; R_total2 := 0; R_total3 := 0; R_total4 := 0; R_total5 := 0;
    R_total6 := 0; R_total7 := 0; R_total8 := 0; R_total9 := 0; R_total10 := 0;
    R_total11 := 0; R_total12 := 0; R_total13 := 0; R_total14 := 0; R_total15 := 0;
    R_total16 := 0; R_total17 := 0; R_total18 := 0; R_total19 := 0; R_total20 := 0;
    R_total21 := 0; R_total22 := 0; R_total23 := 0; R_total24 := 0; R_total25 := 0;
    R_total26 := 0; R_total27 := 0; R_total28 := 0; R_total29 := 0; R_total30 := 0;
    R_total31 := 0; R_total32 := 0; R_total33 := 0; R_total34 := 0; R_total35 := 0;
    R_total36 := 0; R_total37 := 0; R_total38 := 0; R_total39 := 0; R_total40 := 0;
  ELSIF E_total0 IS NULL THEN
    E_total0 := 0; E_total1 := 0; E_total2 := 0; E_total3 := 0; E_total4 := 0; E_total5 := 0;
    E_total6 := 0; E_total7 := 0; E_total8 := 0; E_total9 := 0; E_total10 := 0;
    E_total11 := 0; E_total12 := 0; E_total13 := 0; E_total14 := 0; E_total15 := 0;
    E_total16 := 0; E_total17 := 0; E_total18 := 0; E_total19 := 0; E_total20 := 0;
    E_total21 := 0; E_total22 := 0; E_total23 := 0; E_total24 := 0; E_total25 := 0;
    E_total26 := 0; E_total27 := 0; E_total28 := 0; E_total29 := 0; E_total30 := 0;
    E_total31 := 0; E_total32 := 0; E_total33 := 0; E_total34 := 0; E_total35 := 0;
    E_total36 := 0; E_total37 := 0; E_total38 := 0; E_total39 := 0; E_total40 := 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

END CE_FORECAST_SUMMARY_PKG;

/
