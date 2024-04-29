--------------------------------------------------------
--  DDL for Package CE_FORECAST_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: cefssums.pls 120.1 2002/11/12 21:34:30 bhchung ship $ */
  PROCEDURE select_summary(X_forecast_id       NUMBER,
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
                        E_total39       IN OUT NOCOPY NUMBER, E_total40       IN OUT NOCOPY NUMBER);

END CE_FORECAST_SUMMARY_PKG;

 

/
