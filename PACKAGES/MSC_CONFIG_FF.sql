--------------------------------------------------------
--  DDL for Package MSC_CONFIG_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CONFIG_FF" AUTHID CURRENT_USER AS
/* $Header: MSCCONFS.pls 115.20 2003/10/13 01:07:10 jarora ship $ */


PROCEDURE Configure_forecast_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        item_attr1              IN  NUMBER default null,
        org_attr1               IN  NUMBER default null,
        cust_attr1              IN  NUMBER default null);

PROCEDURE Configure(
	ERRBUF      	OUT NOCOPY VARCHAR2,
	RETCODE     	OUT NOCOPY NUMBER,
	item_attr1		IN  NUMBER default null,
	item_attr2		IN  NUMBER default null,
	org_attr1		IN  NUMBER default null,
	org_attr2		IN  NUMBER default null,
	org_attr3		IN  NUMBER default null,
	org_attr4		IN  NUMBER default null,
	dept_attr1		IN  NUMBER default null,
	dept_attr2		IN  NUMBER default null,
	supp_attr1		IN  NUMBER default null,
	subst_attr1		IN  NUMBER default null,
	trans_attr1		IN  NUMBER default null,
	bom_attr1		IN  NUMBER default null,
	forecast_attr1	        IN  NUMBER default null,
	line_attr1		IN  NUMBER default null,
        schedule_attr1          IN  NUMBER default null
);

PROCEDURE Configure_strn_flex(
	ERRBUF      	OUT NOCOPY VARCHAR2,
	RETCODE     	OUT NOCOPY NUMBER,
	oper_attr1		IN  NUMBER);

PROCEDURE Configure_reba_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        bom_attr1       IN NUMBER,
        bom_attr2       IN NUMBER,
        bom_attr3       IN NUMBER,
        bom_attr4       IN NUMBER,
        bom_attr5       IN NUMBER);

PROCEDURE Configure_fcst_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        fcst_attr1      IN NUMBER);

PROCEDURE Configure_regions_flex(
        ERRBUF          OUT NOCOPY VARCHAR2,
        RETCODE         OUT NOCOPY NUMBER,
        oper_attr1      IN NUMBER);

END MSC_CONFIG_FF;

 

/
