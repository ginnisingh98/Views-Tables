--------------------------------------------------------
--  DDL for Package PER_REFRESH_POSITION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REFRESH_POSITION" AUTHID CURRENT_USER AS
/* $Header: hrpsfref.pkh 115.6 2004/01/29 12:25:39 hsajja ship $ */
--
refreshing_position  boolean := false;
--
procedure refresh_all_position ( errbuf                      out nocopy varchar2
        		                 , retcode                    out nocopy number
			                 , p_refresh_date                 date     default trunc(sysdate));

procedure refresh_position ( p_refresh_date                  date
                             ,p_position_id                  number   default null
                             ,p_effective_date               date
					    ,p_full_hr                      varchar2 default 'Y'
                             ,p_object_version_number in out nocopy number
			              ,errbuf                     out nocopy varchar2
 	    	       	         ,retcode                    out nocopy varchar2);
--
procedure refresh_single_position ( p_refresh_date                  date
                                   , p_position_id                  number
                                   , p_effective_date               date
                                   , p_object_version_number in out nocopy number);
--
function get_position_ovn return number ;
--
END PER_REFRESH_POSITION;

 

/
