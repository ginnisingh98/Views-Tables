--------------------------------------------------------
--  DDL for Package BEN_DELETE_ORPHAN_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DELETE_ORPHAN_ROWS" AUTHID CURRENT_USER as
/* $Header: bedeorph.pkh 115.0 2004/07/21 13:04:17 abparekh noship $ */
--
-- Global type declaration
--
TYPE Numdata is TABLE OF PER_ALL_PEOPLE_F.PERSON_ID%type;
TYPE g_request_table is table of number index by binary_integer;
--
-- Global varaibles.
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< process >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
 -- This is the main batch procedure to be called from the concurrent manager.
--
procedure process
   ( errbuf                       out nocopy varchar2
    ,retcode                      out nocopy number
   );
--
 -- -----------------------------------------------------------------------------
 -- |--------------------------< do_multithread >-------------------------------|
 -- -----------------------------------------------------------------------------
 --
 -- This is the main batch procedure to be called from the concurrent manager
 --
 procedure do_multithread
   (errbuf                     out nocopy varchar2
   ,retcode                    out nocopy number
   ,p_parent_request_id        in  number
   ,p_thread_id                in  number  );
--
end ben_delete_orphan_rows;

 

/
