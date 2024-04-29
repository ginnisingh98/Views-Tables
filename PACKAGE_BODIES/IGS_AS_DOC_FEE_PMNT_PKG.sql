--------------------------------------------------------
--  DDL for Package Body IGS_AS_DOC_FEE_PMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DOC_FEE_PMNT_PKG" AS
/* $Header: IGSDI72B.pls 115.3 2002/11/28 23:29:39 nsidana noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_as_doc_fee_pmnt%ROWTYPE;
  new_references igs_as_doc_fee_pmnt%ROWTYPE;
  FUNCTION check_unique_calseq (p_person_id  IN NUMBER,
                                p_plan_id    IN NUMBER,
				p_cal_type   IN VARCHAR2,
				p_seq_num    IN NUMBER)
  RETURN boolean;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER  ,
    x_fee_paid_date                     IN     DATE    ,
    x_fee_amount                        IN     NUMBER  ,
    x_fee_recorded_date                 IN     DATE    ,
    x_fee_recorded_by                   IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_doc_fee_pmnt
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id                         := x_person_id;
    new_references.fee_paid_date                     := x_fee_paid_date;
    new_references.fee_amount                        := x_fee_amount;
    new_references.fee_recorded_date                 := x_fee_recorded_date;
    new_references.fee_recorded_by                   := x_fee_recorded_by;
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
    new_references.plan_id                           := x_plan_id;
    new_references.invoice_id                        := x_invoice_id;
    new_references.plan_discon_from                  := x_plan_discon_from;
    IF x_plan_discon_from IS NULL OR x_plan_discon_from = '' THEN
       new_references.plan_discon_by                    := NULL;
    ELSE
       new_references.plan_discon_by                    := x_plan_discon_by;
    END IF;
    new_references.num_of_copies                     := x_num_of_copies;
    new_references.prev_paid_plan                    := x_prev_paid_plan;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.program_on_file                   := x_program_on_file;
  END set_column_values;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER  ,
    x_fee_paid_date                     IN     DATE    ,
    x_fee_amount                        IN     NUMBER  ,
    x_fee_recorded_date                 IN     DATE    ,
    x_fee_recorded_by                   IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
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
      x_person_id,
      x_fee_paid_date,
      x_fee_amount,
      x_fee_recorded_date,
      x_fee_recorded_by,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_plan_id          ,
      x_invoice_id       ,
      x_plan_discon_from ,
      x_plan_discon_by   ,
      x_num_of_copies    ,
      x_prev_paid_plan   ,
      x_cal_type         ,
      x_ci_sequence_number,
      x_program_on_file
    );
    IF (p_action = 'INSERT') THEN
      -- Check uniqueness if cal type and seq num are not null
      IF new_references.cal_type IS NOT NULL AND
         new_references.ci_sequence_number IS NOT NULL THEN
         IF ( check_unique_calseq(
              new_references.person_id,
              new_references.plan_id,
              new_references.cal_type,
              new_references.ci_sequence_number
            )
          ) THEN
            fnd_message.set_name('IGS','IGS_AS_PLAN_EXISTS_CAL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
    END IF;
  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     igs_as_doc_fee_pmnt
      WHERE    person_id                         = x_person_id;
    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
  BEGIN
    FND_MSG_PUB.initialize;
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_fee_paid_date                     => x_fee_paid_date,
      x_fee_amount                        => x_fee_amount,
      x_fee_recorded_date                 => x_fee_recorded_date,
      x_fee_recorded_by                   => x_fee_recorded_by,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_plan_id                           => x_plan_id           ,
      x_invoice_id                        => x_invoice_id        ,
      x_plan_discon_from                  => x_plan_discon_from  ,
      x_plan_discon_by                    => x_plan_discon_by    ,
      x_num_of_copies                     => x_num_of_copies     ,
      x_prev_paid_plan                    => x_prev_paid_plan    ,
      x_cal_type                          => x_cal_type          ,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_program_on_file                   => x_program_on_file

    );
    INSERT INTO igs_as_doc_fee_pmnt (
      person_id,
      fee_paid_date,
      fee_amount,
      fee_recorded_date,
      fee_recorded_by,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      plan_id     ,
      invoice_id  ,
      plan_discon_from  ,
      plan_discon_by  ,
      num_of_copies  ,
      prev_paid_plan ,
      cal_type    ,
      ci_sequence_number,
      program_on_file
    ) VALUES (
      new_references.person_id,
      new_references.fee_paid_date,
      new_references.fee_amount,
      new_references.fee_recorded_date,
      new_references.fee_recorded_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.plan_id           ,
      new_references.invoice_id        ,
      new_references.plan_discon_from  ,
      new_references.plan_discon_by    ,
      new_references.num_of_copies     ,
      new_references.prev_paid_plan    ,
      new_references.cal_type          ,
      new_references.ci_sequence_number,
      new_references.program_on_file
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  -- Initialize API return status to success.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
     FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                     p_encoded => FND_API.G_FALSE,
                     p_count => x_MSG_COUNT,
                     p_data  => X_MSG_DATA);
     RETURN;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                    FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_MSG_COUNT,
                        p_data  => X_MSG_DATA);
     RETURN;
        WHEN OTHERS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
             FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
     RETURN;

  END insert_row;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        fee_paid_date,
        fee_amount,
        fee_recorded_date,
        fee_recorded_by,
        plan_id          ,
        invoice_id        ,
        plan_discon_from  ,
        plan_discon_by    ,
        num_of_copies     ,
        prev_paid_plan    ,
        cal_type          ,
        ci_sequence_number,
        program_on_file
      FROM  igs_as_doc_fee_pmnt
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    FND_MSG_PUB.initialize;
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF (
        (tlinfo.person_id = x_person_id)
        AND ((trunc(tlinfo.fee_paid_date) = trunc(x_fee_paid_date)) OR ((tlinfo.fee_paid_date IS NULL) AND (X_fee_paid_date IS NULL)))
        AND ((tlinfo.fee_amount = x_fee_amount) OR ((tlinfo.fee_amount IS NULL) AND (X_fee_amount IS NULL)))
        AND ((trunc(tlinfo.fee_recorded_date) = trunc(x_fee_recorded_date)) OR ((tlinfo.fee_recorded_date IS NULL) AND (X_fee_recorded_date IS NULL)))
        AND ((tlinfo.fee_recorded_by = x_fee_recorded_by) OR ((tlinfo.fee_recorded_by IS NULL) AND (X_fee_recorded_by IS NULL)))
        AND ((tlinfo.plan_id = x_plan_id) OR ((tlinfo.plan_id IS NULL) AND (X_plan_id IS NULL)))
        AND ((tlinfo.invoice_id = x_invoice_id) OR ((tlinfo.invoice_id IS NULL) AND (X_invoice_id IS NULL)))
        AND ((trunc(tlinfo.plan_discon_from) = trunc(x_plan_discon_from)) OR ((tlinfo.plan_discon_from IS NULL) AND (X_plan_discon_from IS NULL)))
        AND ((tlinfo.plan_discon_by = x_plan_discon_by) OR ((tlinfo.plan_discon_by IS NULL) AND (X_plan_discon_by IS NULL)))
        AND ((tlinfo.num_of_copies = x_num_of_copies) OR ((tlinfo.num_of_copies IS NULL) AND (X_num_of_copies IS NULL)))
        AND ((tlinfo.prev_paid_plan = x_prev_paid_plan) OR ((tlinfo.prev_paid_plan IS NULL) AND (X_prev_paid_plan IS NULL)))
        AND ((tlinfo.cal_type = x_cal_type) OR ((tlinfo.cal_type IS NULL) AND (X_cal_type IS NULL)))
        AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
        AND ((tlinfo.program_on_file = x_program_on_file) OR ((tlinfo.program_on_file IS NULL) AND (X_program_on_file IS NULL)))

       ) THEN

      NULL;
    ELSE
      fnd_message.set_name('FND', '*'||x_rowid||'*');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  -- Initialize API return status to success.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
     RETURN;
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                 p_encoded => FND_API.G_FALSE,
                 p_count => x_MSG_COUNT,
                 p_data  => X_MSG_DATA);
 RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_MSG_COUNT,
                    p_data  => X_MSG_DATA);
 RETURN;
  WHEN OTHERS THEN
         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);
 RETURN;

 END lock_row;
  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
    ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
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
    FND_MSG_PUB.initialize;
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_fee_paid_date                     => x_fee_paid_date,
      x_fee_amount                        => x_fee_amount,
      x_fee_recorded_date                 => x_fee_recorded_date,
      x_fee_recorded_by                   => x_fee_recorded_by,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_plan_id                           => x_plan_id           ,
      x_invoice_id                        => x_invoice_id        ,
      x_plan_discon_from                  => x_plan_discon_from  ,
      x_plan_discon_by                    => x_plan_discon_by    ,
      x_num_of_copies                     => x_num_of_copies     ,
      x_prev_paid_plan                    => x_prev_paid_plan    ,
      x_cal_type                          => x_cal_type          ,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_program_on_file                   => x_program_on_file
    );
    UPDATE igs_as_doc_fee_pmnt
      SET
        fee_paid_date                     = new_references.fee_paid_date,
        fee_amount                        = new_references.fee_amount,
        fee_recorded_date                 = new_references.fee_recorded_date,
        fee_recorded_by                   = new_references.fee_recorded_by,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        plan_id                           = new_references.plan_id,
        invoice_id                        = new_references.invoice_id   ,
        plan_discon_from                  = new_references.plan_discon_from ,
        plan_discon_by                    = new_references.plan_discon_by    ,
        num_of_copies                     = new_references.num_of_copies     ,
        prev_paid_plan                    = new_references.prev_paid_plan    ,
        cal_type                          = new_references.cal_type          ,
        ci_sequence_number                = new_references.ci_sequence_number,
        program_on_file                   = new_references.program_on_file
      WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  --
  -- call the api IGS_AS_SS_DOC_REQUEST.RE_CALC_DOC_FESS
  -- to recalculate the fee if the plan is unsubscribed
  --
  DECLARE
    l_orders_recalc  VARCHAR2(2000);
  BEGIN
     IF old_references.plan_discon_by  IS NULL AND new_references.plan_discon_by  IS NOT NULL THEN
        IGS_AS_SS_DOC_REQUEST.RE_CALC_DOC_FEES (
                                p_person_id       => x_person_id,
				p_plan_id         => new_references.plan_id,
				p_subs_unsubs     => 'U',
                                p_admin_person_id => new_references.plan_discon_by,
                                p_orders_recalc   => l_orders_recalc);
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME ('IGS','IGS_AS_TRNS_RECLC_ERR');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;


  -- Initialize API return status to success.
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Update_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;


  END update_row;

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_fee_paid_date                     IN     DATE,
    x_fee_amount                        IN     NUMBER,
    x_fee_recorded_date                 IN     DATE,
    x_fee_recorded_by                   IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_plan_id                           IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_plan_discon_from                  IN     DATE    ,
    x_plan_discon_by                    IN     NUMBER  ,
    x_num_of_copies                     IN     NUMBER  ,
    x_prev_paid_plan                    IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_program_on_file                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_as_doc_fee_pmnt
      WHERE    person_id                         = x_person_id;

    L_RETURN_STATUS                VARCHAR2(10);
    L_MSG_DATA                     VARCHAR2(2000);
    L_MSG_COUNT                    NUMBER(10);
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_person_id,
        x_fee_paid_date,
        x_fee_amount,
        x_fee_recorded_date,
        x_fee_recorded_by,
        x_mode ,
        x_plan_id   ,
        x_invoice_id ,
        x_plan_discon_from  ,
        x_plan_discon_by    ,
        x_num_of_copies     ,
        x_prev_paid_plan    ,
        x_cal_type          ,
        x_ci_sequence_number,
        x_program_on_file,
        L_RETURN_STATUS ,
        L_MSG_DATA      ,
        L_MSG_COUNT
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_person_id,
      x_fee_paid_date,
      x_fee_amount,
      x_fee_recorded_date,
      x_fee_recorded_by,
      x_mode ,
      x_plan_id   ,
      x_invoice_id ,
      x_plan_discon_from  ,
      x_plan_discon_by    ,
      x_num_of_copies     ,
      x_prev_paid_plan    ,
      x_cal_type          ,
      x_ci_sequence_number,
      x_program_on_file   ,
      L_RETURN_STATUS     ,
      L_MSG_DATA          ,
      L_MSG_COUNT
    );
  END add_row;

  PROCEDURE delete_row (
    x_rowid                             IN VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : girish.jha@oracle.com
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    FND_MSG_PUB.initialize;
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
    DELETE FROM igs_as_doc_fee_pmnt
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
 -- Initialize API return status to success.
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;


  END delete_row;

  FUNCTION check_unique_calseq (p_person_id  IN NUMBER,
                                p_plan_id    IN NUMBER,
				p_cal_type   IN VARCHAR2,
				p_seq_num    IN NUMBER)
  RETURN boolean
  AS
    CURSOR c_unique (cp_person_id  IN NUMBER,
		     cp_plan_id    IN NUMBER,
		     cp_cal_type   IN VARCHAR2,
		     cp_seq_num    IN NUMBER)  IS
           SELECT 'Y'
	   FROM   igs_as_doc_fee_pmnt
	   WHERE  person_id  = cp_person_id AND
		  plan_id    = cp_plan_id  AND
		  cal_type   = cp_cal_type AND
		  ci_sequence_number  = cp_seq_num ;
     l_exists  VARCHAR2(1) := 'N';

  BEGIN
     OPEN c_unique (p_person_id,
		    p_plan_id  ,
		    p_cal_type ,
		    p_seq_num  );
     FETCH c_unique INTO l_exists;
     CLOSE c_unique;
     IF l_exists = 'Y' THEN
        RETURN (TRUE);
     ELSE
        RETURN (FALSE);
     END IF;
 END check_unique_calseq;

END Igs_As_Doc_Fee_Pmnt_Pkg;

/
