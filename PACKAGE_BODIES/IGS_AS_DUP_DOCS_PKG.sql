--------------------------------------------------------
--  DDL for Package Body IGS_AS_DUP_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_DUP_DOCS_PKG" AS
/* $Header: IGSDI76B.pls 115.2 2002/11/28 23:30:49 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_dup_docs%ROWTYPE;
  new_references igs_as_dup_docs%ROWTYPE;

  PROCEDURE process_duplicate_documents
  (
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  BEGIN
    --
    -- Create an interface item with the item details
    --
    igs_as_documents_api.update_document_details (
        p_order_number   => x_order_number,
        p_item_number    => x_item_number,
        p_init_msg_list  => fnd_api.g_true,
        p_return_status  => x_return_status,
        p_msg_count      => x_msg_count,
        p_msg_data       => x_msg_data
    );
    --
    -- Check if there was an error during the process of updating the Order and
    -- Details records, and creating an interface item
    --
    IF (NVL (x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) THEN
      RETURN;
    END IF;
    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.SET_TOKEN('NAME','process_duplicate_documents : '||SQLERRM);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  END process_duplicate_documents;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_dup_docs
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.order_number                      := x_order_number;
    new_references.item_number                       := x_item_number;
    new_references.requested_by                      := x_requested_by;
    new_references.requested_date                    := x_requested_date;
    new_references.fulfilled_by                      := x_fulfilled_by;
    new_references.fulfilled_date                    := x_fulfilled_date;

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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
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
      x_order_number,
      x_item_number,
      x_requested_by,
      x_requested_date,
      x_fulfilled_by,
      x_fulfilled_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_order_number                      => x_order_number,
      x_item_number                       => x_item_number,
      x_requested_by                      => x_requested_by,
      x_requested_date                    => x_requested_date,
      x_fulfilled_by                      => x_fulfilled_by,
      x_fulfilled_date                    => x_fulfilled_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_as_dup_docs (
      order_number,
      item_number,
      requested_by,
      requested_date,
      fulfilled_by,
      fulfilled_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.order_number,
      new_references.item_number,
      new_references.requested_by,
      new_references.requested_date,
      new_references.fulfilled_by,
      new_references.fulfilled_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

    --
    -- Update the order and item status to In Process and create an Interface record
    process_duplicate_documents
    (
      x_order_number                      => new_references.order_number,
      x_item_number                       => new_references.item_number,
      x_return_status                     => x_return_status,
      x_msg_data                          => x_msg_data,
      x_msg_count                         => x_msg_count
    );

    IF (NVL (x_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success) THEN
      RETURN;
    END IF;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  END insert_row;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        order_number,
        item_number,
        requested_by,
        requested_date,
        fulfilled_by,
        fulfilled_date
      FROM  igs_as_dup_docs
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.order_number = x_order_number)
        AND (tlinfo.item_number = x_item_number)
        AND (tlinfo.requested_by = x_requested_by)
        AND (tlinfo.requested_date = x_requested_date)
        AND ((tlinfo.fulfilled_by = x_fulfilled_by) OR ((tlinfo.fulfilled_by IS NULL) AND (X_fulfilled_by IS NULL)))
        AND ((tlinfo.fulfilled_date = x_fulfilled_date) OR ((tlinfo.fulfilled_date IS NULL) AND (X_fulfilled_date IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.SET_TOKEN('NAME','Lock_Row : '||SQLERRM);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_requested_by                      IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_fulfilled_by                      IN     NUMBER,
    x_fulfilled_date                    IN     DATE,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_order_number                      => x_order_number,
      x_item_number                       => x_item_number,
      x_requested_by                      => x_requested_by,
      x_requested_date                    => x_requested_date,
      x_fulfilled_by                      => x_fulfilled_by,
      x_fulfilled_date                    => x_fulfilled_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_as_dup_docs
      SET
        order_number                      = new_references.order_number,
        item_number                       = new_references.item_number,
        requested_by                      = new_references.requested_by,
        requested_date                    = new_references.requested_date,
        fulfilled_by                      = new_references.fulfilled_by,
        fulfilled_date                    = new_references.fulfilled_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-OCT-2002
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

    DELETE FROM igs_as_dup_docs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END igs_as_dup_docs_pkg;

/
