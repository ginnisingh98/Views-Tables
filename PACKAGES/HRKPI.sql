--------------------------------------------------------
--  DDL for Package HRKPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRKPI" AUTHID CURRENT_USER as
/* $Header: hrkpi01.pkh 115.6 2002/12/03 13:24:19 apholt noship $ */


  --
  -- Although the implementation of request is java we still call
  -- through a PL/SQL wrapper rather than via call spec directly
  -- to allow more flexibility (eg. autonmous tx), better error
  -- handling. The trade off is performance which is less critical
  -- for this prototype code
  --
  function  request (context in varchar2, cookie in out nocopy varchar2)
  return varchar2 ;

  procedure parseResponse (response in     varchar2,
                           cmd      in out nocopy varchar2,
                           action   in out nocopy varchar2) ;

  --
  -- Returns installed list of adapters
  --
  function getadapters return hr_nvpair_tab_t ;


  --
  -- Returns list of events for the current adapter
  --
  function getevents return hr_extlib_evt_tab_t ;



  --
  -- Saves the user preference for the current user
  --
  -- For the time being the preference name is the name of a profile option
  --
  procedure save_user_preference ( p_name  in varchar2,
                                   p_value in varchar2 ) ;

  --
  -- Basic self-test and version information
  --
  procedure test;

end hrkpi;

 

/
