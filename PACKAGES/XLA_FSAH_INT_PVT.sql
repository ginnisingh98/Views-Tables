--------------------------------------------------------
--  DDL for Package XLA_FSAH_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_FSAH_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: xlafsipvt.pkh 120.6.12010000.1 2009/08/17 14:35:53 vkasina noship $ */
/*================================================================================|
| FILENAME                                                                        |
|    xlafsipvt.pkb                                                                |
|                                                                                 |
| PACKAGE NAME                                                                    |
|    xla_fsah_int_pvt                                                             |
|                                                                                 |
| DESCRIPTION                                                                     |
|    This is a XLA private package, which contains all the fucntions and          |
|    procedures which required to update and reprocess the successfull and        |
|    non-succesfull transactions                                                  |
|    and tranfermations to people soft General Ledger.                            |
|                                                                                 |
|    Also API Return The new group_id for the further Successfull Update          |
|                                                                                 |
|                                                                                 |
|    Note:                                                                        |
|       - the APIs do not execute any COMMIT or ROLLBACK.                         |
|                                         |
|                                         |
| HISTORY                                                                         |
| -------                                                                         |
| 23-Jun-08    JAGAN KODURI                                                       |
|                                                                                 |
|                                                                                 |
|                                                                                 |
| PARAMETER DESCRIPTION                                                           |
| ---------------------                                                           |
| GET_GROUP_ID                                                                    |
| --------------                                                                  |
| Return Only The group_id                                                        |
|                                                                                 |
| SET_GROUP_ID                                                                    |
| ------------                                                                    |
| p_ledger_id         :in parameter                                               |
|                                                                                 |
| SET_TRANSFER_STATUS                                                             |
| --------------------                                                            |
| p_group_id         :in parameter (xla_fsah_int_pvt.group_id)                    |
| p_batch_status     :in parameter (F/S)                                          |
| p_api_version      :in parameter (Default API version 1.0)                      |
| p_return_status    :out parameter (Use to Return Process Successfull Status)    |
| p_msg_data         :out parameter (Default API out to Error count)              |
| p_msg_count        :out parameter (return New Group Id for New Process Update)  |
|                                                                                 |
+=================================================================================*/
   FUNCTION get_group_id (
      p_ledger_short_name     IN   VARCHAR2,
      p_appl_short_name       IN   VARCHAR2,
      p_end_date              IN   DATE,
      p_accounting_batch_id   IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_true,
      p_api_version           IN   NUMBER DEFAULT 1.0
   )
      RETURN NUMBER;

   PROCEDURE set_group_id (
      p_ledger_short_name     IN   VARCHAR2,
      p_appl_short_name       IN   VARCHAR2,
      p_end_date              IN   DATE,
      p_accounting_batch_id   IN   NUMBER,
      p_group_id              IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_true,
      p_api_version           IN   NUMBER DEFAULT 1.0,
      p_commit                IN   BOOLEAN DEFAULT TRUE
   );

   PROCEDURE set_transfer_status (
      p_group_id        IN              NUMBER,
      p_batch_status    IN              VARCHAR2,
      p_api_version     IN              NUMBER DEFAULT 1.0,
      p_return_status   OUT NOCOPY      VARCHAR2,
      p_err_msg         OUT NOCOPY      VARCHAR2
   );

   PROCEDURE reverse_journal_entries (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_application_id     IN              INTEGER,
      p_event_id           IN              INTEGER,
      p_reversal_method    IN              VARCHAR2,
      p_gl_date            IN              DATE,
      p_post_to_gl_flag    IN              VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      x_rev_ae_header_id   OUT NOCOPY      INTEGER,
      x_rev_event_id       OUT NOCOPY      INTEGER,
      x_rev_entity_id      OUT NOCOPY      INTEGER,
      x_new_event_id       OUT NOCOPY      INTEGER,
      x_new_entity_id      OUT NOCOPY      INTEGER
   );

   PROCEDURE rev_jour_entry (
      p_ae_header_id    IN              NUMBER,
      p_return_status   OUT NOCOPY      VARCHAR2,
      p_error_msg       OUT NOCOPY      VARCHAR2
   );

   PROCEDURE rev_jour_entry_list (
      p_list_ae_header_id   IN              FND_TABLE_OF_NUMBER,
      p_return_status       OUT NOCOPY      VARCHAR2,
      p_error_msg           OUT NOCOPY      VARCHAR2
   );
END xla_fsah_int_pvt;

/
