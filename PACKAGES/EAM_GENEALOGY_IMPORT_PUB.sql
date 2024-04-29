--------------------------------------------------------
--  DDL for Package EAM_GENEALOGY_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_GENEALOGY_IMPORT_PUB" AUTHID CURRENT_USER as
/* $Header: EAMPGEIS.pls 115.3 2002/11/20 19:33:59 aan ship $ */
 --
 -- Start of comments
 -- API name : import_genealogy
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       p_interface_group_id   IN    NUMBER   Required
 --          p_purge_option         IN    VARCHAR2 Optional  Default = 'N'
 -- OUT      errbuf                 OUT   VARCHAR2
 --          retcode                OUT   NUMBER
 --
 -- Version  Initial version    1.0     Himal Karmacharya
 --
 -- Notes    : This public API imports genealogy info into
 --            MTL_OBJECT_GENEALOGY table
 --
 -- End of comments

PROCEDURE import_genealogy(
    errbuf                     OUT NOCOPY     VARCHAR2,
    retcode                    OUT NOCOPY     NUMBER,
    p_interface_group_id        IN     NUMBER,
    p_purge_option              IN     VARCHAR2 := 'N'
 );

END EAM_GENEALOGY_IMPORT_PUB;

 

/
