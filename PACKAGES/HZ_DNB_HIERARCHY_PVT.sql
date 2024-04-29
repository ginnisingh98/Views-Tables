--------------------------------------------------------
--  DDL for Package HZ_DNB_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DNB_HIERARCHY_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHDNBHS.pls 120.3 2005/06/16 21:10:22 jhuang noship $ */
--------------------------------------
-- AUTHOR :::::: COLATHUR VIJAYAN (VJN)
--------------------------------------

TYPE dnb_dfs_rec_type IS RECORD (
    party_id    NUMBER,
    start_date  DATE

);

--------------------------------------------------------------------------------------
-- create_dnb_hierarchy ::: THIS WILL FIX DNB DATA, BY CREATING A HIERARCHY FOR
--                          DNB PURCHASED PARTIES, BASED ON THE INFORMATION AVAILABLE
--                          FROM THE EXISTING NON-HIERARCHICAL RELATIONSHIPS FOR
--                          DNB IMPORTED DATA.
--------------------------------------------------------------------------------------

PROCEDURE create_dnb_hierarchy (
-- input parameters
 	p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
-- output parameters
 	x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------------
-- create_dnb_hierarchy ::: THE ABOVE PROCEDURE IS OVERLOADED SO THAT IT CAN BE CALLED
--                          AS A CONCURRENT PROGRAM.
--------------------------------------------------------------------------------------

PROCEDURE create_dnb_hierarchy (
    errbuf              OUT     NOCOPY VARCHAR2,
    Retcode             OUT     NOCOPY VARCHAR2,
    -- introducing this to have a functionality in the future
    -- so that a user could use this argument in the concurrent program
    -- to run the cleanup script before running CPS
    cleanup_required	IN      VARCHAR2  DEFAULT 'N'
);

----------------------------------------------------------------------------------------------
-- conform_party_to_dnb_hierarchy ::: THIS WILL CONFORM A PURCHASED PARTY TO THE DNB HIERARCHY
--                                    CREATED BY THE ABOVE PROCEDURE.
----------------------------------------------------------------------------------------------

PROCEDURE conform_party_to_dnb_hierarchy (
-- input parameters
 	p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    party_id                IN NUMBER,
    parent_party_id         IN NUMBER,
    dup_party_id            IN NUMBER,
    gup_party_id            IN NUMBER,
-- This flag should be passed in as
-- H -- if parent_party_id is a PARENT_OF party_id
-- P -- if parent_party_id is a HEADQUARTER_OF party_id
    parent_type_flag        IN VARCHAR2,
-- output parameters
 	x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
);


END HZ_DNB_HIERARCHY_PVT ;



 

/
