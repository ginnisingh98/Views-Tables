--------------------------------------------------------
--  DDL for Package Body IGI_DOS_TRX_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_TRX_HEADERS_PKG" AS
/* $Header: igidossb.pls 120.11.12010000.2 2008/08/04 13:00:56 sasukuma ship $ */

l_debug_level   number;

l_state_level   number;
l_proc_level    number;
l_event_level   number;
l_excep_level   number;
l_error_level   number;
l_unexp_level   number;

  l_rowid VARCHAR2(25);
  old_references igi_dos_trx_headers%ROWTYPE;
  new_references igi_dos_trx_headers%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_sob_id                            IN     NUMBER       ,
    x_trx_id                            IN     NUMBER       ,
    x_dossier_name                      IN     VARCHAR2     ,
    x_trx_number                        IN     VARCHAR2     ,
    x_packet_id                         IN     NUMBER       ,
    x_trx_status                        IN     VARCHAR2     ,
    x_dossier_id                        IN     NUMBER       ,
    x_dossier_transaction_name          IN     VARCHAR2     ,
    x_description                       IN     VARCHAR2     ,
    x_funds_status                      IN     VARCHAR2     ,
    x_attribute_category                IN     VARCHAR2     ,
    x_attribute1                        IN     VARCHAR2     ,
    x_attribute2                        IN     VARCHAR2     ,
    x_attribute3                        IN     VARCHAR2     ,
    x_attribute4                        IN     VARCHAR2     ,
    x_attribute5                        IN     VARCHAR2     ,
    x_attribute6                        IN     VARCHAR2     ,
    x_attribute7                        IN     VARCHAR2     ,
    x_attribute8                        IN     VARCHAR2     ,
    x_attribute9                        IN     VARCHAR2     ,
    x_attribute10                       IN     VARCHAR2     ,
    x_attribute11                       IN     VARCHAR2     ,
    x_attribute12                       IN     VARCHAR2     ,
    x_attribute13                       IN     VARCHAR2     ,
    x_attribute14                       IN     VARCHAR2     ,
    x_attribute15                       IN     VARCHAR2     ,
    x_attribute16                       IN     VARCHAR2     ,
    x_attribute17                       IN     VARCHAR2     ,
    x_attribute18                       IN     VARCHAR2     ,
    x_attribute19                       IN     VARCHAR2     ,
    x_attribute20                       IN     VARCHAR2     ,
    x_attribute21                       IN     VARCHAR2     ,
    x_attribute22                       IN     VARCHAR2     ,
    x_attribute23                       IN     VARCHAR2     ,
    x_attribute24                       IN     VARCHAR2     ,
    x_attribute25                       IN     VARCHAR2     ,
    x_attribute26                       IN     VARCHAR2     ,
    x_attribute27                       IN     VARCHAR2     ,
    x_attribute28                       IN     VARCHAR2     ,
    x_attribute29                       IN     VARCHAR2     ,
    x_attribute30                       IN     VARCHAR2     ,
    x_parent_trx_id                     IN     NUMBER       ,
    x_parent_trx_number                 IN     VARCHAR2     ,
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
      FROM     igi_dos_trx_headers
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.set_column_values.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.sob_id                            := x_sob_id;
    new_references.trx_id                            := x_trx_id;
    new_references.dossier_name                      := x_dossier_name;
    new_references.trx_number                        := x_trx_number;
    new_references.packet_id                         := x_packet_id;
    new_references.trx_status                        := x_trx_status;
    new_references.dossier_id                        := x_dossier_id;
    new_references.dossier_transaction_name          := x_dossier_transaction_name;
    new_references.description                       := x_description;
    new_references.funds_status                      := x_funds_status;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.attribute21                       := x_attribute21;
    new_references.attribute22                       := x_attribute22;
    new_references.attribute23                       := x_attribute23;
    new_references.attribute24                       := x_attribute24;
    new_references.attribute25                       := x_attribute25;
    new_references.attribute26                       := x_attribute26;
    new_references.attribute27                       := x_attribute27;
    new_references.attribute28                       := x_attribute28;
    new_references.attribute29                       := x_attribute29;
    new_references.attribute30                       := x_attribute30;
    new_references.parent_trx_id                     := x_parent_trx_id;
    new_references.parent_trx_number                 := x_parent_trx_number;

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


  -- Trigger description :-
  -- IGI_DOS_TRX_HEADERS_T1
  --  BEFORE UPDATE OF TRX_STATUS
  --  ON IGI_DOS_TRX_HEADERS
  --  REFERENCING OLD AS OLD NEW AS NEW
  --  FOR EACH ROW
  -- -- PL/SQL Block

  PROCEDURE BeforeRowUpdate1(
    p_updating  IN BOOLEAN
  ) AS
x_history_trx_id number;

  BEGIN

--
-- Bug 2897525 Start(1)
--
--       select   igi_dos_trx_history_s.nextval
       SELECT   igi_dos_trx_headers_hist_s.NEXTVAL
--
-- Bug 2897525 End(1)
--
       into     x_history_trx_id
       from     dual;

        insert into igi_dos_trx_headers_hist
                 (
                  trx_id                     ,
                  dossier_name               ,
                  trx_number                 ,
                  packet_id                  ,
                  trx_status                 ,
                  dossier_id                 ,
 		  dossier_transaction_name   ,
                  description                ,
                  last_update_date           ,
                  history_trx_id
                   )
                   values (
                    new_references.trx_id                     ,
                    new_references.dossier_name               ,
                    new_references.trx_number                 ,
                    new_references.packet_id                  ,
                    new_references.trx_status                 ,
                    new_references.dossier_id                 ,
                    new_references.dossier_transaction_name   ,
                    new_references.description                ,
                    new_references.last_update_date           ,
                    x_history_trx_id
                  );




INSERT INTO igi_dos_trx_sources_hist
 (
  sob_id                  ,
  trx_id                  ,
  source_trx_id           ,
  source_id               ,
  code_combination_id     ,
  profile_code            ,
  budget_org_id           ,
  budget_entity_id        ,
  budget_amount           ,
  funds_available         ,
  new_balance             ,
  currency_code           ,
  visible_segments        ,
  actual_segments         ,
  mrc_budget_amount       ,
  mrc_budget_amt_exch_rate      ,
  mrc_budget_amt_exch_rate_type  ,
  mrc_budget_amt_exch_date   ,
  mrc_budget_amt_exch_status  ,
  mrc_funds_avail            ,
  mrc_funds_avail_exch_rate  ,
  mrc_funds_avail_exch_rate_type  ,
  mrc_funds_avail_exch_date  ,
  mrc_funds_avail_exch_status  ,
  mrc_new_balance            ,
  mrc_new_balance_exch_rate  ,
  mrc_new_balance_exch_rate_type  ,
  mrc_new_balance_exch_date  ,
  mrc_new_balance_exch_status  ,
  budget_name                ,
  dossier_id                 ,
  budget_version_id          ,
  period_name                ,
  status                     ,
  group_id                   ,
  quarter_num                ,
  period_year                ,
  period_num                 ,
  history_trx_id)
  SELECT
  sob_id                  ,
  trx_id                  ,
  source_trx_id           ,
  source_id               ,
  code_combination_id     ,
  profile_code            ,
  budget_org_id           ,
  budget_entity_id        ,
  budget_amount           ,
  funds_available         ,
  new_balance             ,
  currency_code           ,
  visible_segments        ,
  actual_segments         ,
  mrc_budget_amount       ,
  mrc_budget_amt_exch_rate      ,
  mrc_budget_amt_exch_rate_type  ,
  mrc_budget_amt_exch_date   ,
  mrc_budget_amt_exch_status  ,
  mrc_funds_avail            ,
  mrc_funds_avail_exch_rate  ,
  mrc_funds_avail_exch_rate_type  ,
  mrc_funds_avail_exch_date  ,
  mrc_funds_avail_exch_status  ,
  mrc_new_balance            ,
  mrc_new_balance_exch_rate
,
  mrc_new_balance_exch_rate_type  ,
  mrc_new_balance_exch_date  ,
  mrc_new_balance_exch_status  ,
  budget_name                ,
  dossier_id                 ,
  budget_version_id          ,
  period_name                ,
  status                     ,
  group_id                   ,
  quarter_num                ,
  period_year                ,
  period_num                 ,
  x_history_trx_id
  from igi_dos_trx_sources
  where trx_id = new_references.trx_id;

  insert into igi_dos_trx_dest_hist
 (
  sob_id                     ,
  trx_id                     ,
  dest_trx_id                ,
  source_id                  ,
  destination_id             ,
  code_combination_id        ,
  profile_code               ,
  budget_name                ,
  budget_entity_id           ,
  budget_amount              ,
  funds_available            ,
  new_balance                ,
  currency_code              ,
  visible_segments           ,
  actual_segments            ,
  mrc_budget_amount          ,
  mrc_budget_amt_exch_rate   ,
  mrc_budget_amt_exch_rate_type  ,
  mrc_budget_amt_exch_date   ,
  mrc_budget_amt_exch_status  ,
  mrc_funds_avail            ,
  mrc_funds_avail_exch_rate  ,
  mrc_funds_avail_exch_rate_type  ,
  mrc_funds_avail_exch_date  ,
  mrc_funds_avail_exch_status  ,
  mrc_new_balance            ,
  mrc_new_balance_exch_rate  ,
  mrc_new_balance_exch_rate_type  ,
  mrc_new_balance_exch_date  ,
  mrc_new_balance_exch_status  ,
  dossier_id                 ,
  budget_version_id          ,
  period_name                ,
  percentage                 ,
  status                     ,
  group_id                   ,
  quarter_num                ,
  period_year                ,
  period_num                 ,
  history_trx_id
 )
 select
  sob_id                     ,
  trx_id                     ,
  dest_trx_id                ,
  source_id                  ,
  destination_id             ,
  code_combination_id        ,
  profile_code               ,
  budget_name                ,
  budget_entity_id           ,
  budget_amount              ,
  funds_available            ,
  new_balance                ,
  currency_code              ,
  visible_segments           ,
  actual_segments            ,
  mrc_budget_amount          ,
  mrc_budget_amt_exch_rate   ,
  mrc_budget_amt_exch_rate_type  ,
  mrc_budget_amt_exch_date   ,
  mrc_budget_amt_exch_status  ,
  mrc_funds_avail            ,
  mrc_funds_avail_exch_rate  ,

mrc_funds_avail_exch_rate_type  ,
  mrc_funds_avail_exch_date  ,
  mrc_funds_avail_exch_status  ,
  mrc_new_balance            ,
  mrc_new_balance_exch_rate  ,
  mrc_new_balance_exch_rate_type  ,
  mrc_new_balance_exch_date  ,
  mrc_new_balance_exch_status  ,
  dossier_id                 ,
  budget_version_id          ,
  period_name                ,
  percentage                 ,
  status                     ,
  group_id                   ,
  quarter_num                ,
  period_year                ,
  period_num                 ,
  x_history_trx_id
 from igi_dos_trx_dest
 where trx_id = new_references.trx_id;


  END BeforeRowUpdate1;


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

    IF (((old_references.dossier_id = new_references.dossier_id)) OR
        ((new_references.dossier_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_doc_types_pkg.get_pk_for_validation (
                new_references.dossier_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.check_parent_existance.Msg1',FALSE);
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

    igi_dos_trx_dest_pkg.get_fk_igi_dos_trx_headers (
      old_references.trx_id
    );
    /* sowsubra  06-JUN-2002 start */
   /* Commented the following code as this  igi_dos_headers_dest_hist_pkg
   	is currently not present  */

    /*igi_dos_trx_headers_hist_pkg.get_fk_igi_dos_trx_headers (
      old_references.trx_id
    );*/
       /* sowsubra  06-JUN-2002 end */


    igi_dos_trx_sources_pkg.get_fk_igi_dos_trx_headers (
      old_references.trx_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_trx_id                            IN     NUMBER
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
      FROM     igi_dos_trx_headers
      WHERE    trx_id = x_trx_id
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
      FROM     igi_dos_trx_headers
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.get_fk_igi_dos_doc_types.Msg1',FALSE);
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
    x_dossier_name                      IN     VARCHAR2     ,
    x_trx_number                        IN     VARCHAR2     ,
    x_packet_id                         IN     NUMBER       ,
    x_trx_status                        IN     VARCHAR2     ,
    x_dossier_id                        IN     NUMBER       ,
    x_dossier_transaction_name          IN     VARCHAR2     ,
    x_description                       IN     VARCHAR2     ,
    x_funds_status                      IN     VARCHAR2     ,
    x_attribute_category                IN     VARCHAR2     ,
    x_attribute1                        IN     VARCHAR2     ,
    x_attribute2                        IN     VARCHAR2     ,
    x_attribute3                        IN     VARCHAR2     ,
    x_attribute4                        IN     VARCHAR2     ,
    x_attribute5                        IN     VARCHAR2     ,
    x_attribute6                        IN     VARCHAR2     ,
    x_attribute7                        IN     VARCHAR2     ,
    x_attribute8                        IN     VARCHAR2     ,
    x_attribute9                        IN     VARCHAR2     ,
    x_attribute10                       IN     VARCHAR2     ,
    x_attribute11                       IN     VARCHAR2     ,
    x_attribute12                       IN     VARCHAR2     ,
    x_attribute13                       IN     VARCHAR2     ,
    x_attribute14                       IN     VARCHAR2     ,
    x_attribute15                       IN     VARCHAR2     ,
    x_attribute16                       IN     VARCHAR2     ,
    x_attribute17                       IN     VARCHAR2     ,
    x_attribute18                       IN     VARCHAR2     ,
    x_attribute19                       IN     VARCHAR2     ,
    x_attribute20                       IN     VARCHAR2     ,
    x_attribute21                       IN     VARCHAR2     ,
    x_attribute22                       IN     VARCHAR2     ,
    x_attribute23                       IN     VARCHAR2     ,
    x_attribute24                       IN     VARCHAR2     ,
    x_attribute25                       IN     VARCHAR2     ,
    x_attribute26                       IN     VARCHAR2     ,
    x_attribute27                       IN     VARCHAR2     ,
    x_attribute28                       IN     VARCHAR2     ,
    x_attribute29                       IN     VARCHAR2     ,
    x_attribute30                       IN     VARCHAR2     ,
    x_parent_trx_id                     IN     NUMBER       ,
    x_parent_trx_number                 IN     VARCHAR2     ,
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
      x_dossier_name,
      x_trx_number,
      x_packet_id,
      x_trx_status,
      x_dossier_id,
      x_dossier_transaction_name,
      x_description,
      x_funds_status,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24,
      x_attribute25,
      x_attribute26,
      x_attribute27,
      x_attribute28,
      x_attribute29,
      x_attribute30,
      x_parent_trx_id,
      x_parent_trx_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.trx_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.before_dml.Msg1',FALSE);
        END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowUpdate1 ( p_updating => TRUE );
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.trx_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.before_dml.Msg2',FALSE);
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
    x_sob_id							IN NUMBER,
    x_trx_id                            IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_trx_number                        IN     VARCHAR2,
    x_packet_id                         IN     NUMBER,
    x_trx_status                        IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_transaction_name          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_funds_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2,
    x_attribute25                       IN     VARCHAR2,
    x_attribute26                       IN     VARCHAR2,
    x_attribute27                       IN     VARCHAR2,
    x_attribute28                       IN     VARCHAR2,
    x_attribute29                       IN     VARCHAR2,
    x_attribute30                       IN     VARCHAR2,
    x_parent_trx_id                     IN     NUMBER,
    x_parent_trx_number                 IN     VARCHAR2,
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
      FROM     igi_dos_trx_headers
      WHERE    trx_id                            = x_trx_id;

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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.insert_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    SELECT    igi_dos_trx_headers_s.NEXTVAL
    INTO      x_trx_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sob_id                            => x_sob_id,
      x_trx_id                            => x_trx_id,
      x_dossier_name                      => x_dossier_name,
      x_trx_number                        => x_trx_number,
      x_packet_id                         => x_packet_id,
      x_trx_status                        => x_trx_status,
      x_dossier_id                        => x_dossier_id,
      x_dossier_transaction_name          => x_dossier_transaction_name,
      x_description                       => x_description,
      x_funds_status                      => x_funds_status,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_attribute21                       => x_attribute21,
      x_attribute22                       => x_attribute22,
      x_attribute23                       => x_attribute23,
      x_attribute24                       => x_attribute24,
      x_attribute25                       => x_attribute25,
      x_attribute26                       => x_attribute26,
      x_attribute27                       => x_attribute27,
      x_attribute28                       => x_attribute28,
      x_attribute29                       => x_attribute29,
      x_attribute30                       => x_attribute30,
      x_parent_trx_id                     => x_parent_trx_id,
      x_parent_trx_number                 => x_parent_trx_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_dos_trx_headers (
      sob_id,
      trx_id,
      dossier_name,
      trx_number,
      packet_id,
      trx_status,
      dossier_id,
      dossier_transaction_name,
      description,
      funds_status,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      parent_trx_id,
      parent_trx_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sob_id,
      new_references.trx_id,
      new_references.dossier_name,
      new_references.trx_number,
      new_references.packet_id,
      new_references.trx_status,
      new_references.dossier_id,
      new_references.dossier_transaction_name,
      new_references.description,
      new_references.funds_status,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      new_references.attribute21,
      new_references.attribute22,
      new_references.attribute23,
      new_references.attribute24,
      new_references.attribute25,
      new_references.attribute26,
      new_references.attribute27,
      new_references.attribute28,
      new_references.attribute29,
      new_references.attribute30,
      new_references.parent_trx_id,
      new_references.parent_trx_number,
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
    x_sob_id							IN	   NUMBER,
    x_trx_id							IN 	   NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_trx_number                        IN     VARCHAR2,
    x_packet_id                         IN     NUMBER,
    x_trx_status                        IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_transaction_name          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_funds_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2,
    x_attribute25                       IN     VARCHAR2,
    x_attribute26                       IN     VARCHAR2,
    x_attribute27                       IN     VARCHAR2,
    x_attribute28                       IN     VARCHAR2,
    x_attribute29                       IN     VARCHAR2,
    x_attribute30                       IN     VARCHAR2,
    x_parent_trx_id                     IN     NUMBER,
    x_parent_trx_number                 IN     VARCHAR2
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
        dossier_name,
        trx_number,
        packet_id,
        trx_status,
        dossier_id,
        dossier_transaction_name,
        description,
        funds_status,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30,
        parent_trx_id,
        parent_trx_number
      FROM  igi_dos_trx_headers
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.sob_id = x_sob_id) OR ((tlinfo.sob_id IS NULL) AND (X_sob_id IS NULL)))
        AND (tlinfo.dossier_name = x_dossier_name)
        AND ((tlinfo.trx_number = x_trx_number) OR ((tlinfo.trx_number IS NULL) AND (X_trx_number IS NULL)))
        AND ((tlinfo.packet_id = x_packet_id) OR ((tlinfo.packet_id IS NULL) AND (X_packet_id IS NULL)))
        AND ((tlinfo.trx_status = x_trx_status) OR ((tlinfo.trx_status IS NULL) AND (X_trx_status IS NULL)))
        AND ((tlinfo.dossier_id = x_dossier_id) OR ((tlinfo.dossier_id IS NULL) AND (X_dossier_id IS NULL)))
        AND ((tlinfo.dossier_transaction_name = x_dossier_transaction_name) OR ((tlinfo.dossier_transaction_name IS NULL) AND (X_dossier_transaction_name IS NULL)))
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND ((tlinfo.funds_status = x_funds_status) OR ((tlinfo.funds_status IS NULL) AND (X_funds_status IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.attribute21 = x_attribute21) OR ((tlinfo.attribute21 IS NULL) AND (X_attribute21 IS NULL)))
        AND ((tlinfo.attribute22 = x_attribute22) OR ((tlinfo.attribute22 IS NULL) AND (X_attribute22 IS NULL)))
        AND ((tlinfo.attribute23 = x_attribute23) OR ((tlinfo.attribute23 IS NULL) AND (X_attribute23 IS NULL)))
        AND ((tlinfo.attribute24 = x_attribute24) OR ((tlinfo.attribute24 IS NULL) AND (X_attribute24 IS NULL)))
        AND ((tlinfo.attribute25 = x_attribute25) OR ((tlinfo.attribute25 IS NULL) AND (X_attribute25 IS NULL)))
        AND ((tlinfo.attribute26 = x_attribute26) OR ((tlinfo.attribute26 IS NULL) AND (X_attribute26 IS NULL)))
        AND ((tlinfo.attribute27 = x_attribute27) OR ((tlinfo.attribute27 IS NULL) AND (X_attribute27 IS NULL)))
        AND ((tlinfo.attribute28 = x_attribute28) OR ((tlinfo.attribute28 IS NULL) AND (X_attribute28 IS NULL)))
        AND ((tlinfo.attribute29 = x_attribute29) OR ((tlinfo.attribute29 IS NULL) AND (X_attribute29 IS NULL)))
        AND ((tlinfo.attribute30 = x_attribute30) OR ((tlinfo.attribute30 IS NULL) AND (X_attribute30 IS NULL)))
        AND ((tlinfo.parent_trx_id = x_parent_trx_id) OR ((tlinfo.parent_trx_id IS NULL) AND (X_parent_trx_id IS NULL)))
        AND ((tlinfo.parent_trx_number = x_parent_trx_number) OR ((tlinfo.parent_trx_number IS NULL) AND (X_parent_trx_number IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sob_id							IN 	   NUMBER,
    x_trx_id						    IN     NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_trx_number                        IN     VARCHAR2,
    x_packet_id                         IN     NUMBER,
    x_trx_status                        IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_transaction_name          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_funds_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2,
    x_attribute25                       IN     VARCHAR2,
    x_attribute26                       IN     VARCHAR2,
    x_attribute27                       IN     VARCHAR2,
    x_attribute28                       IN     VARCHAR2,
    x_attribute29                       IN     VARCHAR2,
    x_attribute30                       IN     VARCHAR2,
    x_parent_trx_id                     IN     NUMBER,
    x_parent_trx_number                 IN     VARCHAR2,
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_trx_headers_pkg.update_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sob_id                            => x_sob_id,
      x_trx_id                            => x_trx_id,
      x_dossier_name                      => x_dossier_name,
      x_trx_number                        => x_trx_number,
      x_packet_id                         => x_packet_id,
      x_trx_status                        => x_trx_status,
      x_dossier_id                        => x_dossier_id,
      x_dossier_transaction_name          => x_dossier_transaction_name,
      x_description                       => x_description,
      x_funds_status                      => x_funds_status,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_attribute21                       => x_attribute21,
      x_attribute22                       => x_attribute22,
      x_attribute23                       => x_attribute23,
      x_attribute24                       => x_attribute24,
      x_attribute25                       => x_attribute25,
      x_attribute26                       => x_attribute26,
      x_attribute27                       => x_attribute27,
      x_attribute28                       => x_attribute28,
      x_attribute29                       => x_attribute29,
      x_attribute30                       => x_attribute30,
      x_parent_trx_id                     => x_parent_trx_id,
      x_parent_trx_number                 => x_parent_trx_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_dos_trx_headers
      SET
        sob_id                            = new_references.sob_id,
        dossier_name                      = new_references.dossier_name,
        trx_number                        = new_references.trx_number,
        packet_id                         = new_references.packet_id,
        trx_status                        = new_references.trx_status,
        dossier_id                        = new_references.dossier_id,
        dossier_transaction_name          = new_references.dossier_transaction_name,
        description                       = new_references.description,
        funds_status                      = new_references.funds_status,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        attribute21                       = new_references.attribute21,
        attribute22                       = new_references.attribute22,
        attribute23                       = new_references.attribute23,
        attribute24                       = new_references.attribute24,
        attribute25                       = new_references.attribute25,
        attribute26                       = new_references.attribute26,
        attribute27                       = new_references.attribute27,
        attribute28                       = new_references.attribute28,
        attribute29                       = new_references.attribute29,
        attribute30                       = new_references.attribute30,
        parent_trx_id                     = new_references.parent_trx_id,
        parent_trx_number                 = new_references.parent_trx_number,
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
    x_sob_id							IN NUMBER,
    x_trx_id                            IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_trx_number                        IN     VARCHAR2,
    x_packet_id                         IN     NUMBER,
    x_trx_status                        IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_transaction_name          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_funds_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2,
    x_attribute25                       IN     VARCHAR2,
    x_attribute26                       IN     VARCHAR2,
    x_attribute27                       IN     VARCHAR2,
    x_attribute28                       IN     VARCHAR2,
    x_attribute29                       IN     VARCHAR2,
    x_attribute30                       IN     VARCHAR2,
    x_parent_trx_id                     IN     NUMBER,
    x_parent_trx_number                 IN     VARCHAR2,
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
      FROM     igi_dos_trx_headers
      WHERE    trx_id                            = x_trx_id;

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
        x_dossier_name,
        x_trx_number,
        x_packet_id,
        x_trx_status,
        x_dossier_id,
        x_dossier_transaction_name,
        x_description,
        x_funds_status,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_attribute21,
        x_attribute22,
        x_attribute23,
        x_attribute24,
        x_attribute25,
        x_attribute26,
        x_attribute27,
        x_attribute28,
        x_attribute29,
        x_attribute30,
        x_parent_trx_id,
        x_parent_trx_number,
        l_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sob_id,
      x_trx_id,
      x_dossier_name,
      x_trx_number,
      x_packet_id,
      x_trx_status,
      x_dossier_id,
      x_dossier_transaction_name,
      x_description,
      x_funds_status,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24,
      x_attribute25,
      x_attribute26,
      x_attribute27,
      x_attribute28,
      x_attribute29,
      x_attribute30,
      x_parent_trx_id,
      x_parent_trx_number,
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

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid,
    x_sob_id=>NULL,
    x_trx_id=>NULL,
    x_dossier_name=>NULL,
    x_trx_number  =>NULL,
    x_packet_id=>NULL,
    x_trx_status  =>NULL,
    x_dossier_id=>NULL,
    x_dossier_transaction_name=>NULL,
    x_description =>NULL,
    x_funds_status=>NULL,
    x_attribute_category=>NULL,
    x_attribute1  =>NULL,
    x_attribute2  =>NULL,
    x_attribute3  =>NULL,
    x_attribute4  =>NULL,
    x_attribute5  =>NULL,
    x_attribute6  =>NULL,
    x_attribute7  =>NULL,
    x_attribute8  =>NULL,
    x_attribute9  =>NULL,
    x_attribute10 =>NULL,
    x_attribute11 =>NULL,
    x_attribute12 =>NULL,
    x_attribute13 =>NULL,
    x_attribute14 =>NULL,
    x_attribute15 =>NULL,
    x_attribute16 =>NULL,
    x_attribute17 =>NULL,
    x_attribute18 =>NULL,
    x_attribute19 =>NULL,
    x_attribute20 =>NULL,
    x_attribute21 =>NULL,
    x_attribute22 =>NULL,
    x_attribute23 =>NULL,
    x_attribute24 =>NULL,
    x_attribute25 =>NULL,
    x_attribute26 =>NULL,
    x_attribute27 =>NULL,
    x_attribute28 =>NULL,
    x_attribute29 =>NULL,
    x_attribute30 =>NULL,
    x_parent_trx_id=>NULL,
    x_parent_trx_number=>NULL,
    x_creation_date=>NULL,
    x_created_by=>NULL,
    x_last_update_date=>NULL,
    x_last_updated_by=>NULL,
    x_last_update_login=>NULL

    );

    DELETE FROM igi_dos_trx_headers
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;
BEGIN
l_debug_level    := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level    := FND_LOG.LEVEL_STATEMENT ;
l_proc_level     := FND_LOG.LEVEL_PROCEDURE ;
l_event_level    := FND_LOG.LEVEL_EVENT ;
l_excep_level    := FND_LOG.LEVEL_EXCEPTION ;
l_error_level    := FND_LOG.LEVEL_ERROR ;
l_unexp_level    := FND_LOG.LEVEL_UNEXPECTED ;

END igi_dos_trx_headers_pkg;

/
