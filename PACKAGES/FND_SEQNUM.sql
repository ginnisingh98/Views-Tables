--------------------------------------------------------
--  DDL for Package FND_SEQNUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SEQNUM" AUTHID CURRENT_USER as
/* $Header: AFSQNUMS.pls 120.2 2005/11/03 08:11:23 fskinner ship $ */


/* FND_SEQNUM Constants for the return values from get_seq_info and get_seq_val
	this is a fairly close match to fdssop() 'C' function */
SEQSUCC	 CONSTANT number :=	 0; /* Everything completed successfully */
ORAFAIL	 CONSTANT number := -1; /* An oracle error occurred and we have raise the error with
								fnd.message and app_exception.raise_exception function */
NOASSIGN CONSTANT number := -2; /* No assignment exists for the set of parameters */
INACTIVE CONSTANT number := -3; /* The assigned sequence is inactive - so far this
								is not used here, if the trx_date is out of range for
								any assignment we return noassign - the 'C' code does */
BADPROF	 CONSTANT number := -4; /* The profile option is NOT set properly */
NOVALUE	 CONSTANT number := -5;	/* A sequence value was not passed for a manual seq */
NOTUNIQ	 CONSTANT number := -6;	/* The manual sequence value passed is not unique */
NOTUSED	 CONSTANT number := -7; /* Sequential Numbering is not used, continue */
ALWAYS	 CONSTANT number := -8; /* Sequential Numbering is always used and there is */
								/* no assignment for this set of parameters */
BADTYPE	 CONSTANT number := -9; /* Received an invalid DocSeq type */
DUPNAME	 CONSTANT number := -10;/* The sequence Name value passed is not unique */
BADFLAG	 CONSTANT number := -11;/* Received an invalid Message Flag */
BADDATE	 CONSTANT number := -12;/* Received an invalid start and end date combo for
								these parameters */
BADNAME	 CONSTANT number := -13;/* Received an invalid Doc_Seq Name */
BADCODE	 CONSTANT number := -14;/* Received an invalid Category Code */
BADSOB	 CONSTANT number := -15;/* Received an invalid Set of Books ID */
BADMTHD	 CONSTANT number := -16;/* Received an invalid Method Code */
BADAPPID CONSTANT number := -17;/* Received an invalid Method Code */

  function get_next_sequence (appid in number,
							   cat_code in varchar2,
							   sobid in number,
							   met_code in char,
							   trx_date in date,
							   dbseqnm in out nocopy varchar2,
							   dbseqid in out nocopy integer) return number;

  procedure get_seq_name (appid in number,
						  cat_code in varchar2,
						  sobid in number,
						  met_code in char,
						  trx_date in date,
						  dbseqnm out nocopy varchar2,
						  dbseqid out nocopy integer,
						  seqassid out nocopy integer);

  function get_next_auto_seq (dbseqnm in varchar2) return number;

  function get_next_auto_sequence (appid in number,
								   cat_code in varchar2,
								   sobid in number,
								   met_code in char,
								   trx_date in varchar2) return number;

  function get_next_auto_sequence (appid in number,
								   cat_code in varchar2,
								   sobid in number,
								   met_code in char,
								   trx_date in date) return number;

  procedure create_gapless_sequences;

  function create_gapless_sequence (seqid in number) return number;

  function get_next_user_sequence (fds_user_id in number,
								   seqassid in number,
								   seqid in number) return number;
/*
 * Bug 1106208 - Modified create_db_seq() to accept two new parameters
 * db_seq_name and init_value
 */
procedure create_db_seq (
		db_seq_name	in	fnd_document_sequences.db_sequence_name%TYPE,
		init_value	in	fnd_document_sequences.initial_value%TYPE
		);

/*
 * This function replaces/performs the actions of the 'C' code function fdssop()
 * Please see the comments above for usage information
 */
function get_seq_info (
		app_id			in number,
		cat_code		in varchar2,
		sob_id			in number,
		met_code		in char,
		trx_date		in date,
		docseq_id		out nocopy number,
		docseq_type		out nocopy char,
		docseq_name		out nocopy varchar2,
		db_seq_name		out nocopy varchar2,
		seq_ass_id		out nocopy number,
		prd_tab_name	out nocopy varchar2,
		aud_tab_name	out nocopy varchar2,
		msg_flag		out nocopy char,
		suppress_error	in char default 'N',
		suppress_warn	in char default 'N'
		) return number;

function create_audit_rec (
		aud_tab_name	in varchar2,
		docseq_id		in number,
		seq_val 		in number,
		seq_ass_id		in number,
		user_id			in number
		) return number;

/*
 * This function replaces/performs the actions of the user exit #FND SEQVAL
 * Please see the comments above for usage information
 */
function get_seq_val (
		app_id			in number,
		cat_code		in varchar2,
		sob_id			in number,
		met_code		in char,
		trx_date		in date,
		seq_val			in out nocopy number,
		docseq_id		out nocopy number,
		suppress_error	in char default 'N',
		suppress_warn	in char default 'N'
		) return number;

/*
 * This function is for special internal Applications use to create new Document
 * Sequences in batch form by the Product teams for upgrades or coversions
 */
function define_doc_seq (
		app_id			in number,
		docseq_name		in fnd_document_sequences.name%TYPE,
		docseq_type		in fnd_document_sequences.type%TYPE,
		msg_flag		in fnd_document_sequences.message_flag%TYPE,
		init_value		in fnd_document_sequences.initial_value%TYPE,
		p_startDate		in date,
		p_endDate		in date default NULL
		) return number;

/*
 * This function is for special internal Applications use to create new Doc_Seq
 * Assignments in batch form by the Product teams for upgrades or coversions
 */
function assign_doc_seq (
		app_id			in number,
		docseq_name		in fnd_document_sequences.name%TYPE,
		cat_code		in fnd_doc_sequence_assignments.category_code%TYPE,
		sob_id			in fnd_doc_sequence_assignments.set_of_books_id%TYPE,
		met_code		in fnd_doc_sequence_assignments.method_code%TYPE,
		p_startDate		in date,
		p_endDate		in date default NULL
		) return number;

end FND_SEQNUM;
 

/
