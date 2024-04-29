--------------------------------------------------------
--  DDL for Package PA_COPY_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COPY_STRUCTURE_PKG" AUTHID CURRENT_USER as
--  $Header: PAXCICPS.pls 120.1 2005/08/23 19:18:03 spunathi noship $

   procedure check_structure(cp_structure IN varchar2, status IN OUT NOCOPY number);

   procedure check_existence(cp_structure IN varchar2, status IN OUT NOCOPY number);

   procedure copy_structure(source      IN     varchar2,
                             destination IN     varchar2,
                             status      IN OUT NOCOPY number,
                             stage       IN OUT NOCOPY number);


end PA_COPY_STRUCTURE_PKG ;

 

/
