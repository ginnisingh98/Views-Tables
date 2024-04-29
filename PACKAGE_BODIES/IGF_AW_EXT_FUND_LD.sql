--------------------------------------------------------
--  DDL for Package Body IGF_AW_EXT_FUND_LD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_EXT_FUND_LD" AS
/* $Header: IGFAW05B.pls 120.2 2006/01/17 02:40:03 tsailaja noship $ */
--
-------------------------------------------------------------------------
--   Created By       :    mesriniv
--   Date Created By  :    2001/15/06
--   Purpose          :    To Upload External Funds from the DataFile
--                         and Create Awards and Disbursements
------------------------------------------------------------------------
-- Who             When            What
------------------------------------------------------------------------
-- veramach        3-NOV-2003      FA 125 Multiple Distr Methods
--                                 Obsoleted the process
------------------------------------------------------------------------
-- ugummall        26-SEP-2003     FA 126 - Multiple FA Offices.
--                                 added new parameter assoc_org_num to
--                                 igf_ap_fa_base_rec_pkg TBH calls
------------------------------------------------------------------------
-- sjadhav         02-Jul-2003     Re-vamped code logic to create
--                                 external awards. Corrected routines
--                                 added via bug 2863920.
------------------------------------------------------------------------
-- sjadhav         24-Jun-2003     Bug 2983181. elig status populated
--                                 with N
------------------------------------------------------------------------
-- bkkumar         04-jun-2003     Bug #2858504
--                                 Added legacy_record_flag,award_number_txt
--                                 in the table handler calls for
--                                 igf_aw_award_pkg.insert_row
--                                 Added legacy_record_flag
--                                 in the table handler calls for
--                                 igf_ap_td_item_inst_pkg.insert_row
------------------------------------------------------------------------
--rasahoo         23-Apl-2003      Bug # 2860836
--                                 Added exception handling for resolving
--                                 locking problem created by fund manager
------------------------------------------------------------------------
--gmuralid         10-Apr-2003     Bug 2863920
--                                 Made the following changes :
--                                 1) In process_funds procedure
--                                 in check for student cursor, added
--                                 award year join in the where clause.
--                                 2)The procedures get_disbursements,
--                                 post_award and add_todo initially
--                                 present in the packaging process now
--                                 made local to this package.
------------------------------------------------------------------------
-- sjadhav         03-Apr-2003     Bug 2875503
--                                 Added SQLERRM messages
------------------------------------------------------------------------
-- sjadhav         Jan.08.2003.    Bug 2740220.
--                                 Added igf_gr_gen.get_ssn_digits
------------------------------------------------------------------------
-- masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
--                                 Removed packaging hold
------------------------------------------------------------------------
-- masehgal        03-Nov-2002     # 2613546  FA 105_108 Multi Award
--                                 Years Added pell alt expense in fa
--                                 base call
------------------------------------------------------------------------
-- masehgal        25-Sep-2002     FA 104 - To Do Enhancements
--                                 Added manual_disb_hold in FA Base
--                                 insert
------------------------------------------------------------------------
-- cdcruz          13-jun-2002     IF Student not found in Base record
--                                 it Creates a Base Record
------------------------------------------------------------------------
--

-- MAIN PROCEDURE
PROCEDURE process_ack(errbuf           OUT NOCOPY   VARCHAR2,
                      retcode          OUT NOCOPY   NUMBER,
                      p_award_year     IN           VARCHAR2,
                      p_org_id         IN           NUMBER)
AS

/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2001/15/06
   Purpose          :    To process all the Records in the FlatFile
   Known Limitations,Enhancements or Remarks
   Change History   :
   Bug No               :       2400442
   Bug Desc             :       Import External Awards
   Who                  When        What
   mesriniv            7-jun-2002   Added a new parameter p_award_year
   Who              When      What
   tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
 ***************************************************************/


BEGIN
	 igf_aw_gen.set_org_id(NULL);
     retcode := 0;

     fnd_message.set_name('IGS','IGS_GE_OBSOLETE_JOB');
     fnd_file.put_line(fnd_file.log,fnd_message.get);

END process_ack;

END igf_aw_ext_fund_ld;

/
