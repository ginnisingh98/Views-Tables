--------------------------------------------------------
--  DDL for Package FND_CP_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_RT_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPPRTS.pls 115.3 2003/02/13 16:46:17 ckclark noship $ */

 --
 -- Package
 --   FND_CP_RT_PKG
 --
 -- Purpose
 --   Concurrent processing PL/SQL regression testing
 --
 -- History
 --   21-DEC-02	Christina Clark         Created
 --


   --
   -- PUBLIC PROCEDURES/FUNCTIONS
   --
  /* Main concurrent program procedure */
  procedure fnd_cp_rt_proc(
                                  errbuf    out NOCOPY varchar2,
                                  retcode   out NOCOPY varchar2,
                                  run_mode  in  varchar2 default 'BASIC',
                                  duration  in  varchar2 default '0',
                                  p_num     in  varchar2 default NULL,
                                  p_date    in  varchar2 default NULL,
                                  p_varchar in  varchar2 default NULL);

  /* Sleep for duration seconds */
  procedure sleep (               duration IN varchar2);

  /* Run program in stripped down fashion */
  procedure basic(                errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2);

  /* Select and display data */
  procedure verify_values (       run_mode IN varchar2,
                                  duration IN varchar2,
                                  p_num IN varchar2,
                                  p_date IN varchar2,
                                  p_varchar IN varchar2);

  /* Submit a single request */
  procedure submit_single_request(errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2);

  /* Submit a single child request */
  procedure submit_sub_request(   errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2);

  /* Submit a request set */
  procedure submit_request_set(   errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2);

  /* Write a message that all phases complete */
  procedure finish(               errbuf  OUT NOCOPY varchar2,
                                  retcode OUT NOCOPY varchar2);

end fnd_cp_rt_pkg;

 

/
