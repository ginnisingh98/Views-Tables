--------------------------------------------------------
--  DDL for Package ARP_UPGRADE_COMMON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_UPGRADE_COMMON_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARUPGCOS.pls 115.2 2002/11/15 04:08:18 anukumar ship $*/

--
--
-- Public procedures/functions
--

PROCEDURE insert_p( p_dist_rec   IN ar_distributions_all%ROWTYPE,
                    p_line_id    OUT NOCOPY ar_distributions_all.line_id%TYPE );

PROCEDURE enable_file_debug(p_path_name in varchar2,
                            p_file_name in varchar2);

PROCEDURE disable_file_debug;

PROCEDURE debug(p_line in varchar2);
PROCEDURE enable_debug;
PROCEDURE enable_debug( buffer_size NUMBER );
PROCEDURE disable_debug;

--
END ARP_UPGRADE_COMMON_UTIL;

 

/
