--------------------------------------------------------
--  DDL for Package PA_ALLOC_COPY_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ALLOC_COPY_RULE_PKG" AUTHID CURRENT_USER AS
/*  $Header: PAXALCRS.pls 120.1 2005/08/09 11:18:52 dlanka noship $ */

procedure COPY_RULE(p_rule_id in number
                ,p_to_rule_name in varchar2
                ,p_to_description in varchar2
                ,x_retcode out NOCOPY varchar2
                ,x_errbuf  out NOCOPY  varchar2);
END PA_ALLOC_COPY_RULE_PKG;

 

/
