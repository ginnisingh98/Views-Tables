--------------------------------------------------------
--  DDL for Package HXC_RESTORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RESTORE" AUTHID CURRENT_USER as
/* $Header: hxcrestore.pkh 120.0.12010000.3 2008/09/27 11:32:34 asrajago ship $ */

PROCEDURE restore_process(p_data_set_id 	NUMBER,
              		  p_data_set_start_date DATE,
              		  p_data_set_end_date   DATE);

PROCEDURE child_restore_process ( errbuf          OUT  NOCOPY VARCHAR2,
                                  retcode         OUT  NOCOPY NUMBER,
                                  p_from_id       IN   NUMBER,
                                  p_to_id         IN   NUMBER,
                                  p_data_set_id   IN   NUMBER,
                                  p_thread_id     IN   NUMBER ) ;

PROCEDURE log_data_mismatch( p_scope      IN VARCHAR2,
                             p_insert     IN NUMBER,
                             p_delete     IN NUMBER ,
                             p_mismatch   IN OUT NOCOPY BOOLEAN) ;



END hxc_restore;

/
