--------------------------------------------------------
--  DDL for Package AD_JAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_JAR" AUTHID CURRENT_USER as
/* $Header: ADJRIS.pls 120.1.12010000.3 2013/06/16 19:37:51 mkumandu noship $ */

procedure get_jripasswords(storepass OUT NOCOPY varchar2,
                           keypass OUT NOCOPY varchar2);

procedure put_jripasswords(storepass in varchar2 default null,
                           keypass in varchar2 default null);

procedure del_jripasswords;

end AD_JAR;

/
