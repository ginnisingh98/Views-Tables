--------------------------------------------------------
--  DDL for Package Body IGI_DOS_DESTINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_DESTINATIONS_PKG" AS
/* $Header: igidosmb.pls 120.5.12000000.2 2007/06/14 05:52:49 pshivara ship $ */

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

  l_rowid VARCHAR2(25);
  old_references igi_dos_destinations%ROWTYPE;
  new_references igi_dos_destinations%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_line_num                          IN     NUMBER      ,
    x_dossier_id                        IN     NUMBER      ,
    x_source_id                         IN     NUMBER      ,
    x_destination_id                    IN     NUMBER      ,
    x_sob_id                            IN     NUMBER      ,
    x_coa_id                            IN     NUMBER      ,
    x_budget                            IN     VARCHAR2    ,
    x_budget_entity_id                  IN     NUMBER      ,
    x_budget_entity_name                IN     VARCHAR2    ,
    x_segment1_low                      IN     VARCHAR2    ,
    x_segment1_high                     IN     VARCHAR2    ,
    x_segment2_low                      IN     VARCHAR2    ,
    x_segment2_high                     IN     VARCHAR2    ,
    x_segment3_low                      IN     VARCHAR2    ,
    x_segment3_high                     IN     VARCHAR2    ,
    x_segment4_low                      IN     VARCHAR2    ,
    x_segment4_high                     IN     VARCHAR2    ,
    x_segment5_low                      IN     VARCHAR2    ,
    x_segment5_high                     IN     VARCHAR2    ,
    x_segment6_low                      IN     VARCHAR2    ,
    x_segment6_high                     IN     VARCHAR2    ,
    x_segment7_high                     IN     VARCHAR2    ,
    x_segment7_low                      IN     VARCHAR2    ,
    x_segment8_high                     IN     VARCHAR2    ,
    x_segment8_low                      IN     VARCHAR2    ,
    x_segment9_high                     IN     VARCHAR2    ,
    x_segment9_low                      IN     VARCHAR2    ,
    x_segment10_high                    IN     VARCHAR2    ,
    x_segment10_low                     IN     VARCHAR2    ,
    x_segment11_high                    IN     VARCHAR2    ,
    x_segment11_low                     IN     VARCHAR2    ,
    x_segment12_high                    IN     VARCHAR2    ,
    x_segment12_low                     IN     VARCHAR2    ,
    x_segment13_high                    IN     VARCHAR2    ,
    x_segment13_low                     IN     VARCHAR2    ,
    x_segment14_high                    IN     VARCHAR2    ,
    x_segment14_low                     IN     VARCHAR2    ,
    x_segment15_high                    IN     VARCHAR2    ,
    x_segment15_low                     IN     VARCHAR2    ,
    x_segment16_high                    IN     VARCHAR2    ,
    x_segment16_low                     IN     VARCHAR2    ,
    x_segment17_high                    IN     VARCHAR2    ,
    x_segment17_low                     IN     VARCHAR2    ,
    x_segment18_high                    IN     VARCHAR2    ,
    x_segment18_low                     IN     VARCHAR2    ,
    x_segment19_high                    IN     VARCHAR2    ,
    x_segment19_low                     IN     VARCHAR2    ,
    x_segment20_high                    IN     VARCHAR2    ,
    x_segment20_low                     IN     VARCHAR2    ,
    x_segment21_high                    IN     VARCHAR2    ,
    x_segment21_low                     IN     VARCHAR2    ,
    x_segment22_high                    IN     VARCHAR2    ,
    x_segment22_low                     IN     VARCHAR2    ,
    x_segment23_high                    IN     VARCHAR2    ,
    x_segment23_low                     IN     VARCHAR2    ,
    x_segment24_high                    IN     VARCHAR2    ,
    x_segment24_low                     IN     VARCHAR2    ,
    x_segment25_low                     IN     VARCHAR2    ,
    x_segment25_high                    IN     VARCHAR2    ,
    x_segment26_low                     IN     VARCHAR2    ,
    x_segment26_high                    IN     VARCHAR2    ,
    x_segment27_low                     IN     VARCHAR2    ,
    x_segment27_high                    IN     VARCHAR2    ,
    x_segment28_low                     IN     VARCHAR2    ,
    x_segment28_high                    IN     VARCHAR2    ,
    x_segment29_low                     IN     VARCHAR2    ,
    x_segment29_high                    IN     VARCHAR2    ,
    x_segment30_low                     IN     VARCHAR2    ,
    x_segment30_high                    IN     VARCHAR2    ,
    x_segments_low_ccid                 IN     NUMBER      ,
    x_segments_high_ccid                IN     NUMBER      ,
    x_segments_low_ccid_desc            IN     VARCHAR2    ,
    x_segments_high_ccid_desc           IN     VARCHAR2    ,
    x_budget_version_id                 IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_dos_destinations
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.set_column_values.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.line_num                          := x_line_num;
    new_references.dossier_id                        := x_dossier_id;
    new_references.source_id                         := x_source_id;
    new_references.destination_id                    := x_destination_id;
    new_references.sob_id                            := x_sob_id;
    new_references.coa_id                            := x_coa_id;
    new_references.budget                            := x_budget;
    new_references.budget_entity_id                  := x_budget_entity_id;
    new_references.budget_entity_name                := x_budget_entity_name;
    new_references.segment1_low                      := x_segment1_low;
    new_references.segment1_high                     := x_segment1_high;
    new_references.segment2_low                      := x_segment2_low;
    new_references.segment2_high                     := x_segment2_high;
    new_references.segment3_low                      := x_segment3_low;
    new_references.segment3_high                     := x_segment3_high;
    new_references.segment4_low                      := x_segment4_low;
    new_references.segment4_high                     := x_segment4_high;
    new_references.segment5_low                      := x_segment5_low;
    new_references.segment5_high                     := x_segment5_high;
    new_references.segment6_low                      := x_segment6_low;
    new_references.segment6_high                     := x_segment6_high;
    new_references.segment7_high                     := x_segment7_high;
    new_references.segment7_low                      := x_segment7_low;
    new_references.segment8_high                     := x_segment8_high;
    new_references.segment8_low                      := x_segment8_low;
    new_references.segment9_high                     := x_segment9_high;
    new_references.segment9_low                      := x_segment9_low;
    new_references.segment10_high                    := x_segment10_high;
    new_references.segment10_low                     := x_segment10_low;
    new_references.segment11_high                    := x_segment11_high;
    new_references.segment11_low                     := x_segment11_low;
    new_references.segment12_high                    := x_segment12_high;
    new_references.segment12_low                     := x_segment12_low;
    new_references.segment13_high                    := x_segment13_high;
    new_references.segment13_low                     := x_segment13_low;
    new_references.segment14_high                    := x_segment14_high;
    new_references.segment14_low                     := x_segment14_low;
    new_references.segment15_high                    := x_segment15_high;
    new_references.segment15_low                     := x_segment15_low;
    new_references.segment16_high                    := x_segment16_high;
    new_references.segment16_low                     := x_segment16_low;
    new_references.segment17_high                    := x_segment17_high;
    new_references.segment17_low                     := x_segment17_low;
    new_references.segment18_high                    := x_segment18_high;
    new_references.segment18_low                     := x_segment18_low;
    new_references.segment19_high                    := x_segment19_high;
    new_references.segment19_low                     := x_segment19_low;
    new_references.segment20_high                    := x_segment20_high;
    new_references.segment20_low                     := x_segment20_low;
    new_references.segment21_high                    := x_segment21_high;
    new_references.segment21_low                     := x_segment21_low;
    new_references.segment22_high                    := x_segment22_high;
    new_references.segment22_low                     := x_segment22_low;
    new_references.segment23_high                    := x_segment23_high;
    new_references.segment23_low                     := x_segment23_low;
    new_references.segment24_high                    := x_segment24_high;
    new_references.segment24_low                     := x_segment24_low;
    new_references.segment25_low                     := x_segment25_low;
    new_references.segment25_high                    := x_segment25_high;
    new_references.segment26_low                     := x_segment26_low;
    new_references.segment26_high                    := x_segment26_high;
    new_references.segment27_low                     := x_segment27_low;
    new_references.segment27_high                    := x_segment27_high;
    new_references.segment28_low                     := x_segment28_low;
    new_references.segment28_high                    := x_segment28_high;
    new_references.segment29_low                     := x_segment29_low;
    new_references.segment29_high                    := x_segment29_high;
    new_references.segment30_low                     := x_segment30_low;
    new_references.segment30_high                    := x_segment30_high;
    new_references.segments_low_ccid                 := x_segments_low_ccid;
    new_references.segments_high_ccid                := x_segments_high_ccid;
    new_references.segments_low_ccid_desc            := x_segments_low_ccid_desc;
    new_references.segments_high_ccid_desc           := x_segments_high_ccid_desc;
    new_references.budget_version_id                 := x_budget_version_id;

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
  ||  Created On : 18-APR-2002
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.check_parent_existance.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    IF (((old_references.source_id = new_references.source_id)) OR
        ((new_references.source_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_sources_pkg.get_pk_for_validation (
                new_references.source_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.check_parent_existance.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    igi_dos_destination_usages_pkg.get_fk_igi_dos_destinations (
      old_references.destination_id
    );


  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_destination_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_destinations
      WHERE    destination_id = x_destination_id
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
  ||  Created On : 18-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_destinations
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.get_fk_igi_dos_doc_types.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_doc_types;


  PROCEDURE get_fk_igi_dos_sources (
    x_source_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_destinations
      WHERE   ((source_id = x_source_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.get_fk_igi_dos_sources.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_sources;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_line_num                          IN     NUMBER      ,
    x_dossier_id                        IN     NUMBER      ,
    x_source_id                         IN     NUMBER      ,
    x_destination_id                    IN     NUMBER      ,
    x_sob_id                            IN     NUMBER      ,
    x_coa_id                            IN     NUMBER      ,
    x_budget                            IN     VARCHAR2    ,
    x_budget_entity_id                  IN     NUMBER      ,
    x_budget_entity_name                IN     VARCHAR2    ,
    x_segment1_low                      IN     VARCHAR2    ,
    x_segment1_high                     IN     VARCHAR2    ,
    x_segment2_low                      IN     VARCHAR2    ,
    x_segment2_high                     IN     VARCHAR2    ,
    x_segment3_low                      IN     VARCHAR2    ,
    x_segment3_high                     IN     VARCHAR2    ,
    x_segment4_low                      IN     VARCHAR2    ,
    x_segment4_high                     IN     VARCHAR2    ,
    x_segment5_low                      IN     VARCHAR2    ,
    x_segment5_high                     IN     VARCHAR2    ,
    x_segment6_low                      IN     VARCHAR2    ,
    x_segment6_high                     IN     VARCHAR2    ,
    x_segment7_high                     IN     VARCHAR2    ,
    x_segment7_low                      IN     VARCHAR2    ,
    x_segment8_high                     IN     VARCHAR2    ,
    x_segment8_low                      IN     VARCHAR2    ,
    x_segment9_high                     IN     VARCHAR2    ,
    x_segment9_low                      IN     VARCHAR2    ,
    x_segment10_high                    IN     VARCHAR2    ,
    x_segment10_low                     IN     VARCHAR2    ,
    x_segment11_high                    IN     VARCHAR2    ,
    x_segment11_low                     IN     VARCHAR2    ,
    x_segment12_high                    IN     VARCHAR2    ,
    x_segment12_low                     IN     VARCHAR2    ,
    x_segment13_high                    IN     VARCHAR2    ,
    x_segment13_low                     IN     VARCHAR2    ,
    x_segment14_high                    IN     VARCHAR2    ,
    x_segment14_low                     IN     VARCHAR2    ,
    x_segment15_high                    IN     VARCHAR2    ,
    x_segment15_low                     IN     VARCHAR2    ,
    x_segment16_high                    IN     VARCHAR2    ,
    x_segment16_low                     IN     VARCHAR2    ,
    x_segment17_high                    IN     VARCHAR2    ,
    x_segment17_low                     IN     VARCHAR2    ,
    x_segment18_high                    IN     VARCHAR2    ,
    x_segment18_low                     IN     VARCHAR2    ,
    x_segment19_high                    IN     VARCHAR2    ,
    x_segment19_low                     IN     VARCHAR2    ,
    x_segment20_high                    IN     VARCHAR2    ,
    x_segment20_low                     IN     VARCHAR2    ,
    x_segment21_high                    IN     VARCHAR2    ,
    x_segment21_low                     IN     VARCHAR2    ,
    x_segment22_high                    IN     VARCHAR2    ,
    x_segment22_low                     IN     VARCHAR2    ,
    x_segment23_high                    IN     VARCHAR2    ,
    x_segment23_low                     IN     VARCHAR2    ,
    x_segment24_high                    IN     VARCHAR2    ,
    x_segment24_low                     IN     VARCHAR2    ,
    x_segment25_low                     IN     VARCHAR2    ,
    x_segment25_high                    IN     VARCHAR2    ,
    x_segment26_low                     IN     VARCHAR2    ,
    x_segment26_high                    IN     VARCHAR2    ,
    x_segment27_low                     IN     VARCHAR2    ,
    x_segment27_high                    IN     VARCHAR2    ,
    x_segment28_low                     IN     VARCHAR2    ,
    x_segment28_high                    IN     VARCHAR2    ,
    x_segment29_low                     IN     VARCHAR2    ,
    x_segment29_high                    IN     VARCHAR2    ,
    x_segment30_low                     IN     VARCHAR2    ,
    x_segment30_high                    IN     VARCHAR2    ,
    x_segments_low_ccid                 IN     NUMBER      ,
    x_segments_high_ccid                IN     NUMBER      ,
    x_segments_low_ccid_desc            IN     VARCHAR2    ,
    x_segments_high_ccid_desc           IN     VARCHAR2    ,
    x_budget_version_id                 IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
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
      x_line_num,
      x_dossier_id,
      x_source_id,
      x_destination_id,
      x_sob_id,
      x_coa_id,
      x_budget,
      x_budget_entity_id,
      x_budget_entity_name,
      x_segment1_low,
      x_segment1_high,
      x_segment2_low,
      x_segment2_high,
      x_segment3_low,
      x_segment3_high,
      x_segment4_low,
      x_segment4_high,
      x_segment5_low,
      x_segment5_high,
      x_segment6_low,
      x_segment6_high,
      x_segment7_high,
      x_segment7_low,
      x_segment8_high,
      x_segment8_low,
      x_segment9_high,
      x_segment9_low,
      x_segment10_high,
      x_segment10_low,
      x_segment11_high,
      x_segment11_low,
      x_segment12_high,
      x_segment12_low,
      x_segment13_high,
      x_segment13_low,
      x_segment14_high,
      x_segment14_low,
      x_segment15_high,
      x_segment15_low,
      x_segment16_high,
      x_segment16_low,
      x_segment17_high,
      x_segment17_low,
      x_segment18_high,
      x_segment18_low,
      x_segment19_high,
      x_segment19_low,
      x_segment20_high,
      x_segment20_low,
      x_segment21_high,
      x_segment21_low,
      x_segment22_high,
      x_segment22_low,
      x_segment23_high,
      x_segment23_low,
      x_segment24_high,
      x_segment24_low,
      x_segment25_low,
      x_segment25_high,
      x_segment26_low,
      x_segment26_high,
      x_segment27_low,
      x_segment27_high,
      x_segment28_low,
      x_segment28_high,
      x_segment29_low,
      x_segment29_high,
      x_segment30_low,
      x_segment30_high,
      x_segments_low_ccid,
      x_segments_high_ccid,
      x_segments_low_ccid_desc,
      x_segments_high_ccid_desc,
      x_budget_version_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.destination_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.beforedml.Msg1',FALSE);
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
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.destination_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.beforedml.Msg2',FALSE);
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
    x_line_num                          IN     NUMBER,
    x_dossier_id                        IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN OUT NOCOPY NUMBER,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_budget                            IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_entity_name                IN     VARCHAR2,
    x_segment1_low                      IN     VARCHAR2,
    x_segment1_high                     IN     VARCHAR2,
    x_segment2_low                      IN     VARCHAR2,
    x_segment2_high                     IN     VARCHAR2,
    x_segment3_low                      IN     VARCHAR2,
    x_segment3_high                     IN     VARCHAR2,
    x_segment4_low                      IN     VARCHAR2,
    x_segment4_high                     IN     VARCHAR2,
    x_segment5_low                      IN     VARCHAR2,
    x_segment5_high                     IN     VARCHAR2,
    x_segment6_low                      IN     VARCHAR2,
    x_segment6_high                     IN     VARCHAR2,
    x_segment7_high                     IN     VARCHAR2,
    x_segment7_low                      IN     VARCHAR2,
    x_segment8_high                     IN     VARCHAR2,
    x_segment8_low                      IN     VARCHAR2,
    x_segment9_high                     IN     VARCHAR2,
    x_segment9_low                      IN     VARCHAR2,
    x_segment10_high                    IN     VARCHAR2,
    x_segment10_low                     IN     VARCHAR2,
    x_segment11_high                    IN     VARCHAR2,
    x_segment11_low                     IN     VARCHAR2,
    x_segment12_high                    IN     VARCHAR2,
    x_segment12_low                     IN     VARCHAR2,
    x_segment13_high                    IN     VARCHAR2,
    x_segment13_low                     IN     VARCHAR2,
    x_segment14_high                    IN     VARCHAR2,
    x_segment14_low                     IN     VARCHAR2,
    x_segment15_high                    IN     VARCHAR2,
    x_segment15_low                     IN     VARCHAR2,
    x_segment16_high                    IN     VARCHAR2,
    x_segment16_low                     IN     VARCHAR2,
    x_segment17_high                    IN     VARCHAR2,
    x_segment17_low                     IN     VARCHAR2,
    x_segment18_high                    IN     VARCHAR2,
    x_segment18_low                     IN     VARCHAR2,
    x_segment19_high                    IN     VARCHAR2,
    x_segment19_low                     IN     VARCHAR2,
    x_segment20_high                    IN     VARCHAR2,
    x_segment20_low                     IN     VARCHAR2,
    x_segment21_high                    IN     VARCHAR2,
    x_segment21_low                     IN     VARCHAR2,
    x_segment22_high                    IN     VARCHAR2,
    x_segment22_low                     IN     VARCHAR2,
    x_segment23_high                    IN     VARCHAR2,
    x_segment23_low                     IN     VARCHAR2,
    x_segment24_high                    IN     VARCHAR2,
    x_segment24_low                     IN     VARCHAR2,
    x_segment25_low                     IN     VARCHAR2,
    x_segment25_high                    IN     VARCHAR2,
    x_segment26_low                     IN     VARCHAR2,
    x_segment26_high                    IN     VARCHAR2,
    x_segment27_low                     IN     VARCHAR2,
    x_segment27_high                    IN     VARCHAR2,
    x_segment28_low                     IN     VARCHAR2,
    x_segment28_high                    IN     VARCHAR2,
    x_segment29_low                     IN     VARCHAR2,
    x_segment29_high                    IN     VARCHAR2,
    x_segment30_low                     IN     VARCHAR2,
    x_segment30_high                    IN     VARCHAR2,
    x_segments_low_ccid                 IN     NUMBER,
    x_segments_high_ccid                IN     NUMBER,
    x_segments_low_ccid_desc            IN     VARCHAR2,
    x_segments_high_ccid_desc           IN     VARCHAR2,
    x_budget_version_id                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_dos_destinations
      WHERE    destination_id                    = x_destination_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.insert_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    SELECT    igi_dos_destinations_s.NEXTVAL
    INTO      x_destination_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_line_num                          => x_line_num,
      x_dossier_id                        => x_dossier_id,
      x_source_id                         => x_source_id,
      x_destination_id                    => x_destination_id,
      x_sob_id                            => x_sob_id,
      x_coa_id                            => x_coa_id,
      x_budget                            => x_budget,
      x_budget_entity_id                  => x_budget_entity_id,
      x_budget_entity_name                => x_budget_entity_name,
      x_segment1_low                      => x_segment1_low,
      x_segment1_high                     => x_segment1_high,
      x_segment2_low                      => x_segment2_low,
      x_segment2_high                     => x_segment2_high,
      x_segment3_low                      => x_segment3_low,
      x_segment3_high                     => x_segment3_high,
      x_segment4_low                      => x_segment4_low,
      x_segment4_high                     => x_segment4_high,
      x_segment5_low                      => x_segment5_low,
      x_segment5_high                     => x_segment5_high,
      x_segment6_low                      => x_segment6_low,
      x_segment6_high                     => x_segment6_high,
      x_segment7_high                     => x_segment7_high,
      x_segment7_low                      => x_segment7_low,
      x_segment8_high                     => x_segment8_high,
      x_segment8_low                      => x_segment8_low,
      x_segment9_high                     => x_segment9_high,
      x_segment9_low                      => x_segment9_low,
      x_segment10_high                    => x_segment10_high,
      x_segment10_low                     => x_segment10_low,
      x_segment11_high                    => x_segment11_high,
      x_segment11_low                     => x_segment11_low,
      x_segment12_high                    => x_segment12_high,
      x_segment12_low                     => x_segment12_low,
      x_segment13_high                    => x_segment13_high,
      x_segment13_low                     => x_segment13_low,
      x_segment14_high                    => x_segment14_high,
      x_segment14_low                     => x_segment14_low,
      x_segment15_high                    => x_segment15_high,
      x_segment15_low                     => x_segment15_low,
      x_segment16_high                    => x_segment16_high,
      x_segment16_low                     => x_segment16_low,
      x_segment17_high                    => x_segment17_high,
      x_segment17_low                     => x_segment17_low,
      x_segment18_high                    => x_segment18_high,
      x_segment18_low                     => x_segment18_low,
      x_segment19_high                    => x_segment19_high,
      x_segment19_low                     => x_segment19_low,
      x_segment20_high                    => x_segment20_high,
      x_segment20_low                     => x_segment20_low,
      x_segment21_high                    => x_segment21_high,
      x_segment21_low                     => x_segment21_low,
      x_segment22_high                    => x_segment22_high,
      x_segment22_low                     => x_segment22_low,
      x_segment23_high                    => x_segment23_high,
      x_segment23_low                     => x_segment23_low,
      x_segment24_high                    => x_segment24_high,
      x_segment24_low                     => x_segment24_low,
      x_segment25_low                     => x_segment25_low,
      x_segment25_high                    => x_segment25_high,
      x_segment26_low                     => x_segment26_low,
      x_segment26_high                    => x_segment26_high,
      x_segment27_low                     => x_segment27_low,
      x_segment27_high                    => x_segment27_high,
      x_segment28_low                     => x_segment28_low,
      x_segment28_high                    => x_segment28_high,
      x_segment29_low                     => x_segment29_low,
      x_segment29_high                    => x_segment29_high,
      x_segment30_low                     => x_segment30_low,
      x_segment30_high                    => x_segment30_high,
      x_segments_low_ccid                 => x_segments_low_ccid,
      x_segments_high_ccid                => x_segments_high_ccid,
      x_segments_low_ccid_desc            => x_segments_low_ccid_desc,
      x_segments_high_ccid_desc           => x_segments_high_ccid_desc,
      x_budget_version_id                 => x_budget_version_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_dos_destinations (
      line_num,
      dossier_id,
      source_id,
      destination_id,
      sob_id,
      coa_id,
      budget,
      budget_entity_id,
      budget_entity_name,
      segment1_low,
      segment1_high,
      segment2_low,
      segment2_high,
      segment3_low,
      segment3_high,
      segment4_low,
      segment4_high,
      segment5_low,
      segment5_high,
      segment6_low,
      segment6_high,
      segment7_high,
      segment7_low,
      segment8_high,
      segment8_low,
      segment9_high,
      segment9_low,
      segment10_high,
      segment10_low,
      segment11_high,
      segment11_low,
      segment12_high,
      segment12_low,
      segment13_high,
      segment13_low,
      segment14_high,
      segment14_low,
      segment15_high,
      segment15_low,
      segment16_high,
      segment16_low,
      segment17_high,
      segment17_low,
      segment18_high,
      segment18_low,
      segment19_high,
      segment19_low,
      segment20_high,
      segment20_low,
      segment21_high,
      segment21_low,
      segment22_high,
      segment22_low,
      segment23_high,
      segment23_low,
      segment24_high,
      segment24_low,
      segment25_low,
      segment25_high,
      segment26_low,
      segment26_high,
      segment27_low,
      segment27_high,
      segment28_low,
      segment28_high,
      segment29_low,
      segment29_high,
      segment30_low,
      segment30_high,
      segments_low_ccid,
      segments_high_ccid,
      segments_low_ccid_desc,
      segments_high_ccid_desc,
      budget_version_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.line_num,
      new_references.dossier_id,
      new_references.source_id,
      new_references.destination_id,
      new_references.sob_id,
      new_references.coa_id,
      new_references.budget,
      new_references.budget_entity_id,
      new_references.budget_entity_name,
      new_references.segment1_low,
      new_references.segment1_high,
      new_references.segment2_low,
      new_references.segment2_high,
      new_references.segment3_low,
      new_references.segment3_high,
      new_references.segment4_low,
      new_references.segment4_high,
      new_references.segment5_low,
      new_references.segment5_high,
      new_references.segment6_low,
      new_references.segment6_high,
      new_references.segment7_high,
      new_references.segment7_low,
      new_references.segment8_high,
      new_references.segment8_low,
      new_references.segment9_high,
      new_references.segment9_low,
      new_references.segment10_high,
      new_references.segment10_low,
      new_references.segment11_high,
      new_references.segment11_low,
      new_references.segment12_high,
      new_references.segment12_low,
      new_references.segment13_high,
      new_references.segment13_low,
      new_references.segment14_high,
      new_references.segment14_low,
      new_references.segment15_high,
      new_references.segment15_low,
      new_references.segment16_high,
      new_references.segment16_low,
      new_references.segment17_high,
      new_references.segment17_low,
      new_references.segment18_high,
      new_references.segment18_low,
      new_references.segment19_high,
      new_references.segment19_low,
      new_references.segment20_high,
      new_references.segment20_low,
      new_references.segment21_high,
      new_references.segment21_low,
      new_references.segment22_high,
      new_references.segment22_low,
      new_references.segment23_high,
      new_references.segment23_low,
      new_references.segment24_high,
      new_references.segment24_low,
      new_references.segment25_low,
      new_references.segment25_high,
      new_references.segment26_low,
      new_references.segment26_high,
      new_references.segment27_low,
      new_references.segment27_high,
      new_references.segment28_low,
      new_references.segment28_high,
      new_references.segment29_low,
      new_references.segment29_high,
      new_references.segment30_low,
      new_references.segment30_high,
      new_references.segments_low_ccid,
      new_references.segments_high_ccid,
      new_references.segments_low_ccid_desc,
      new_references.segments_high_ccid_desc,
      new_references.budget_version_id,
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
    x_line_num                          IN     NUMBER,
    x_dossier_id                        IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_budget                            IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_entity_name                IN     VARCHAR2,
    x_segment1_low                      IN     VARCHAR2,
    x_segment1_high                     IN     VARCHAR2,
    x_segment2_low                      IN     VARCHAR2,
    x_segment2_high                     IN     VARCHAR2,
    x_segment3_low                      IN     VARCHAR2,
    x_segment3_high                     IN     VARCHAR2,
    x_segment4_low                      IN     VARCHAR2,
    x_segment4_high                     IN     VARCHAR2,
    x_segment5_low                      IN     VARCHAR2,
    x_segment5_high                     IN     VARCHAR2,
    x_segment6_low                      IN     VARCHAR2,
    x_segment6_high                     IN     VARCHAR2,
    x_segment7_high                     IN     VARCHAR2,
    x_segment7_low                      IN     VARCHAR2,
    x_segment8_high                     IN     VARCHAR2,
    x_segment8_low                      IN     VARCHAR2,
    x_segment9_high                     IN     VARCHAR2,
    x_segment9_low                      IN     VARCHAR2,
    x_segment10_high                    IN     VARCHAR2,
    x_segment10_low                     IN     VARCHAR2,
    x_segment11_high                    IN     VARCHAR2,
    x_segment11_low                     IN     VARCHAR2,
    x_segment12_high                    IN     VARCHAR2,
    x_segment12_low                     IN     VARCHAR2,
    x_segment13_high                    IN     VARCHAR2,
    x_segment13_low                     IN     VARCHAR2,
    x_segment14_high                    IN     VARCHAR2,
    x_segment14_low                     IN     VARCHAR2,
    x_segment15_high                    IN     VARCHAR2,
    x_segment15_low                     IN     VARCHAR2,
    x_segment16_high                    IN     VARCHAR2,
    x_segment16_low                     IN     VARCHAR2,
    x_segment17_high                    IN     VARCHAR2,
    x_segment17_low                     IN     VARCHAR2,
    x_segment18_high                    IN     VARCHAR2,
    x_segment18_low                     IN     VARCHAR2,
    x_segment19_high                    IN     VARCHAR2,
    x_segment19_low                     IN     VARCHAR2,
    x_segment20_high                    IN     VARCHAR2,
    x_segment20_low                     IN     VARCHAR2,
    x_segment21_high                    IN     VARCHAR2,
    x_segment21_low                     IN     VARCHAR2,
    x_segment22_high                    IN     VARCHAR2,
    x_segment22_low                     IN     VARCHAR2,
    x_segment23_high                    IN     VARCHAR2,
    x_segment23_low                     IN     VARCHAR2,
    x_segment24_high                    IN     VARCHAR2,
    x_segment24_low                     IN     VARCHAR2,
    x_segment25_low                     IN     VARCHAR2,
    x_segment25_high                    IN     VARCHAR2,
    x_segment26_low                     IN     VARCHAR2,
    x_segment26_high                    IN     VARCHAR2,
    x_segment27_low                     IN     VARCHAR2,
    x_segment27_high                    IN     VARCHAR2,
    x_segment28_low                     IN     VARCHAR2,
    x_segment28_high                    IN     VARCHAR2,
    x_segment29_low                     IN     VARCHAR2,
    x_segment29_high                    IN     VARCHAR2,
    x_segment30_low                     IN     VARCHAR2,
    x_segment30_high                    IN     VARCHAR2,
    x_segments_low_ccid                 IN     NUMBER,
    x_segments_high_ccid                IN     NUMBER,
    x_segments_low_ccid_desc            IN     VARCHAR2,
    x_segments_high_ccid_desc           IN     VARCHAR2,
    x_budget_version_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        line_num,
        dossier_id,
        source_id,
        sob_id,
        coa_id,
        budget,
        budget_entity_id,
        budget_entity_name,
        segment1_low,
        segment1_high,
        segment2_low,
        segment2_high,
        segment3_low,
        segment3_high,
        segment4_low,
        segment4_high,
        segment5_low,
        segment5_high,
        segment6_low,
        segment6_high,
        segment7_high,
        segment7_low,
        segment8_high,
        segment8_low,
        segment9_high,
        segment9_low,
        segment10_high,
        segment10_low,
        segment11_high,
        segment11_low,
        segment12_high,
        segment12_low,
        segment13_high,
        segment13_low,
        segment14_high,
        segment14_low,
        segment15_high,
        segment15_low,
        segment16_high,
        segment16_low,
        segment17_high,
        segment17_low,
        segment18_high,
        segment18_low,
        segment19_high,
        segment19_low,
        segment20_high,
        segment20_low,
        segment21_high,
        segment21_low,
        segment22_high,
        segment22_low,
        segment23_high,
        segment23_low,
        segment24_high,
        segment24_low,
        segment25_low,
        segment25_high,
        segment26_low,
        segment26_high,
        segment27_low,
        segment27_high,
        segment28_low,
        segment28_high,
        segment29_low,
        segment29_high,
        segment30_low,
        segment30_high,
        segments_low_ccid,
        segments_high_ccid,
        segments_low_ccid_desc,
        segments_high_ccid_desc,
        budget_version_id
      FROM  igi_dos_destinations
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.line_num = x_line_num) OR ((tlinfo.line_num IS NULL) AND (X_line_num IS NULL)))
        AND (tlinfo.dossier_id = x_dossier_id)
        AND (tlinfo.source_id = x_source_id)
        AND (tlinfo.sob_id = x_sob_id)
        AND (tlinfo.coa_id = x_coa_id)
        AND ((tlinfo.budget = x_budget) OR ((tlinfo.budget IS NULL) AND (X_budget IS NULL)))
        AND ((tlinfo.budget_entity_id = x_budget_entity_id) OR ((tlinfo.budget_entity_id IS NULL) AND (X_budget_entity_id IS NULL)))
        AND ((tlinfo.budget_entity_name = x_budget_entity_name) OR ((tlinfo.budget_entity_name IS NULL) AND (X_budget_entity_name IS NULL)))
        AND ((tlinfo.segment1_low = x_segment1_low) OR ((tlinfo.segment1_low IS NULL) AND (X_segment1_low IS NULL)))
        AND ((tlinfo.segment1_high = x_segment1_high) OR ((tlinfo.segment1_high IS NULL) AND (X_segment1_high IS NULL)))
        AND ((tlinfo.segment2_low = x_segment2_low) OR ((tlinfo.segment2_low IS NULL) AND (X_segment2_low IS NULL)))
        AND ((tlinfo.segment2_high = x_segment2_high) OR ((tlinfo.segment2_high IS NULL) AND (X_segment2_high IS NULL)))
        AND ((tlinfo.segment3_low = x_segment3_low) OR ((tlinfo.segment3_low IS NULL) AND (X_segment3_low IS NULL)))
        AND ((tlinfo.segment3_high = x_segment3_high) OR ((tlinfo.segment3_high IS NULL) AND (X_segment3_high IS NULL)))
        AND ((tlinfo.segment4_low = x_segment4_low) OR ((tlinfo.segment4_low IS NULL) AND (X_segment4_low IS NULL)))
        AND ((tlinfo.segment4_high = x_segment4_high) OR ((tlinfo.segment4_high IS NULL) AND (X_segment4_high IS NULL)))
        AND ((tlinfo.segment5_low = x_segment5_low) OR ((tlinfo.segment5_low IS NULL) AND (X_segment5_low IS NULL)))
        AND ((tlinfo.segment5_high = x_segment5_high) OR ((tlinfo.segment5_high IS NULL) AND (X_segment5_high IS NULL)))
        AND ((tlinfo.segment6_low = x_segment6_low) OR ((tlinfo.segment6_low IS NULL) AND (X_segment6_low IS NULL)))
        AND ((tlinfo.segment6_high = x_segment6_high) OR ((tlinfo.segment6_high IS NULL) AND (X_segment6_high IS NULL)))
        AND ((tlinfo.segment7_high = x_segment7_high) OR ((tlinfo.segment7_high IS NULL) AND (X_segment7_high IS NULL)))
        AND ((tlinfo.segment7_low = x_segment7_low) OR ((tlinfo.segment7_low IS NULL) AND (X_segment7_low IS NULL)))
        AND ((tlinfo.segment8_high = x_segment8_high) OR ((tlinfo.segment8_high IS NULL) AND (X_segment8_high IS NULL)))
        AND ((tlinfo.segment8_low = x_segment8_low) OR ((tlinfo.segment8_low IS NULL) AND (X_segment8_low IS NULL)))
        AND ((tlinfo.segment9_high = x_segment9_high) OR ((tlinfo.segment9_high IS NULL) AND (X_segment9_high IS NULL)))
        AND ((tlinfo.segment9_low = x_segment9_low) OR ((tlinfo.segment9_low IS NULL) AND (X_segment9_low IS NULL)))
        AND ((tlinfo.segment10_high = x_segment10_high) OR ((tlinfo.segment10_high IS NULL) AND (X_segment10_high IS NULL)))
        AND ((tlinfo.segment10_low = x_segment10_low) OR ((tlinfo.segment10_low IS NULL) AND (X_segment10_low IS NULL)))
        AND ((tlinfo.segment11_high = x_segment11_high) OR ((tlinfo.segment11_high IS NULL) AND (X_segment11_high IS NULL)))
        AND ((tlinfo.segment11_low = x_segment11_low) OR ((tlinfo.segment11_low IS NULL) AND (X_segment11_low IS NULL)))
        AND ((tlinfo.segment12_high = x_segment12_high) OR ((tlinfo.segment12_high IS NULL) AND (X_segment12_high IS NULL)))
        AND ((tlinfo.segment12_low = x_segment12_low) OR ((tlinfo.segment12_low IS NULL) AND (X_segment12_low IS NULL)))
        AND ((tlinfo.segment13_high = x_segment13_high) OR ((tlinfo.segment13_high IS NULL) AND (X_segment13_high IS NULL)))
        AND ((tlinfo.segment13_low = x_segment13_low) OR ((tlinfo.segment13_low IS NULL) AND (X_segment13_low IS NULL)))
        AND ((tlinfo.segment14_high = x_segment14_high) OR ((tlinfo.segment14_high IS NULL) AND (X_segment14_high IS NULL)))
        AND ((tlinfo.segment14_low = x_segment14_low) OR ((tlinfo.segment14_low IS NULL) AND (X_segment14_low IS NULL)))
        AND ((tlinfo.segment15_high = x_segment15_high) OR ((tlinfo.segment15_high IS NULL) AND (X_segment15_high IS NULL)))
        AND ((tlinfo.segment15_low = x_segment15_low) OR ((tlinfo.segment15_low IS NULL) AND (X_segment15_low IS NULL)))
        AND ((tlinfo.segment16_high = x_segment16_high) OR ((tlinfo.segment16_high IS NULL) AND (X_segment16_high IS NULL)))
        AND ((tlinfo.segment16_low = x_segment16_low) OR ((tlinfo.segment16_low IS NULL) AND (X_segment16_low IS NULL)))
        AND ((tlinfo.segment17_high = x_segment17_high) OR ((tlinfo.segment17_high IS NULL) AND (X_segment17_high IS NULL)))
        AND ((tlinfo.segment17_low = x_segment17_low) OR ((tlinfo.segment17_low IS NULL) AND (X_segment17_low IS NULL)))
        AND ((tlinfo.segment18_high = x_segment18_high) OR ((tlinfo.segment18_high IS NULL) AND (X_segment18_high IS NULL)))
        AND ((tlinfo.segment18_low = x_segment18_low) OR ((tlinfo.segment18_low IS NULL) AND (X_segment18_low IS NULL)))
        AND ((tlinfo.segment19_high = x_segment19_high) OR ((tlinfo.segment19_high IS NULL) AND (X_segment19_high IS NULL)))
        AND ((tlinfo.segment19_low = x_segment19_low) OR ((tlinfo.segment19_low IS NULL) AND (X_segment19_low IS NULL)))
        AND ((tlinfo.segment20_high = x_segment20_high) OR ((tlinfo.segment20_high IS NULL) AND (X_segment20_high IS NULL)))
        AND ((tlinfo.segment20_low = x_segment20_low) OR ((tlinfo.segment20_low IS NULL) AND (X_segment20_low IS NULL)))
        AND ((tlinfo.segment21_high = x_segment21_high) OR ((tlinfo.segment21_high IS NULL) AND (X_segment21_high IS NULL)))
        AND ((tlinfo.segment21_low = x_segment21_low) OR ((tlinfo.segment21_low IS NULL) AND (X_segment21_low IS NULL)))
        AND ((tlinfo.segment22_high = x_segment22_high) OR ((tlinfo.segment22_high IS NULL) AND (X_segment22_high IS NULL)))
        AND ((tlinfo.segment22_low = x_segment22_low) OR ((tlinfo.segment22_low IS NULL) AND (X_segment22_low IS NULL)))
        AND ((tlinfo.segment23_high = x_segment23_high) OR ((tlinfo.segment23_high IS NULL) AND (X_segment23_high IS NULL)))
        AND ((tlinfo.segment23_low = x_segment23_low) OR ((tlinfo.segment23_low IS NULL) AND (X_segment23_low IS NULL)))
        AND ((tlinfo.segment24_high = x_segment24_high) OR ((tlinfo.segment24_high IS NULL) AND (X_segment24_high IS NULL)))
        AND ((tlinfo.segment24_low = x_segment24_low) OR ((tlinfo.segment24_low IS NULL) AND (X_segment24_low IS NULL)))
        AND ((tlinfo.segment25_low = x_segment25_low) OR ((tlinfo.segment25_low IS NULL) AND (X_segment25_low IS NULL)))
        AND ((tlinfo.segment25_high = x_segment25_high) OR ((tlinfo.segment25_high IS NULL) AND (X_segment25_high IS NULL)))
        AND ((tlinfo.segment26_low = x_segment26_low) OR ((tlinfo.segment26_low IS NULL) AND (X_segment26_low IS NULL)))
        AND ((tlinfo.segment26_high = x_segment26_high) OR ((tlinfo.segment26_high IS NULL) AND (X_segment26_high IS NULL)))
        AND ((tlinfo.segment27_low = x_segment27_low) OR ((tlinfo.segment27_low IS NULL) AND (X_segment27_low IS NULL)))
        AND ((tlinfo.segment27_high = x_segment27_high) OR ((tlinfo.segment27_high IS NULL) AND (X_segment27_high IS NULL)))
        AND ((tlinfo.segment28_low = x_segment28_low) OR ((tlinfo.segment28_low IS NULL) AND (X_segment28_low IS NULL)))
        AND ((tlinfo.segment28_high = x_segment28_high) OR ((tlinfo.segment28_high IS NULL) AND (X_segment28_high IS NULL)))
        AND ((tlinfo.segment29_low = x_segment29_low) OR ((tlinfo.segment29_low IS NULL) AND (X_segment29_low IS NULL)))
        AND ((tlinfo.segment29_high = x_segment29_high) OR ((tlinfo.segment29_high IS NULL) AND (X_segment29_high IS NULL)))
        AND ((tlinfo.segment30_low = x_segment30_low) OR ((tlinfo.segment30_low IS NULL) AND (X_segment30_low IS NULL)))
        AND ((tlinfo.segment30_high = x_segment30_high) OR ((tlinfo.segment30_high IS NULL) AND (X_segment30_high IS NULL)))
        AND ((tlinfo.segments_low_ccid = x_segments_low_ccid) OR ((tlinfo.segments_low_ccid IS NULL) AND (X_segments_low_ccid IS NULL)))
        AND ((tlinfo.segments_high_ccid = x_segments_high_ccid) OR ((tlinfo.segments_high_ccid IS NULL) AND (X_segments_high_ccid IS NULL)))
        AND ((tlinfo.segments_low_ccid_desc = x_segments_low_ccid_desc) OR ((tlinfo.segments_low_ccid_desc IS NULL) AND (X_segments_low_ccid_desc IS NULL)))
        AND ((tlinfo.segments_high_ccid_desc = x_segments_high_ccid_desc) OR ((tlinfo.segments_high_ccid_desc IS NULL) AND (X_segments_high_ccid_desc IS NULL)))
        AND ((tlinfo.budget_version_id = x_budget_version_id) OR ((tlinfo.budget_version_id IS NULL) AND (X_budget_version_id IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.lock_row.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_line_num                          IN     NUMBER,
    x_dossier_id                        IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_budget                            IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_entity_name                IN     VARCHAR2,
    x_segment1_low                      IN     VARCHAR2,
    x_segment1_high                     IN     VARCHAR2,
    x_segment2_low                      IN     VARCHAR2,
    x_segment2_high                     IN     VARCHAR2,
    x_segment3_low                      IN     VARCHAR2,
    x_segment3_high                     IN     VARCHAR2,
    x_segment4_low                      IN     VARCHAR2,
    x_segment4_high                     IN     VARCHAR2,
    x_segment5_low                      IN     VARCHAR2,
    x_segment5_high                     IN     VARCHAR2,
    x_segment6_low                      IN     VARCHAR2,
    x_segment6_high                     IN     VARCHAR2,
    x_segment7_high                     IN     VARCHAR2,
    x_segment7_low                      IN     VARCHAR2,
    x_segment8_high                     IN     VARCHAR2,
    x_segment8_low                      IN     VARCHAR2,
    x_segment9_high                     IN     VARCHAR2,
    x_segment9_low                      IN     VARCHAR2,
    x_segment10_high                    IN     VARCHAR2,
    x_segment10_low                     IN     VARCHAR2,
    x_segment11_high                    IN     VARCHAR2,
    x_segment11_low                     IN     VARCHAR2,
    x_segment12_high                    IN     VARCHAR2,
    x_segment12_low                     IN     VARCHAR2,
    x_segment13_high                    IN     VARCHAR2,
    x_segment13_low                     IN     VARCHAR2,
    x_segment14_high                    IN     VARCHAR2,
    x_segment14_low                     IN     VARCHAR2,
    x_segment15_high                    IN     VARCHAR2,
    x_segment15_low                     IN     VARCHAR2,
    x_segment16_high                    IN     VARCHAR2,
    x_segment16_low                     IN     VARCHAR2,
    x_segment17_high                    IN     VARCHAR2,
    x_segment17_low                     IN     VARCHAR2,
    x_segment18_high                    IN     VARCHAR2,
    x_segment18_low                     IN     VARCHAR2,
    x_segment19_high                    IN     VARCHAR2,
    x_segment19_low                     IN     VARCHAR2,
    x_segment20_high                    IN     VARCHAR2,
    x_segment20_low                     IN     VARCHAR2,
    x_segment21_high                    IN     VARCHAR2,
    x_segment21_low                     IN     VARCHAR2,
    x_segment22_high                    IN     VARCHAR2,
    x_segment22_low                     IN     VARCHAR2,
    x_segment23_high                    IN     VARCHAR2,
    x_segment23_low                     IN     VARCHAR2,
    x_segment24_high                    IN     VARCHAR2,
    x_segment24_low                     IN     VARCHAR2,
    x_segment25_low                     IN     VARCHAR2,
    x_segment25_high                    IN     VARCHAR2,
    x_segment26_low                     IN     VARCHAR2,
    x_segment26_high                    IN     VARCHAR2,
    x_segment27_low                     IN     VARCHAR2,
    x_segment27_high                    IN     VARCHAR2,
    x_segment28_low                     IN     VARCHAR2,
    x_segment28_high                    IN     VARCHAR2,
    x_segment29_low                     IN     VARCHAR2,
    x_segment29_high                    IN     VARCHAR2,
    x_segment30_low                     IN     VARCHAR2,
    x_segment30_high                    IN     VARCHAR2,
    x_segments_low_ccid                 IN     NUMBER,
    x_segments_high_ccid                IN     NUMBER,
    x_segments_low_ccid_desc            IN     VARCHAR2,
    x_segments_high_ccid_desc           IN     VARCHAR2,
    x_budget_version_id                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_destinations_pkg.update_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_line_num                          => x_line_num,
      x_dossier_id                        => x_dossier_id,
      x_source_id                         => x_source_id,
      x_destination_id                    => x_destination_id,
      x_sob_id                            => x_sob_id,
      x_coa_id                            => x_coa_id,
      x_budget                            => x_budget,
      x_budget_entity_id                  => x_budget_entity_id,
      x_budget_entity_name                => x_budget_entity_name,
      x_segment1_low                      => x_segment1_low,
      x_segment1_high                     => x_segment1_high,
      x_segment2_low                      => x_segment2_low,
      x_segment2_high                     => x_segment2_high,
      x_segment3_low                      => x_segment3_low,
      x_segment3_high                     => x_segment3_high,
      x_segment4_low                      => x_segment4_low,
      x_segment4_high                     => x_segment4_high,
      x_segment5_low                      => x_segment5_low,
      x_segment5_high                     => x_segment5_high,
      x_segment6_low                      => x_segment6_low,
      x_segment6_high                     => x_segment6_high,
      x_segment7_high                     => x_segment7_high,
      x_segment7_low                      => x_segment7_low,
      x_segment8_high                     => x_segment8_high,
      x_segment8_low                      => x_segment8_low,
      x_segment9_high                     => x_segment9_high,
      x_segment9_low                      => x_segment9_low,
      x_segment10_high                    => x_segment10_high,
      x_segment10_low                     => x_segment10_low,
      x_segment11_high                    => x_segment11_high,
      x_segment11_low                     => x_segment11_low,
      x_segment12_high                    => x_segment12_high,
      x_segment12_low                     => x_segment12_low,
      x_segment13_high                    => x_segment13_high,
      x_segment13_low                     => x_segment13_low,
      x_segment14_high                    => x_segment14_high,
      x_segment14_low                     => x_segment14_low,
      x_segment15_high                    => x_segment15_high,
      x_segment15_low                     => x_segment15_low,
      x_segment16_high                    => x_segment16_high,
      x_segment16_low                     => x_segment16_low,
      x_segment17_high                    => x_segment17_high,
      x_segment17_low                     => x_segment17_low,
      x_segment18_high                    => x_segment18_high,
      x_segment18_low                     => x_segment18_low,
      x_segment19_high                    => x_segment19_high,
      x_segment19_low                     => x_segment19_low,
      x_segment20_high                    => x_segment20_high,
      x_segment20_low                     => x_segment20_low,
      x_segment21_high                    => x_segment21_high,
      x_segment21_low                     => x_segment21_low,
      x_segment22_high                    => x_segment22_high,
      x_segment22_low                     => x_segment22_low,
      x_segment23_high                    => x_segment23_high,
      x_segment23_low                     => x_segment23_low,
      x_segment24_high                    => x_segment24_high,
      x_segment24_low                     => x_segment24_low,
      x_segment25_low                     => x_segment25_low,
      x_segment25_high                    => x_segment25_high,
      x_segment26_low                     => x_segment26_low,
      x_segment26_high                    => x_segment26_high,
      x_segment27_low                     => x_segment27_low,
      x_segment27_high                    => x_segment27_high,
      x_segment28_low                     => x_segment28_low,
      x_segment28_high                    => x_segment28_high,
      x_segment29_low                     => x_segment29_low,
      x_segment29_high                    => x_segment29_high,
      x_segment30_low                     => x_segment30_low,
      x_segment30_high                    => x_segment30_high,
      x_segments_low_ccid                 => x_segments_low_ccid,
      x_segments_high_ccid                => x_segments_high_ccid,
      x_segments_low_ccid_desc            => x_segments_low_ccid_desc,
      x_segments_high_ccid_desc           => x_segments_high_ccid_desc,
      x_budget_version_id                 => x_budget_version_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_dos_destinations
      SET
        line_num                          = new_references.line_num,
        dossier_id                        = new_references.dossier_id,
        source_id                         = new_references.source_id,
        sob_id                            = new_references.sob_id,
        coa_id                            = new_references.coa_id,
        budget                            = new_references.budget,
        budget_entity_id                  = new_references.budget_entity_id,
        budget_entity_name                = new_references.budget_entity_name,
        segment1_low                      = new_references.segment1_low,
        segment1_high                     = new_references.segment1_high,
        segment2_low                      = new_references.segment2_low,
        segment2_high                     = new_references.segment2_high,
        segment3_low                      = new_references.segment3_low,
        segment3_high                     = new_references.segment3_high,
        segment4_low                      = new_references.segment4_low,
        segment4_high                     = new_references.segment4_high,
        segment5_low                      = new_references.segment5_low,
        segment5_high                     = new_references.segment5_high,
        segment6_low                      = new_references.segment6_low,
        segment6_high                     = new_references.segment6_high,
        segment7_high                     = new_references.segment7_high,
        segment7_low                      = new_references.segment7_low,
        segment8_high                     = new_references.segment8_high,
        segment8_low                      = new_references.segment8_low,
        segment9_high                     = new_references.segment9_high,
        segment9_low                      = new_references.segment9_low,
        segment10_high                    = new_references.segment10_high,
        segment10_low                     = new_references.segment10_low,
        segment11_high                    = new_references.segment11_high,
        segment11_low                     = new_references.segment11_low,
        segment12_high                    = new_references.segment12_high,
        segment12_low                     = new_references.segment12_low,
        segment13_high                    = new_references.segment13_high,
        segment13_low                     = new_references.segment13_low,
        segment14_high                    = new_references.segment14_high,
        segment14_low                     = new_references.segment14_low,
        segment15_high                    = new_references.segment15_high,
        segment15_low                     = new_references.segment15_low,
        segment16_high                    = new_references.segment16_high,
        segment16_low                     = new_references.segment16_low,
        segment17_high                    = new_references.segment17_high,
        segment17_low                     = new_references.segment17_low,
        segment18_high                    = new_references.segment18_high,
        segment18_low                     = new_references.segment18_low,
        segment19_high                    = new_references.segment19_high,
        segment19_low                     = new_references.segment19_low,
        segment20_high                    = new_references.segment20_high,
        segment20_low                     = new_references.segment20_low,
        segment21_high                    = new_references.segment21_high,
        segment21_low                     = new_references.segment21_low,
        segment22_high                    = new_references.segment22_high,
        segment22_low                     = new_references.segment22_low,
        segment23_high                    = new_references.segment23_high,
        segment23_low                     = new_references.segment23_low,
        segment24_high                    = new_references.segment24_high,
        segment24_low                     = new_references.segment24_low,
        segment25_low                     = new_references.segment25_low,
        segment25_high                    = new_references.segment25_high,
        segment26_low                     = new_references.segment26_low,
        segment26_high                    = new_references.segment26_high,
        segment27_low                     = new_references.segment27_low,
        segment27_high                    = new_references.segment27_high,
        segment28_low                     = new_references.segment28_low,
        segment28_high                    = new_references.segment28_high,
        segment29_low                     = new_references.segment29_low,
        segment29_high                    = new_references.segment29_high,
        segment30_low                     = new_references.segment30_low,
        segment30_high                    = new_references.segment30_high,
        segments_low_ccid                 = new_references.segments_low_ccid,
        segments_high_ccid                = new_references.segments_high_ccid,
        segments_low_ccid_desc            = new_references.segments_low_ccid_desc,
        segments_high_ccid_desc           = new_references.segments_high_ccid_desc,
        budget_version_id                 = new_references.budget_version_id,
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
    x_line_num                          IN     NUMBER,
    x_dossier_id                        IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN OUT NOCOPY NUMBER,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_budget                            IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_entity_name                IN     VARCHAR2,
    x_segment1_low                      IN     VARCHAR2,
    x_segment1_high                     IN     VARCHAR2,
    x_segment2_low                      IN     VARCHAR2,
    x_segment2_high                     IN     VARCHAR2,
    x_segment3_low                      IN     VARCHAR2,
    x_segment3_high                     IN     VARCHAR2,
    x_segment4_low                      IN     VARCHAR2,
    x_segment4_high                     IN     VARCHAR2,
    x_segment5_low                      IN     VARCHAR2,
    x_segment5_high                     IN     VARCHAR2,
    x_segment6_low                      IN     VARCHAR2,
    x_segment6_high                     IN     VARCHAR2,
    x_segment7_high                     IN     VARCHAR2,
    x_segment7_low                      IN     VARCHAR2,
    x_segment8_high                     IN     VARCHAR2,
    x_segment8_low                      IN     VARCHAR2,
    x_segment9_high                     IN     VARCHAR2,
    x_segment9_low                      IN     VARCHAR2,
    x_segment10_high                    IN     VARCHAR2,
    x_segment10_low                     IN     VARCHAR2,
    x_segment11_high                    IN     VARCHAR2,
    x_segment11_low                     IN     VARCHAR2,
    x_segment12_high                    IN     VARCHAR2,
    x_segment12_low                     IN     VARCHAR2,
    x_segment13_high                    IN     VARCHAR2,
    x_segment13_low                     IN     VARCHAR2,
    x_segment14_high                    IN     VARCHAR2,
    x_segment14_low                     IN     VARCHAR2,
    x_segment15_high                    IN     VARCHAR2,
    x_segment15_low                     IN     VARCHAR2,
    x_segment16_high                    IN     VARCHAR2,
    x_segment16_low                     IN     VARCHAR2,
    x_segment17_high                    IN     VARCHAR2,
    x_segment17_low                     IN     VARCHAR2,
    x_segment18_high                    IN     VARCHAR2,
    x_segment18_low                     IN     VARCHAR2,
    x_segment19_high                    IN     VARCHAR2,
    x_segment19_low                     IN     VARCHAR2,
    x_segment20_high                    IN     VARCHAR2,
    x_segment20_low                     IN     VARCHAR2,
    x_segment21_high                    IN     VARCHAR2,
    x_segment21_low                     IN     VARCHAR2,
    x_segment22_high                    IN     VARCHAR2,
    x_segment22_low                     IN     VARCHAR2,
    x_segment23_high                    IN     VARCHAR2,
    x_segment23_low                     IN     VARCHAR2,
    x_segment24_high                    IN     VARCHAR2,
    x_segment24_low                     IN     VARCHAR2,
    x_segment25_low                     IN     VARCHAR2,
    x_segment25_high                    IN     VARCHAR2,
    x_segment26_low                     IN     VARCHAR2,
    x_segment26_high                    IN     VARCHAR2,
    x_segment27_low                     IN     VARCHAR2,
    x_segment27_high                    IN     VARCHAR2,
    x_segment28_low                     IN     VARCHAR2,
    x_segment28_high                    IN     VARCHAR2,
    x_segment29_low                     IN     VARCHAR2,
    x_segment29_high                    IN     VARCHAR2,
    x_segment30_low                     IN     VARCHAR2,
    x_segment30_high                    IN     VARCHAR2,
    x_segments_low_ccid                 IN     NUMBER,
    x_segments_high_ccid                IN     NUMBER,
    x_segments_low_ccid_desc            IN     VARCHAR2,
    x_segments_high_ccid_desc           IN     VARCHAR2,
    x_budget_version_id                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_dos_destinations
      WHERE    destination_id                    = x_destination_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_line_num,
        x_dossier_id,
        x_source_id,
        x_destination_id,
        x_sob_id,
        x_coa_id,
        x_budget,
        x_budget_entity_id,
        x_budget_entity_name,
        x_segment1_low,
        x_segment1_high,
        x_segment2_low,
        x_segment2_high,
        x_segment3_low,
        x_segment3_high,
        x_segment4_low,
        x_segment4_high,
        x_segment5_low,
        x_segment5_high,
        x_segment6_low,
        x_segment6_high,
        x_segment7_high,
        x_segment7_low,
        x_segment8_high,
        x_segment8_low,
        x_segment9_high,
        x_segment9_low,
        x_segment10_high,
        x_segment10_low,
        x_segment11_high,
        x_segment11_low,
        x_segment12_high,
        x_segment12_low,
        x_segment13_high,
        x_segment13_low,
        x_segment14_high,
        x_segment14_low,
        x_segment15_high,
        x_segment15_low,
        x_segment16_high,
        x_segment16_low,
        x_segment17_high,
        x_segment17_low,
        x_segment18_high,
        x_segment18_low,
        x_segment19_high,
        x_segment19_low,
        x_segment20_high,
        x_segment20_low,
        x_segment21_high,
        x_segment21_low,
        x_segment22_high,
        x_segment22_low,
        x_segment23_high,
        x_segment23_low,
        x_segment24_high,
        x_segment24_low,
        x_segment25_low,
        x_segment25_high,
        x_segment26_low,
        x_segment26_high,
        x_segment27_low,
        x_segment27_high,
        x_segment28_low,
        x_segment28_high,
        x_segment29_low,
        x_segment29_high,
        x_segment30_low,
        x_segment30_high,
        x_segments_low_ccid,
        x_segments_high_ccid,
        x_segments_low_ccid_desc,
        x_segments_high_ccid_desc,
        x_budget_version_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_line_num,
      x_dossier_id,
      x_source_id,
      x_destination_id,
      x_sob_id,
      x_coa_id,
      x_budget,
      x_budget_entity_id,
      x_budget_entity_name,
      x_segment1_low,
      x_segment1_high,
      x_segment2_low,
      x_segment2_high,
      x_segment3_low,
      x_segment3_high,
      x_segment4_low,
      x_segment4_high,
      x_segment5_low,
      x_segment5_high,
      x_segment6_low,
      x_segment6_high,
      x_segment7_high,
      x_segment7_low,
      x_segment8_high,
      x_segment8_low,
      x_segment9_high,
      x_segment9_low,
      x_segment10_high,
      x_segment10_low,
      x_segment11_high,
      x_segment11_low,
      x_segment12_high,
      x_segment12_low,
      x_segment13_high,
      x_segment13_low,
      x_segment14_high,
      x_segment14_low,
      x_segment15_high,
      x_segment15_low,
      x_segment16_high,
      x_segment16_low,
      x_segment17_high,
      x_segment17_low,
      x_segment18_high,
      x_segment18_low,
      x_segment19_high,
      x_segment19_low,
      x_segment20_high,
      x_segment20_low,
      x_segment21_high,
      x_segment21_low,
      x_segment22_high,
      x_segment22_low,
      x_segment23_high,
      x_segment23_low,
      x_segment24_high,
      x_segment24_low,
      x_segment25_low,
      x_segment25_high,
      x_segment26_low,
      x_segment26_high,
      x_segment27_low,
      x_segment27_high,
      x_segment28_low,
      x_segment28_high,
      x_segment29_low,
      x_segment29_high,
      x_segment30_low,
      x_segment30_high,
      x_segments_low_ccid,
      x_segments_high_ccid,
      x_segments_low_ccid_desc,
      x_segments_high_ccid_desc,
      x_budget_version_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igi_dos_destinations
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_dos_destinations_pkg;

/
