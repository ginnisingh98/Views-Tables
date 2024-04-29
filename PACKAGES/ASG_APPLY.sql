--------------------------------------------------------
--  DDL for Package ASG_APPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_APPLY" AUTHID DEFINER AS
/*$Header: asgaplys.pls 120.2.12010000.3 2010/05/06 06:45:38 trajasek ship $*/

-- DESCRIPTION
--  This package processes upload data. It also contains ltos of helper
--  routines meant to apply the changes efficiently.
--
-- HISTORY
--   12-aug-2009 saradhak   Added process_mobile_queries api
--   15-sep-2004 ssabesan   Changes for delivery notification
--   28-nov-2002 ssabesan   Added NOCOPY in function definition
--   14-aug-2002 rsripada   Added globals to store conc program's user-id etc
--   29-may-2002 rsripada   Streamlined some of the procedures
--   24-may-2002 rsripada   Added sequence processing support
--   25-apr-2002 rsripada   Added deferred transaction support etc
--   22-feb-2002 rsripada   Finalized api specifications
--   19-feb-2002 rsripada   Created

  -- Table to store the list of usernames or publication-items
  TYPE vc2_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  -- Table to store the list of tranids
  TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  g_empty_vc2_tbl vc2_tbl_type; -- Should always be empty!
  g_empty_num_tbl num_tbl_type; -- Should always be empty!

  g_current_tranid      NUMBER;
  g_user_name           VARCHAR2(30);
  g_only_deferred_trans VARCHAR2(1);

  g_conc_userid        NUMBER := 5;
  g_conc_respid        NUMBER := 20420;
  g_conc_appid         NUMBER := 1;

  -- Logging procedure
  PROCEDURE log(debug_msg IN VARCHAR2,
                log_level IN NUMBER := FND_LOG.LEVEL_STATEMENT);

  -- Sort the publication item list by weight stored in
  -- asg_pub_item table
  PROCEDURE sort_by_weight(p_pub_name IN VARCHAR2,
                           x_pub_items_tbl IN OUT NOCOPY vc2_tbl_type);

  -- Returns the list of all clients with the specified inq record types
  -- dirty for unprocessed new records
  -- deferred for processed but deferred records.
  -- x_return_status should be checked for FND_API.G_RET_STS_SUCCESS
  -- before the clients list processed.
  PROCEDURE get_all_clients(p_dirty IN VARCHAR2 := 'Y',
                            p_deferred IN VARCHAR2 := 'N',
                            x_clients_tbl OUT NOCOPY vc2_tbl_type,
                            x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_all_tranids(p_user_name IN VARCHAR2,
                            x_tranids_tbl OUT NOCOPY num_tbl_type,
                            x_return_status OUT NOCOPY VARCHAR2);

  -- get the names of all publication items that have
  -- records for the specified tran_id and pubname
  PROCEDURE get_all_pub_items(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              p_pubname IN VARCHAR2,
                              x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                              x_return_status OUT NOCOPY VARCHAR2);

  -- get the names of all publication items that have
  -- records for the specified tran_id
  PROCEDURE get_all_pub_items(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                              x_return_status OUT NOCOPY VARCHAR2);

  -- get the names of all publication items that have only dirty
  -- records for the specified tran_id
  PROCEDURE get_all_dirty_pub_items(p_user_name IN VARCHAR2,
                                    p_tranid   IN NUMBER,
                                    p_pubname IN VARCHAR2,
                                    x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2);

  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if no tranid exists
  -- Returns both dirty and deferred tranids
  PROCEDURE get_first_tranid(p_user_name IN VARCHAR2,
                             x_tranid OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2);

  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if no tranid exists
  -- Returns both dirty and deferred tranids
  PROCEDURE get_next_tranid(p_user_name IN VARCHAR2,
                            p_curr_tranid IN NUMBER,
                            x_tranid OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to delete a row
  PROCEDURE delete_row(p_user_name IN VARCHAR2,
                       p_tranid IN NUMBER,
                       p_pubitem IN VARCHAR2,
                       p_sequence IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to purge all the dirty INQ records for
  -- the specified user/transid/publication-item(s)
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           p_tranid   IN NUMBER,
                           p_pubitems_tbl  IN vc2_tbl_type,
                           x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to purge all the dirty INQ records for
  -- the specified user/transid
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           p_tranid  IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to purge all the dirty INQ records for
  -- the specified user
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2);

  -- Signal the beginning of inq processing for an user
  -- returns FND_API.G_FALSE is no inq processing is necessary for this user
  PROCEDURE begin_client_apply(p_user_name IN VARCHAR2,
                               x_begin_client_apply OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2);

  -- Signal the end of inq processing for an user
  -- All dirty records processed in this session that are not removed from
  -- inq will be marked as deferred.
  PROCEDURE end_client_apply(p_user_name IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

  -- Should be called before any user's transactions are processed
  -- returns FND_API.G_FALSE if no user has dirty/deferred data in inq.
  PROCEDURE begin_apply(x_begin_apply OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2);

  -- Should be called at the end of the apply for all clients in that
  -- session. Always returns FND_API.G_RET_STS_SUCCESS.
  PROCEDURE end_apply(x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to update the upload information
  PROCEDURE setup_inq_info(p_user_name IN VARCHAR2,
                           p_tranid IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2);

-- Procedure to process synchronous mobile queries from client
  PROCEDURE process_mobile_queries(p_user_name IN VARCHAR2,
                                   p_tranid IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2);

  -- Procedure to process sequence updates from client
  PROCEDURE process_sequences(p_user_name IN VARCHAR2,
                              p_tranid IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2);

  -- Main procedure to process all upload transactions
  -- Will be used by the concurrent program to process all users.
  PROCEDURE process_upload(errbuf OUT NOCOPY VARCHAR2,
                           RETCODE OUT NOCOPY VARCHAR2,
                           p_apply_ha IN VARCHAR2 );

  function is_conc_program_running
  return varchar2;

--12.1
  PROCEDURE get_compacted_tranid(p_user_name IN VARCHAR2,
                                 p_tranid IN NUMBER,
                                 x_compacted_tranid OUT NOCOPY NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2);

--12.1
  PROCEDURE process_auto_sync(p_user_name IN VARCHAR2,
                              p_tranid IN NUMBER,
                              x_compacted_tranid OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2);

END asg_apply;

/
