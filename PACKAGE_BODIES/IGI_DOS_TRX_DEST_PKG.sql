--------------------------------------------------------
--  DDL for Package Body IGI_DOS_TRX_DEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_TRX_DEST_PKG" AS
/* $Header: igidosrb.pls 120.8.12000000.2 2007/06/14 05:57:08 pshivara ship $ */

l_debug_level   number;

l_state_level   number;
l_proc_level    number;
l_event_level   number;
l_excep_level   number;
l_error_level   number;
l_unexp_level   number;

  l_rowid VARCHAR2(25);
  old_references igi_dos_trx_dest%ROWTYPE;
  new_references igi_dos_trx_dest%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_sob_id                            IN     NUMBER       ,
    x_trx_id                            IN     NUMBER       ,
    x_dest_trx_id                       IN     NUMBER       ,
    x_source_trx_id                     IN     NUMBER       ,
    x_source_id                         IN     NUMBER       ,
    x_destination_id                    IN     NUMBER       ,
    x_code_combination_id               IN     NUMBER       ,
    x_profile_code                      IN     VARCHAR2     ,
    x_budget_name                       IN     VARCHAR2     ,
    x_budget_entity_id                  IN     NUMBER       ,
    x_budget_amount                     IN     NUMBER       ,
    x_funds_available                   IN     NUMBER       ,
    x_new_balance                       IN     NUMBER       ,
    x_currency_code                     IN     VARCHAR2     ,
    x_visible_segments                  IN     VARCHAR2     ,
    x_actual_segments                   IN     VARCHAR2     ,
    x_m_budget_amount                 IN     NUMBER       ,
    x_m_budget_amt_exch_rate          IN     NUMBER       ,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2     ,
    x_m_budget_amt_exch_date          IN     DATE         ,
    x_m_budget_amt_exch_status        IN     VARCHAR2     ,
    x_m_funds_avail                   IN     NUMBER       ,
    x_m_funds_avail_exch_rate         IN     NUMBER       ,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2     ,
    x_m_funds_avail_exch_date         IN     DATE         ,
    x_m_funds_avail_exch_status       IN     VARCHAR2     ,
    x_m_new_balance                   IN     NUMBER       ,
    x_m_new_balance_exch_rate         IN     NUMBER       ,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2     ,
    x_m_new_balance_exch_date         IN     DATE         ,
    x_m_new_balance_exch_status       IN     VARCHAR2     ,
    x_dossier_id                        IN     NUMBER       ,
    x_budget_version_id                 IN     NUMBER       ,
    x_period_name                       IN     VARCHAR2     ,
    x_percentage                        IN     NUMBER       ,
    x_status                            IN     VARCHAR2     ,
    x_group_id                          IN     NUMBER       ,
    x_quarter_num                       IN     NUMBER       ,
    x_period_year                       IN     NUMBER       ,
    x_period_num                        IN     NUMBER       ,
    x_line_num                          IN     NUMBER       ,
    x_segment1                          IN     VARCHAR2     ,
    x_segment2                          IN     VARCHAR2     ,
    x_segment3                          IN     VARCHAR2     ,
    x_segment4                          IN     VARCHAR2     ,
    x_segment5                          IN     VARCHAR2     ,
    x_segment6                          IN     VARCHAR2     ,
    x_segment7                          IN     VARCHAR2     ,
    x_segment8                          IN     VARCHAR2     ,
    x_segment9                          IN     VARCHAR2     ,
    x_segment10                         IN     VARCHAR2     ,
    x_segment11                         IN     VARCHAR2     ,
    x_segment12                         IN     VARCHAR2     ,
    x_segment13                         IN     VARCHAR2     ,
    x_segment14                         IN     VARCHAR2     ,
    x_segment15                         IN     VARCHAR2     ,
    x_segment16                         IN     VARCHAR2     ,
    x_segment17                         IN     VARCHAR2     ,
    x_segment18                         IN     VARCHAR2     ,
    x_segment19                         IN     VARCHAR2     ,
    x_segment20                         IN     VARCHAR2     ,
    x_segment21                         IN     VARCHAR2     ,
    x_segment22                         IN     VARCHAR2     ,
    x_segment23                         IN     VARCHAR2     ,
    x_segment24                         IN     VARCHAR2     ,
    x_segment25                         IN     VARCHAR2     ,
    x_segment26                         IN     VARCHAR2     ,
    x_segment27                         IN     VARCHAR2     ,
    x_segment28                         IN     VARCHAR2     ,
    x_segment29                         IN     VARCHAR2     ,
    x_segment30                         IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_dos_trx_dest
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.set_column_values.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.sob_id                            := x_sob_id;
    new_references.trx_id                            := x_trx_id;
    new_references.dest_trx_id                       := x_dest_trx_id;
    new_references.source_trx_id                     := x_source_trx_id;
    new_references.source_id                         := x_source_id;
    new_references.destination_id                    := x_destination_id;
    new_references.code_combination_id               := x_code_combination_id;
    new_references.profile_code                      := x_profile_code;
    new_references.budget_name                       := x_budget_name;
    new_references.budget_entity_id                  := x_budget_entity_id;
    new_references.budget_amount                     := x_budget_amount;
    new_references.funds_available                   := x_funds_available;
    new_references.new_balance                       := x_new_balance;
    new_references.currency_code                     := x_currency_code;
    new_references.visible_segments                  := x_visible_segments;
    new_references.actual_segments                   := x_actual_segments;
    new_references.mrc_budget_amount                 := x_m_budget_amount;
    new_references.mrc_budget_amt_exch_rate          := x_m_budget_amt_exch_rate;
    new_references.mrc_budget_amt_exch_rate_type     := x_m_budget_amt_exch_rate_type;
    new_references.mrc_budget_amt_exch_date          := x_m_budget_amt_exch_date;
    new_references.mrc_budget_amt_exch_status        := x_m_budget_amt_exch_status;
    new_references.mrc_funds_avail                   := x_m_funds_avail;
    new_references.mrc_funds_avail_exch_rate         := x_m_funds_avail_exch_rate;
    new_references.mrc_funds_avail_exch_rate_type    := x_m_funds_avail_exch_rate_type;
    new_references.mrc_funds_avail_exch_date         := x_m_funds_avail_exch_date;
    new_references.mrc_funds_avail_exch_status       := x_m_funds_avail_exch_status;
    new_references.mrc_new_balance                   := x_m_new_balance;
    new_references.mrc_new_balance_exch_rate         := x_m_new_balance_exch_rate;
    new_references.mrc_new_balance_exch_rate_type    := x_m_new_balance_exch_rate_type;
    new_references.mrc_new_balance_exch_date         := x_m_new_balance_exch_date;
    new_references.mrc_new_balance_exch_status       := x_m_new_balance_exch_status;
    new_references.dossier_id                        := x_dossier_id;
    new_references.budget_version_id                 := x_budget_version_id;
    new_references.period_name                       := x_period_name;
    new_references.percentage                        := x_percentage;
    new_references.status                            := x_status;
    new_references.group_id                          := x_group_id;
    new_references.quarter_num                       := x_quarter_num;
    new_references.period_year                       := x_period_year;
    new_references.period_num                        := x_period_num;
    new_references.line_num                          := x_line_num;
    new_references.segment1                          := x_segment1;
    new_references.segment2                          := x_segment2;
    new_references.segment3                          := x_segment3;
    new_references.segment4                          := x_segment4;
    new_references.segment5                          := x_segment5;
    new_references.segment6                          := x_segment6;
    new_references.segment7                          := x_segment7;
    new_references.segment8                          := x_segment8;
    new_references.segment9                          := x_segment9;
    new_references.segment10                         := x_segment10;
    new_references.segment11                         := x_segment11;
    new_references.segment12                         := x_segment12;
    new_references.segment13                         := x_segment13;
    new_references.segment14                         := x_segment14;
    new_references.segment15                         := x_segment15;
    new_references.segment16                         := x_segment16;
    new_references.segment17                         := x_segment17;
    new_references.segment18                         := x_segment18;
    new_references.segment19                         := x_segment19;
    new_references.segment20                         := x_segment20;
    new_references.segment21                         := x_segment21;
    new_references.segment22                         := x_segment22;
    new_references.segment23                         := x_segment23;
    new_references.segment24                         := x_segment24;
    new_references.segment25                         := x_segment25;
    new_references.segment26                         := x_segment26;
    new_references.segment27                         := x_segment27;
    new_references.segment28                         := x_segment28;
    new_references.segment29                         := x_segment29;
    new_references.segment30                         := x_segment30;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.source_trx_id = new_references.source_trx_id)) OR
        ((new_references.source_trx_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_trx_sources_pkg.get_pk_for_validation (
                new_references.source_trx_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.check_parent_existance.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    IF (((old_references.trx_id = new_references.trx_id)) OR
        ((new_references.trx_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_trx_headers_pkg.get_pk_for_validation (
                new_references.trx_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.check_parent_existance.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    IF (((old_references.dossier_id = new_references.dossier_id)) OR
        ((new_references.dossier_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_doc_types_pkg.get_pk_for_validation (
                new_references.dossier_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.check_parent_existance.Msg3',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    /* sowsubra  06-JUN-2002 start */
   /* Commented the following code as this  igi_dos_trx_dest_hist_pkg
   	is currently not present  */

	null;
    /*igi_dos_trx_dest_hist_pkg.get_fk_igi_dos_trx_dest (
      old_references.dest_trx_id    );
   /* sowsubra  06-JUN-2002 end */

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_dest_trx_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE    dest_trx_id = x_dest_trx_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE get_fk_igi_dos_trx_sources (
    x_source_trx_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE   ((source_trx_id = x_source_trx_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.get_fk_igi_dos_trx_sources.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_trx_sources;


  PROCEDURE get_fk_igi_dos_trx_headers (
    x_trx_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE   ((trx_id = x_trx_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.get_fk_igi_dos_trx_headers.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_trx_headers;


  PROCEDURE get_fk_igi_dos_doc_types (
    x_dossier_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE   ((dossier_id = x_dossier_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.get_fk_igi_dos_doc_types.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_doc_types;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_sob_id                            IN     NUMBER       ,
    x_trx_id                            IN     NUMBER       ,
    x_dest_trx_id                       IN     NUMBER       ,
    x_source_trx_id                     IN     NUMBER       ,
    x_source_id                         IN     NUMBER       ,
    x_destination_id                    IN     NUMBER       ,
    x_code_combination_id               IN     NUMBER       ,
    x_profile_code                      IN     VARCHAR2     ,
    x_budget_name                       IN     VARCHAR2     ,
    x_budget_entity_id                  IN     NUMBER       ,
    x_budget_amount                     IN     NUMBER       ,
    x_funds_available                   IN     NUMBER       ,
    x_new_balance                       IN     NUMBER       ,
    x_currency_code                     IN     VARCHAR2     ,
    x_visible_segments                  IN     VARCHAR2     ,
    x_actual_segments                   IN     VARCHAR2     ,
    x_m_budget_amount                 IN     NUMBER       ,
    x_m_budget_amt_exch_rate          IN     NUMBER       ,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2     ,
    x_m_budget_amt_exch_date          IN     DATE         ,
    x_m_budget_amt_exch_status        IN     VARCHAR2     ,
    x_m_funds_avail                   IN     NUMBER       ,
    x_m_funds_avail_exch_rate         IN     NUMBER       ,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2     ,
    x_m_funds_avail_exch_date         IN     DATE         ,
    x_m_funds_avail_exch_status       IN     VARCHAR2     ,
    x_m_new_balance                   IN     NUMBER       ,
    x_m_new_balance_exch_rate         IN     NUMBER       ,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2     ,
    x_m_new_balance_exch_date         IN     DATE         ,
    x_m_new_balance_exch_status       IN     VARCHAR2     ,
    x_dossier_id                        IN     NUMBER       ,
    x_budget_version_id                 IN     NUMBER       ,
    x_period_name                       IN     VARCHAR2     ,
    x_percentage                        IN     NUMBER       ,
    x_status                            IN     VARCHAR2     ,
    x_group_id                          IN     NUMBER       ,
    x_quarter_num                       IN     NUMBER       ,
    x_period_year                       IN     NUMBER       ,
    x_period_num                        IN     NUMBER       ,
    x_line_num                          IN     NUMBER       ,
    x_segment1                          IN     VARCHAR2     ,
    x_segment2                          IN     VARCHAR2     ,
    x_segment3                          IN     VARCHAR2     ,
    x_segment4                          IN     VARCHAR2     ,
    x_segment5                          IN     VARCHAR2     ,
    x_segment6                          IN     VARCHAR2     ,
    x_segment7                          IN     VARCHAR2     ,
    x_segment8                          IN     VARCHAR2     ,
    x_segment9                          IN     VARCHAR2     ,
    x_segment10                         IN     VARCHAR2     ,
    x_segment11                         IN     VARCHAR2     ,
    x_segment12                         IN     VARCHAR2     ,
    x_segment13                         IN     VARCHAR2     ,
    x_segment14                         IN     VARCHAR2     ,
    x_segment15                         IN     VARCHAR2     ,
    x_segment16                         IN     VARCHAR2     ,
    x_segment17                         IN     VARCHAR2     ,
    x_segment18                         IN     VARCHAR2     ,
    x_segment19                         IN     VARCHAR2     ,
    x_segment20                         IN     VARCHAR2     ,
    x_segment21                         IN     VARCHAR2     ,
    x_segment22                         IN     VARCHAR2     ,
    x_segment23                         IN     VARCHAR2     ,
    x_segment24                         IN     VARCHAR2     ,
    x_segment25                         IN     VARCHAR2     ,
    x_segment26                         IN     VARCHAR2     ,
    x_segment27                         IN     VARCHAR2     ,
    x_segment28                         IN     VARCHAR2     ,
    x_segment29                         IN     VARCHAR2     ,
    x_segment30                         IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_sob_id,
      x_trx_id,
      x_dest_trx_id,
      x_source_trx_id,
      x_source_id,
      x_destination_id,
      x_code_combination_id,
      x_profile_code,
      x_budget_name,
      x_budget_entity_id,
      x_budget_amount,
      x_funds_available,
      x_new_balance,
      x_currency_code,
      x_visible_segments,
      x_actual_segments,
      x_m_budget_amount,
      x_m_budget_amt_exch_rate,
      x_m_budget_amt_exch_rate_type,
      x_m_budget_amt_exch_date,
      x_m_budget_amt_exch_status,
      x_m_funds_avail,
      x_m_funds_avail_exch_rate,
      x_m_funds_avail_exch_rate_type,
      x_m_funds_avail_exch_date,
      x_m_funds_avail_exch_status,
      x_m_new_balance,
      x_m_new_balance_exch_rate,
      x_m_new_balance_exch_rate_type,
      x_m_new_balance_exch_date,
      x_m_new_balance_exch_status,
      x_dossier_id,
      x_budget_version_id,
      x_period_name,
      x_percentage,
      x_status,
      x_group_id,
      x_quarter_num,
      x_period_year,
      x_period_num,
      x_line_num,
      x_segment1,
      x_segment2,
      x_segment3,
      x_segment4,
      x_segment5,
      x_segment6,
      x_segment7,
      x_segment8,
      x_segment9,
      x_segment10,
      x_segment11,
      x_segment12,
      x_segment13,
      x_segment14,
      x_segment15,
      x_segment16,
      x_segment17,
      x_segment18,
      x_segment19,
      x_segment20,
      x_segment21,
      x_segment22,
      x_segment23,
      x_segment24,
      x_segment25,
      x_segment26,
      x_segment27,
      x_segment28,
      x_segment29,
      x_segment30,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.dest_trx_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.before_dml.Msg1',FALSE);
        END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      --check_child_existance;
           null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.dest_trx_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.before_dml.Msg2',FALSE);
        END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN OUT NOCOPY NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE    dest_trx_id                       = x_dest_trx_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  l_mode VARCHAR2(1);

  BEGIN
  IF X_mode is NULL then
   l_mode :='R';
  ELSE
   l_mode := X_mode;
  END IF;

    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.insert_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    SELECT    igi_dos_trx_dest_s.NEXTVAL
    INTO      x_dest_trx_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sob_id                            => x_sob_id,
      x_trx_id                            => x_trx_id,
      x_dest_trx_id                       => x_dest_trx_id,
      x_source_trx_id                     => x_source_trx_id,
      x_source_id                         => x_source_id,
      x_destination_id                    => x_destination_id,
      x_code_combination_id               => x_code_combination_id,
      x_profile_code                      => x_profile_code,
      x_budget_name                       => x_budget_name,
      x_budget_entity_id                  => x_budget_entity_id,
      x_budget_amount                     => x_budget_amount,
      x_funds_available                   => x_funds_available,
      x_new_balance                       => x_new_balance,
      x_currency_code                     => x_currency_code,
      x_visible_segments                  => x_visible_segments,
      x_actual_segments                   => x_actual_segments,
      x_m_budget_amount                 => x_m_budget_amount,
      x_m_budget_amt_exch_rate          => x_m_budget_amt_exch_rate,
      x_m_budget_amt_exch_rate_type     => x_m_budget_amt_exch_rate_type,
      x_m_budget_amt_exch_date          => x_m_budget_amt_exch_date,
      x_m_budget_amt_exch_status        => x_m_budget_amt_exch_status,
      x_m_funds_avail                   => x_m_funds_avail,
      x_m_funds_avail_exch_rate         => x_m_funds_avail_exch_rate,
      x_m_funds_avail_exch_rate_type    => x_m_funds_avail_exch_rate_type,
      x_m_funds_avail_exch_date         => x_m_funds_avail_exch_date,
      x_m_funds_avail_exch_status       => x_m_funds_avail_exch_status,
      x_m_new_balance                   => x_m_new_balance,
      x_m_new_balance_exch_rate         => x_m_new_balance_exch_rate,
      x_m_new_balance_exch_rate_type    => x_m_new_balance_exch_rate_type,
      x_m_new_balance_exch_date         => x_m_new_balance_exch_date,
      x_m_new_balance_exch_status       => x_m_new_balance_exch_status,
      x_dossier_id                        => x_dossier_id,
      x_budget_version_id                 => x_budget_version_id,
      x_period_name                       => x_period_name,
      x_percentage                        => x_percentage,
      x_status                            => x_status,
      x_group_id                          => x_group_id,
      x_quarter_num                       => x_quarter_num,
      x_period_year                       => x_period_year,
      x_period_num                        => x_period_num,
      x_line_num                          => x_line_num,
      x_segment1                          => x_segment1,
      x_segment2                          => x_segment2,
      x_segment3                          => x_segment3,
      x_segment4                          => x_segment4,
      x_segment5                          => x_segment5,
      x_segment6                          => x_segment6,
      x_segment7                          => x_segment7,
      x_segment8                          => x_segment8,
      x_segment9                          => x_segment9,
      x_segment10                         => x_segment10,
      x_segment11                         => x_segment11,
      x_segment12                         => x_segment12,
      x_segment13                         => x_segment13,
      x_segment14                         => x_segment14,
      x_segment15                         => x_segment15,
      x_segment16                         => x_segment16,
      x_segment17                         => x_segment17,
      x_segment18                         => x_segment18,
      x_segment19                         => x_segment19,
      x_segment20                         => x_segment20,
      x_segment21                         => x_segment21,
      x_segment22                         => x_segment22,
      x_segment23                         => x_segment23,
      x_segment24                         => x_segment24,
      x_segment25                         => x_segment25,
      x_segment26                         => x_segment26,
      x_segment27                         => x_segment27,
      x_segment28                         => x_segment28,
      x_segment29                         => x_segment29,
      x_segment30                         => x_segment30,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_dos_trx_dest (
      sob_id,
      trx_id,
      dest_trx_id,
      source_trx_id,
      source_id,
      destination_id,
      code_combination_id,
      profile_code,
      budget_name,
      budget_entity_id,
      budget_amount,
      funds_available,
      new_balance,
      currency_code,
      visible_segments,
      actual_segments,
      mrc_budget_amount,
      mrc_budget_amt_exch_rate,
      mrc_budget_amt_exch_rate_type,
      mrc_budget_amt_exch_date,
      mrc_budget_amt_exch_status,
      mrc_funds_avail,
      mrc_funds_avail_exch_rate,
      mrc_funds_avail_exch_rate_type,
      mrc_funds_avail_exch_date,
      mrc_funds_avail_exch_status,
      mrc_new_balance,
      mrc_new_balance_exch_rate,
      mrc_new_balance_exch_rate_type,
      mrc_new_balance_exch_date,
      mrc_new_balance_exch_status,
      dossier_id,
      budget_version_id,
      period_name,
      percentage,
      status,
      group_id,
      quarter_num,
      period_year,
      period_num,
      line_num,
      segment1,
      segment2,
      segment3,
      segment4,
      segment5,
      segment6,
      segment7,
      segment8,
      segment9,
      segment10,
      segment11,
      segment12,
      segment13,
      segment14,
      segment15,
      segment16,
      segment17,
      segment18,
      segment19,
      segment20,
      segment21,
      segment22,
      segment23,
      segment24,
      segment25,
      segment26,
      segment27,
      segment28,
      segment29,
      segment30,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sob_id,
      new_references.trx_id,
      new_references.dest_trx_id,
      new_references.source_trx_id,
      new_references.source_id,
      new_references.destination_id,
      new_references.code_combination_id,
      new_references.profile_code,
      new_references.budget_name,
      new_references.budget_entity_id,
      new_references.budget_amount,
      new_references.funds_available,
      new_references.new_balance,
      new_references.currency_code,
      new_references.visible_segments,
      new_references.actual_segments,
      new_references.mrc_budget_amount,
      new_references.mrc_budget_amt_exch_rate,
      new_references.mrc_budget_amt_exch_rate_type,
      new_references.mrc_budget_amt_exch_date,
      new_references.mrc_budget_amt_exch_status,
      new_references.mrc_funds_avail,
      new_references.mrc_funds_avail_exch_rate,
      new_references.mrc_funds_avail_exch_rate_type,
      new_references.mrc_funds_avail_exch_date,
      new_references.mrc_funds_avail_exch_status,
      new_references.mrc_new_balance,
      new_references.mrc_new_balance_exch_rate,
      new_references.mrc_new_balance_exch_rate_type,
      new_references.mrc_new_balance_exch_date,
      new_references.mrc_new_balance_exch_status,
      new_references.dossier_id,
      new_references.budget_version_id,
      new_references.period_name,
      new_references.percentage,
      new_references.status,
      new_references.group_id,
      new_references.quarter_num,
      new_references.period_year,
      new_references.period_num,
      new_references.line_num,
      new_references.segment1,
      new_references.segment2,
      new_references.segment3,
      new_references.segment4,
      new_references.segment5,
      new_references.segment6,
      new_references.segment7,
      new_references.segment8,
      new_references.segment9,
      new_references.segment10,
      new_references.segment11,
      new_references.segment12,
      new_references.segment13,
      new_references.segment14,
      new_references.segment15,
      new_references.segment16,
      new_references.segment17,
      new_references.segment18,
      new_references.segment19,
      new_references.segment20,
      new_references.segment21,
      new_references.segment22,
      new_references.segment23,
      new_references.segment24,
      new_references.segment25,
      new_references.segment26,
      new_references.segment27,
      new_references.segment28,
      new_references.segment29,
      new_references.segment30,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN     NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        sob_id,
        trx_id,
        source_trx_id,
        source_id,
        destination_id,
        code_combination_id,
        profile_code,
        budget_name,
        budget_entity_id,
        budget_amount,
        funds_available,
        new_balance,
        currency_code,
        visible_segments,
        actual_segments,
        mrc_budget_amount,
        mrc_budget_amt_exch_rate,
        mrc_budget_amt_exch_rate_type,
        mrc_budget_amt_exch_date,
        mrc_budget_amt_exch_status,
        mrc_funds_avail,
        mrc_funds_avail_exch_rate,
        mrc_funds_avail_exch_rate_type,
        mrc_funds_avail_exch_date,
        mrc_funds_avail_exch_status,
        mrc_new_balance,
        mrc_new_balance_exch_rate,
        mrc_new_balance_exch_rate_type,
        mrc_new_balance_exch_date,
        mrc_new_balance_exch_status,
        dossier_id,
        budget_version_id,
        period_name,
        percentage,
        status,
        group_id,
        quarter_num,
        period_year,
        period_num,
        line_num,
        segment1,
        segment2,
        segment3,
        segment4,
        segment5,
        segment6,
        segment7,
        segment8,
        segment9,
        segment10,
        segment11,
        segment12,
        segment13,
        segment14,
        segment15,
        segment16,
        segment17,
        segment18,
        segment19,
        segment20,
        segment21,
        segment22,
        segment23,
        segment24,
        segment25,
        segment26,
        segment27,
        segment28,
        segment29,
        segment30
      FROM  igi_dos_trx_dest
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.sob_id = x_sob_id) OR ((tlinfo.sob_id IS NULL) AND (X_sob_id IS NULL)))
        AND ((tlinfo.trx_id = x_trx_id) OR ((tlinfo.trx_id IS NULL) AND (X_trx_id IS NULL)))
        AND ((tlinfo.source_trx_id = x_source_trx_id) OR ((tlinfo.source_trx_id IS NULL) AND (X_source_trx_id IS NULL)))
        AND ((tlinfo.source_id = x_source_id) OR ((tlinfo.source_id IS NULL) AND (X_source_id IS NULL)))
        AND ((tlinfo.destination_id = x_destination_id) OR ((tlinfo.destination_id IS NULL) AND (X_destination_id IS NULL)))
        AND ((tlinfo.code_combination_id = x_code_combination_id) OR ((tlinfo.code_combination_id IS NULL) AND (X_code_combination_id IS NULL)))
        AND ((tlinfo.profile_code = x_profile_code) OR ((tlinfo.profile_code IS NULL) AND (X_profile_code IS NULL)))
        AND ((tlinfo.budget_name = x_budget_name) OR ((tlinfo.budget_name IS NULL) AND (X_budget_name IS NULL)))
        AND ((tlinfo.budget_entity_id = x_budget_entity_id) OR ((tlinfo.budget_entity_id IS NULL) AND (X_budget_entity_id IS NULL)))
        AND ((tlinfo.budget_amount = x_budget_amount) OR ((tlinfo.budget_amount IS NULL) AND (X_budget_amount IS NULL)))
        AND ((tlinfo.funds_available = x_funds_available) OR ((tlinfo.funds_available IS NULL) AND (X_funds_available IS NULL)))
        AND ((tlinfo.new_balance = x_new_balance) OR ((tlinfo.new_balance IS NULL) AND (X_new_balance IS NULL)))
        AND ((tlinfo.currency_code = x_currency_code) OR ((tlinfo.currency_code IS NULL) AND (X_currency_code IS NULL)))
        AND ((tlinfo.visible_segments = x_visible_segments) OR ((tlinfo.visible_segments IS NULL) AND (X_visible_segments IS NULL)))
        AND ((tlinfo.actual_segments = x_actual_segments) OR ((tlinfo.actual_segments IS NULL) AND (X_actual_segments IS NULL)))
        AND ((tlinfo.mrc_budget_amount = x_m_budget_amount) OR ((tlinfo.mrc_budget_amount IS NULL) AND (x_m_budget_amount IS NULL)))
        AND ((tlinfo.mrc_budget_amt_exch_rate = x_m_budget_amt_exch_rate) OR ((tlinfo.mrc_budget_amt_exch_rate IS NULL) AND (x_m_budget_amt_exch_rate IS NULL)))
        AND ((tlinfo.mrc_budget_amt_exch_rate_type = x_m_budget_amt_exch_rate_type) OR ((tlinfo.mrc_budget_amt_exch_rate_type IS NULL) AND (x_m_budget_amt_exch_rate_type IS NULL)))
        AND ((tlinfo.mrc_budget_amt_exch_date = x_m_budget_amt_exch_date) OR ((tlinfo.mrc_budget_amt_exch_date IS NULL) AND (x_m_budget_amt_exch_date IS NULL)))
        AND ((tlinfo.mrc_budget_amt_exch_status = x_m_budget_amt_exch_status) OR ((tlinfo.mrc_budget_amt_exch_status IS NULL) AND (x_m_budget_amt_exch_status IS NULL)))
        AND ((tlinfo.mrc_funds_avail = x_m_funds_avail) OR ((tlinfo.mrc_funds_avail IS NULL) AND (x_m_funds_avail IS NULL)))
        AND ((tlinfo.mrc_funds_avail_exch_rate = x_m_funds_avail_exch_rate) OR ((tlinfo.mrc_funds_avail_exch_rate IS NULL) AND (x_m_funds_avail_exch_rate IS NULL)))
        AND ((tlinfo.mrc_funds_avail_exch_rate_type = x_m_funds_avail_exch_rate_type) OR ((tlinfo.mrc_funds_avail_exch_rate_type IS NULL) AND (x_m_funds_avail_exch_rate_type IS NULL)))
        AND ((tlinfo.mrc_funds_avail_exch_date = x_m_funds_avail_exch_date) OR ((tlinfo.mrc_funds_avail_exch_date IS NULL) AND (x_m_funds_avail_exch_date IS NULL)))
        AND ((tlinfo.mrc_funds_avail_exch_status = x_m_funds_avail_exch_status) OR ((tlinfo.mrc_funds_avail_exch_status IS NULL) AND (x_m_funds_avail_exch_status IS NULL)))
        AND ((tlinfo.mrc_new_balance = x_m_new_balance) OR ((tlinfo.mrc_new_balance IS NULL) AND (x_m_new_balance IS NULL)))
        AND ((tlinfo.mrc_new_balance_exch_rate = x_m_new_balance_exch_rate) OR ((tlinfo.mrc_new_balance_exch_rate IS NULL) AND (x_m_new_balance_exch_rate IS NULL)))
        AND ((tlinfo.mrc_new_balance_exch_rate_type = x_m_new_balance_exch_rate_type) OR ((tlinfo.mrc_new_balance_exch_rate_type IS NULL) AND (x_m_new_balance_exch_rate_type IS NULL)))
        AND ((tlinfo.mrc_new_balance_exch_date = x_m_new_balance_exch_date) OR ((tlinfo.mrc_new_balance_exch_date IS NULL) AND (x_m_new_balance_exch_date IS NULL)))
        AND ((tlinfo.mrc_new_balance_exch_status = x_m_new_balance_exch_status) OR ((tlinfo.mrc_new_balance_exch_status IS NULL) AND (x_m_new_balance_exch_status IS NULL)))
        AND ((tlinfo.dossier_id = x_dossier_id) OR ((tlinfo.dossier_id IS NULL) AND (X_dossier_id IS NULL)))
        AND ((tlinfo.budget_version_id = x_budget_version_id) OR ((tlinfo.budget_version_id IS NULL) AND (X_budget_version_id IS NULL)))
        AND ((tlinfo.period_name = x_period_name) OR ((tlinfo.period_name IS NULL) AND (X_period_name IS NULL)))
        AND ((tlinfo.percentage = x_percentage) OR ((tlinfo.percentage IS NULL) AND (X_percentage IS NULL)))
        AND ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
        AND ((tlinfo.group_id = x_group_id) OR ((tlinfo.group_id IS NULL) AND (X_group_id IS NULL)))
        AND ((tlinfo.quarter_num = x_quarter_num) OR ((tlinfo.quarter_num IS NULL) AND (X_quarter_num IS NULL)))
        AND ((tlinfo.period_year = x_period_year) OR ((tlinfo.period_year IS NULL) AND (X_period_year IS NULL)))
        AND ((tlinfo.period_num = x_period_num) OR ((tlinfo.period_num IS NULL) AND (X_period_num IS NULL)))
        AND ((tlinfo.line_num = x_line_num) OR ((tlinfo.line_num IS NULL) AND (X_line_num IS NULL)))
        AND ((tlinfo.segment1 = x_segment1) OR ((tlinfo.segment1 IS NULL) AND (X_segment1 IS NULL)))
        AND ((tlinfo.segment2 = x_segment2) OR ((tlinfo.segment2 IS NULL) AND (X_segment2 IS NULL)))
        AND ((tlinfo.segment3 = x_segment3) OR ((tlinfo.segment3 IS NULL) AND (X_segment3 IS NULL)))
        AND ((tlinfo.segment4 = x_segment4) OR ((tlinfo.segment4 IS NULL) AND (X_segment4 IS NULL)))
        AND ((tlinfo.segment5 = x_segment5) OR ((tlinfo.segment5 IS NULL) AND (X_segment5 IS NULL)))
        AND ((tlinfo.segment6 = x_segment6) OR ((tlinfo.segment6 IS NULL) AND (X_segment6 IS NULL)))
        AND ((tlinfo.segment7 = x_segment7) OR ((tlinfo.segment7 IS NULL) AND (X_segment7 IS NULL)))
        AND ((tlinfo.segment8 = x_segment8) OR ((tlinfo.segment8 IS NULL) AND (X_segment8 IS NULL)))
        AND ((tlinfo.segment9 = x_segment9) OR ((tlinfo.segment9 IS NULL) AND (X_segment9 IS NULL)))
        AND ((tlinfo.segment10 = x_segment10) OR ((tlinfo.segment10 IS NULL) AND (X_segment10 IS NULL)))
        AND ((tlinfo.segment11 = x_segment11) OR ((tlinfo.segment11 IS NULL) AND (X_segment11 IS NULL)))
        AND ((tlinfo.segment12 = x_segment12) OR ((tlinfo.segment12 IS NULL) AND (X_segment12 IS NULL)))
        AND ((tlinfo.segment13 = x_segment13) OR ((tlinfo.segment13 IS NULL) AND (X_segment13 IS NULL)))
        AND ((tlinfo.segment14 = x_segment14) OR ((tlinfo.segment14 IS NULL) AND (X_segment14 IS NULL)))
        AND ((tlinfo.segment15 = x_segment15) OR ((tlinfo.segment15 IS NULL) AND (X_segment15 IS NULL)))
        AND ((tlinfo.segment16 = x_segment16) OR ((tlinfo.segment16 IS NULL) AND (X_segment16 IS NULL)))
        AND ((tlinfo.segment17 = x_segment17) OR ((tlinfo.segment17 IS NULL) AND (X_segment17 IS NULL)))
        AND ((tlinfo.segment18 = x_segment18) OR ((tlinfo.segment18 IS NULL) AND (X_segment18 IS NULL)))
        AND ((tlinfo.segment19 = x_segment19) OR ((tlinfo.segment19 IS NULL) AND (X_segment19 IS NULL)))
        AND ((tlinfo.segment20 = x_segment20) OR ((tlinfo.segment20 IS NULL) AND (X_segment20 IS NULL)))
        AND ((tlinfo.segment21 = x_segment21) OR ((tlinfo.segment21 IS NULL) AND (X_segment21 IS NULL)))
        AND ((tlinfo.segment22 = x_segment22) OR ((tlinfo.segment22 IS NULL) AND (X_segment22 IS NULL)))
        AND ((tlinfo.segment23 = x_segment23) OR ((tlinfo.segment23 IS NULL) AND (X_segment23 IS NULL)))
        AND ((tlinfo.segment24 = x_segment24) OR ((tlinfo.segment24 IS NULL) AND (X_segment24 IS NULL)))
        AND ((tlinfo.segment25 = x_segment25) OR ((tlinfo.segment25 IS NULL) AND (X_segment25 IS NULL)))
        AND ((tlinfo.segment26 = x_segment26) OR ((tlinfo.segment26 IS NULL) AND (X_segment26 IS NULL)))
        AND ((tlinfo.segment27 = x_segment27) OR ((tlinfo.segment27 IS NULL) AND (X_segment27 IS NULL)))
        AND ((tlinfo.segment28 = x_segment28) OR ((tlinfo.segment28 IS NULL) AND (X_segment28 IS NULL)))
        AND ((tlinfo.segment29 = x_segment29) OR ((tlinfo.segment29 IS NULL) AND (X_segment29 IS NULL)))
        AND ((tlinfo.segment30 = x_segment30) OR ((tlinfo.segment30 IS NULL) AND (X_segment30 IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.lock_row.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN     NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  l_mode VARCHAR2(1);

  BEGIN
  IF X_mode is NULL then
   l_mode :='R';
  ELSE
   l_mode := X_mode;
  END IF;

    x_last_update_date := SYSDATE;
    IF (l_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_dest_pkg.update_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sob_id                            => x_sob_id,
      x_trx_id                            => x_trx_id,
      x_dest_trx_id                       => x_dest_trx_id,
      x_source_trx_id                     => x_source_trx_id,
      x_source_id                         => x_source_id,
      x_destination_id                    => x_destination_id,
      x_code_combination_id               => x_code_combination_id,
      x_profile_code                      => x_profile_code,
      x_budget_name                       => x_budget_name,
      x_budget_entity_id                  => x_budget_entity_id,
      x_budget_amount                     => x_budget_amount,
      x_funds_available                   => x_funds_available,
      x_new_balance                       => x_new_balance,
      x_currency_code                     => x_currency_code,
      x_visible_segments                  => x_visible_segments,
      x_actual_segments                   => x_actual_segments,
      x_m_budget_amount                 => x_m_budget_amount,
      x_m_budget_amt_exch_rate          => x_m_budget_amt_exch_rate,
      x_m_budget_amt_exch_rate_type     => x_m_budget_amt_exch_rate_type,
      x_m_budget_amt_exch_date          => x_m_budget_amt_exch_date,
      x_m_budget_amt_exch_status        => x_m_budget_amt_exch_status,
      x_m_funds_avail                   => x_m_funds_avail,
      x_m_funds_avail_exch_rate         => x_m_funds_avail_exch_rate,
      x_m_funds_avail_exch_rate_type    => x_m_funds_avail_exch_rate_type,
      x_m_funds_avail_exch_date         => x_m_funds_avail_exch_date,
      x_m_funds_avail_exch_status       => x_m_funds_avail_exch_status,
      x_m_new_balance                   => x_m_new_balance,
      x_m_new_balance_exch_rate         => x_m_new_balance_exch_rate,
      x_m_new_balance_exch_rate_type    => x_m_new_balance_exch_rate_type,
      x_m_new_balance_exch_date         => x_m_new_balance_exch_date,
      x_m_new_balance_exch_status       => x_m_new_balance_exch_status,
      x_dossier_id                        => x_dossier_id,
      x_budget_version_id                 => x_budget_version_id,
      x_period_name                       => x_period_name,
      x_percentage                        => x_percentage,
      x_status                            => x_status,
      x_group_id                          => x_group_id,
      x_quarter_num                       => x_quarter_num,
      x_period_year                       => x_period_year,
      x_period_num                        => x_period_num,
      x_line_num                          => x_line_num,
      x_segment1                          => x_segment1,
      x_segment2                          => x_segment2,
      x_segment3                          => x_segment3,
      x_segment4                          => x_segment4,
      x_segment5                          => x_segment5,
      x_segment6                          => x_segment6,
      x_segment7                          => x_segment7,
      x_segment8                          => x_segment8,
      x_segment9                          => x_segment9,
      x_segment10                         => x_segment10,
      x_segment11                         => x_segment11,
      x_segment12                         => x_segment12,
      x_segment13                         => x_segment13,
      x_segment14                         => x_segment14,
      x_segment15                         => x_segment15,
      x_segment16                         => x_segment16,
      x_segment17                         => x_segment17,
      x_segment18                         => x_segment18,
      x_segment19                         => x_segment19,
      x_segment20                         => x_segment20,
      x_segment21                         => x_segment21,
      x_segment22                         => x_segment22,
      x_segment23                         => x_segment23,
      x_segment24                         => x_segment24,
      x_segment25                         => x_segment25,
      x_segment26                         => x_segment26,
      x_segment27                         => x_segment27,
      x_segment28                         => x_segment28,
      x_segment29                         => x_segment29,
      x_segment30                         => x_segment30,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_dos_trx_dest
      SET
        sob_id                            = new_references.sob_id,
        trx_id                            = new_references.trx_id,
        source_trx_id                     = new_references.source_trx_id,
        source_id                         = new_references.source_id,
        destination_id                    = new_references.destination_id,
        code_combination_id               = new_references.code_combination_id,
        profile_code                      = new_references.profile_code,
        budget_name                       = new_references.budget_name,
        budget_entity_id                  = new_references.budget_entity_id,
        budget_amount                     = new_references.budget_amount,
        funds_available                   = new_references.funds_available,
        new_balance                       = new_references.new_balance,
        currency_code                     = new_references.currency_code,
        visible_segments                  = new_references.visible_segments,
        actual_segments                   = new_references.actual_segments,
        mrc_budget_amount                 = new_references.mrc_budget_amount,
        mrc_budget_amt_exch_rate          = new_references.mrc_budget_amt_exch_rate,
        mrc_budget_amt_exch_rate_type     = new_references.mrc_budget_amt_exch_rate_type,
        mrc_budget_amt_exch_date          = new_references.mrc_budget_amt_exch_date,
        mrc_budget_amt_exch_status        = new_references.mrc_budget_amt_exch_status,
        mrc_funds_avail                   = new_references.mrc_funds_avail,
        mrc_funds_avail_exch_rate         = new_references.mrc_funds_avail_exch_rate,
        mrc_funds_avail_exch_rate_type    = new_references.mrc_funds_avail_exch_rate_type,
        mrc_funds_avail_exch_date         = new_references.mrc_funds_avail_exch_date,
        mrc_funds_avail_exch_status       = new_references.mrc_funds_avail_exch_status,
        mrc_new_balance                   = new_references.mrc_new_balance,
        mrc_new_balance_exch_rate         = new_references.mrc_new_balance_exch_rate,
        mrc_new_balance_exch_rate_type    = new_references.mrc_new_balance_exch_rate_type,
        mrc_new_balance_exch_date         = new_references.mrc_new_balance_exch_date,
        mrc_new_balance_exch_status       = new_references.mrc_new_balance_exch_status,
        dossier_id                        = new_references.dossier_id,
        budget_version_id                 = new_references.budget_version_id,
        period_name                       = new_references.period_name,
        percentage                        = new_references.percentage,
        status                            = new_references.status,
        group_id                          = new_references.group_id,
        quarter_num                       = new_references.quarter_num,
        period_year                       = new_references.period_year,
        period_num                        = new_references.period_num,
        line_num                          = new_references.line_num,
        segment1                          = new_references.segment1,
        segment2                          = new_references.segment2,
        segment3                          = new_references.segment3,
        segment4                          = new_references.segment4,
        segment5                          = new_references.segment5,
        segment6                          = new_references.segment6,
        segment7                          = new_references.segment7,
        segment8                          = new_references.segment8,
        segment9                          = new_references.segment9,
        segment10                         = new_references.segment10,
        segment11                         = new_references.segment11,
        segment12                         = new_references.segment12,
        segment13                         = new_references.segment13,
        segment14                         = new_references.segment14,
        segment15                         = new_references.segment15,
        segment16                         = new_references.segment16,
        segment17                         = new_references.segment17,
        segment18                         = new_references.segment18,
        segment19                         = new_references.segment19,
        segment20                         = new_references.segment20,
        segment21                         = new_references.segment21,
        segment22                         = new_references.segment22,
        segment23                         = new_references.segment23,
        segment24                         = new_references.segment24,
        segment25                         = new_references.segment25,
        segment26                         = new_references.segment26,
        segment27                         = new_references.segment27,
        segment28                         = new_references.segment28,
        segment29                         = new_references.segment29,
        segment30                         = new_references.segment30,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN OUT NOCOPY NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_dos_trx_dest
      WHERE    dest_trx_id                       = x_dest_trx_id;

  l_mode VARCHAR2(1);
  BEGIN
  IF X_mode is NULL then
   l_mode :='R';
  ELSE
   l_mode := X_mode;
  END IF;

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sob_id,
        x_trx_id,
        x_dest_trx_id,
        x_source_trx_id,
        x_source_id,
        x_destination_id,
        x_code_combination_id,
        x_profile_code,
        x_budget_name,
        x_budget_entity_id,
        x_budget_amount,
        x_funds_available,
        x_new_balance,
        x_currency_code,
        x_visible_segments,
        x_actual_segments,
        x_m_budget_amount,
        x_m_budget_amt_exch_rate,
        x_m_budget_amt_exch_rate_type,
        x_m_budget_amt_exch_date,
        x_m_budget_amt_exch_status,
        x_m_funds_avail,
        x_m_funds_avail_exch_rate,
        x_m_funds_avail_exch_rate_type,
        x_m_funds_avail_exch_date,
        x_m_funds_avail_exch_status,
        x_m_new_balance,
        x_m_new_balance_exch_rate,
        x_m_new_balance_exch_rate_type,
        x_m_new_balance_exch_date,
        x_m_new_balance_exch_status,
        x_dossier_id,
        x_budget_version_id,
        x_period_name,
        x_percentage,
        x_status,
        x_group_id,
        x_quarter_num,
        x_period_year,
        x_period_num,
        x_line_num,
        x_segment1,
        x_segment2,
        x_segment3,
        x_segment4,
        x_segment5,
        x_segment6,
        x_segment7,
        x_segment8,
        x_segment9,
        x_segment10,
        x_segment11,
        x_segment12,
        x_segment13,
        x_segment14,
        x_segment15,
        x_segment16,
        x_segment17,
        x_segment18,
        x_segment19,
        x_segment20,
        x_segment21,
        x_segment22,
        x_segment23,
        x_segment24,
        x_segment25,
        x_segment26,
        x_segment27,
        x_segment28,
        x_segment29,
        x_segment30,
        l_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sob_id,
      x_trx_id,
      x_dest_trx_id,
      x_source_trx_id,
      x_source_id,
      x_destination_id,
      x_code_combination_id,
      x_profile_code,
      x_budget_name,
      x_budget_entity_id,
      x_budget_amount,
      x_funds_available,
      x_new_balance,
      x_currency_code,
      x_visible_segments,
      x_actual_segments,
      x_m_budget_amount,
      x_m_budget_amt_exch_rate,
      x_m_budget_amt_exch_rate_type,
      x_m_budget_amt_exch_date,
      x_m_budget_amt_exch_status,
      x_m_funds_avail,
      x_m_funds_avail_exch_rate,
      x_m_funds_avail_exch_rate_type,
      x_m_funds_avail_exch_date,
      x_m_funds_avail_exch_status,
      x_m_new_balance,
      x_m_new_balance_exch_rate,
      x_m_new_balance_exch_rate_type,
      x_m_new_balance_exch_date,
      x_m_new_balance_exch_status,
      x_dossier_id,
      x_budget_version_id,
      x_period_name,
      x_percentage,
      x_status,
      x_group_id,
      x_quarter_num,
      x_period_year,
      x_period_num,
      x_line_num,
      x_segment1,
      x_segment2,
      x_segment3,
      x_segment4,
      x_segment5,
      x_segment6,
      x_segment7,
      x_segment8,
      x_segment9,
      x_segment10,
      x_segment11,
      x_segment12,
      x_segment13,
      x_segment14,
      x_segment15,
      x_segment16,
      x_segment17,
      x_segment18,
      x_segment19,
      x_segment20,
      x_segment21,
      x_segment22,
      x_segment23,
      x_segment24,
      x_segment25,
      x_segment26,
      x_segment27,
      x_segment28,
      x_segment29,
      x_segment30,
      l_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 02-MAY-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

 before_dml(
      p_action                            => 'DELETE',
      x_rowid                             => x_rowid,
      x_sob_id                            => NULL,
      x_trx_id                            => NULL,
      x_dest_trx_id                       => NULL,
      x_source_trx_id                     => NULL,
      x_source_id                         => NULL,
      x_destination_id                    => NULL,
      x_code_combination_id               => NULL,
      x_profile_code                      => NULL,
      x_budget_name                       => NULL,
      x_budget_entity_id                  => NULL,
      x_budget_amount                     => NULL,
      x_funds_available                   => NULL,
      x_new_balance                       => NULL,
      x_currency_code                     => NULL,
      x_visible_segments                  => NULL,
      x_actual_segments                   => NULL,
      x_m_budget_amount                 => NULL,
      x_m_budget_amt_exch_rate          => NULL,
      x_m_budget_amt_exch_rate_type     => NULL,
      x_m_budget_amt_exch_date          => NULL,
      x_m_budget_amt_exch_status        => NULL,
      x_m_funds_avail                   => NULL,
      x_m_funds_avail_exch_rate         => NULL,
      x_m_funds_avail_exch_rate_type    => NULL,
      x_m_funds_avail_exch_date         => NULL,
      x_m_funds_avail_exch_status       => NULL,
      x_m_new_balance                   => NULL,
      x_m_new_balance_exch_rate         => NULL,
      x_m_new_balance_exch_rate_type    => NULL,
      x_m_new_balance_exch_date         => NULL,
      x_m_new_balance_exch_status       => NULL,
      x_dossier_id                        => NULL,
      x_budget_version_id                 => NULL,
      x_period_name                       => NULL,
      x_percentage                        => NULL,
      x_status                            => NULL,
      x_group_id                          => NULL,
      x_quarter_num                       => NULL,
      x_period_year                       => NULL,
      x_period_num                        => NULL,
      x_line_num                          => NULL,
      x_segment1                          => NULL,
      x_segment2                          => NULL,
      x_segment3                          => NULL,
      x_segment4                          => NULL,
      x_segment5                          => NULL,
      x_segment6                          => NULL,
      x_segment7                          => NULL,
      x_segment8                          => NULL,
      x_segment9                          => NULL,
      x_segment10                         => NULL,
      x_segment11                         => NULL,
      x_segment12                         => NULL,
      x_segment13                         => NULL,
      x_segment14                         => NULL,
      x_segment15                         => NULL,
      x_segment16                         => NULL,
      x_segment17                         => NULL,
      x_segment18                         => NULL,
      x_segment19                         => NULL,
      x_segment20                         => NULL,
      x_segment21                         => NULL,
      x_segment22                         => NULL,
      x_segment23                         => NULL,
      x_segment24                         => NULL,
      x_segment25                         => NULL,
      x_segment26                         => NULL,
      x_segment27                         => NULL,
      x_segment28                         => NULL,
      x_segment29                         => NULL,
      x_segment30                         => NULL,
      x_creation_date                     => NULL,
      x_created_by                        => NULL,
      x_last_update_date                  => NULL,
      x_last_updated_by                   => NULL,
      x_last_update_login                 => NULL
    );


    DELETE FROM igi_dos_trx_dest
    WHERE rowid = x_rowid;

    --IF (SQL%NOTFOUND) THEN
     -- RAISE NO_DATA_FOUND;
    --END IF;

  END delete_row;
Begin
l_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level    := FND_LOG.LEVEL_STATEMENT ;
l_proc_level     := FND_LOG.LEVEL_PROCEDURE ;
l_event_level    := FND_LOG.LEVEL_EVENT ;
l_excep_level    := FND_LOG.LEVEL_EXCEPTION ;
l_error_level    := FND_LOG.LEVEL_ERROR ;
l_unexp_level    := FND_LOG.LEVEL_UNEXPECTED ;



END igi_dos_trx_dest_pkg;

/
