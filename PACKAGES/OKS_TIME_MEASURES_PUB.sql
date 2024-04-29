--------------------------------------------------------
--  DDL for Package OKS_TIME_MEASURES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_TIME_MEASURES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSSTQTS.pls 120.2 2005/07/07 01:53:36 jvorugan noship $ */

-----------------------------------------------------------------------------

  G_APP_NAME		  CONSTANT  VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN         CONSTANT  varchar2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN         CONSTANT  varchar2(200) := 'SQLcode';
  G_DATE_ERROR            CONSTANT  varchar2(200) := 'OKC_INVALID_START_END_DATES';
  G_COL_NAME_TOKEN	  CONSTANT  VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PKG_NAME		  CONSTANT  VARCHAR2(200) := 'OKC_TIME_UTIL_PVT';
  G_INVALID_VALUE	  CONSTANT  VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR      CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';



-----------------------------------------------------------------------------

function get_target_qty (p_start_date  IN DATE DEFAULT NULL,
                         p_source_qty  IN NUMBER,
                         p_source_uom  IN VARCHAR2,
                         p_target_uom  IN VARCHAR2,
                         p_round_dec   IN NUMBER)
return NUMBER;

function get_target_qty_cal(p_start_date   IN DATE,
                            p_end_date     IN DATE,
                            p_price_uom    IN VARCHAR2,
                            p_period_type  IN VARCHAR2,
                            p_round_dec    IN NUMBER)

return NUMBER;

function get_target_qty_service(p_start_date   IN DATE,
                                p_end_date     IN DATE,
                                p_price_uom    IN VARCHAR2,
                                p_period_type  IN VARCHAR2,
                                p_round_dec    IN NUMBER)

return NUMBER;

function get_partial_period_duration (p_start_date   IN DATE,
                                      p_end_date     IN DATE,
                                      p_price_uom    IN VARCHAR2,
                                      p_period_type  IN VARCHAR2,
                                      p_period_start IN VARCHAR2)

return NUMBER;

PROCEDURE get_full_periods (p_start_date            IN  DATE,
                            p_end_date              IN  DATE,
                            p_price_uom             IN  VARCHAR2,
                            x_full_periods          OUT NOCOPY NUMBER,
                            x_full_period_end_date OUT NOCOPY DATE,
                            x_return_status         OUT NOCOPY VARCHAR2);

function get_con_factor(p_source_uom IN VARCHAR2,
                         p_target_uom IN VARCHAR2)
return NUMBER;


function get_qty_for_days(p_no_days     IN NUMBER,
                          p_target_uom  IN VARCHAR2)
return NUMBER;


function get_quantity(p_start_date    IN DATE,
                      p_end_date      IN DATE,
                      p_source_uom    IN VARCHAR2 DEFAULT NULL,
		      p_period_type   IN VARCHAR2 DEFAULT NULL,
		      p_period_start  IN VARCHAR2 DEFAULT NULL)
return NUMBER;

function get_uom_code(p_tce_code      IN VARCHAR2
                     ,p_quantity      IN NUMBER)
return VARCHAR2;

procedure get_duration_uom ( p_start_date        IN DATE
                           , p_end_date          IN DATE
                           , x_duration      OUT NOCOPY NUMBER
                           , x_timeunit      OUT NOCOPY VARCHAR2
                           , x_return_status OUT NOCOPY VARCHAR2);


function get_months_between(p_start_date    IN DATE,
                            p_end_date      IN DATE)
return NUMBER;

END OKS_TIME_MEASURES_PUB ;

 

/
