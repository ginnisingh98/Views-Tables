--------------------------------------------------------
--  DDL for Package Body IGS_AS_ORDER_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ORDER_HDR_PKG" AS
/* $Header: IGSDI70B.pls 120.2 2006/05/26 05:16:53 shimitta ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_as_order_hdr%ROWTYPE;
  new_references igs_as_order_hdr%ROWTYPE;
  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_order_number                      IN     NUMBER      ,
    x_order_status                      IN     VARCHAR2    ,
    x_date_completed                    IN     DATE        ,
    x_person_id                         IN     NUMBER      ,
    x_addr_line_1                       IN     VARCHAR2    ,
    x_addr_line_2                       IN     VARCHAR2    ,
    x_addr_line_3                       IN     VARCHAR2    ,
    x_addr_line_4                       IN     VARCHAR2    ,
    x_city                              IN     VARCHAR2    ,
    x_state                             IN     VARCHAR2    ,
    x_province                          IN     VARCHAR2    ,
    x_county                            IN     VARCHAR2    ,
    x_country                           IN     VARCHAR2    ,
    x_postal_code                       IN     VARCHAR2    ,
    x_email_address                     IN     VARCHAR2    ,
    x_phone_country_code                IN     VARCHAR2    ,
    x_phone_area_code                   IN     VARCHAR2    ,
    x_phone_number                      IN     VARCHAR2    ,
    x_phone_extension                   IN     VARCHAR2    ,
    x_fax_country_code                  IN     VARCHAR2    ,
    x_fax_area_code                     IN     VARCHAR2    ,
    x_fax_number                        IN     VARCHAR2    ,
    x_delivery_fee                      IN     NUMBER      ,
    x_order_fee                         IN     NUMBER      ,
    x_request_type                      IN     VARCHAR2    ,
    x_submit_method                     IN     VARCHAR2    ,
    x_invoice_id                        IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER       ,
    x_order_description                 IN     VARCHAR2 ,
    x_order_placed_by                   IN     NUMBER
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_order_hdr
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.order_number                      := x_order_number;
    new_references.order_status                      := x_order_status;
    new_references.date_completed                    := x_date_completed;
    new_references.person_id                         := x_person_id;
    new_references.addr_line_1                       := x_addr_line_1;
    new_references.addr_line_2                       := x_addr_line_2;
    new_references.addr_line_3                       := x_addr_line_3;
    new_references.addr_line_4                       := x_addr_line_4;
    new_references.city                              := x_city;
    new_references.state                             := x_state;
    new_references.province                          := x_province;
    new_references.county                            := x_county;
    new_references.country                           := x_country;
    new_references.postal_code                       := x_postal_code;
    new_references.email_address                     := x_email_address;
    new_references.phone_country_code                := x_phone_country_code;
    new_references.phone_area_code                   := x_phone_area_code;
    new_references.phone_number                      := x_phone_number;
    new_references.phone_extension                   := x_phone_extension;
    new_references.fax_country_code                  := x_fax_country_code;
    new_references.fax_area_code                     := x_fax_area_code;
    new_references.fax_number                        := x_fax_number;
    new_references.delivery_fee                      := x_delivery_fee;
    new_references.order_fee                         := x_order_fee;
    new_references.request_type                      := x_request_type;
    new_references.submit_method                     := x_submit_method;
    new_references.invoice_id                        := x_invoice_id;
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
    new_references.order_description                 := x_order_description;
    new_references.order_placed_by                   := x_order_placed_by;
  END set_column_values;
  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.invoice_id = new_references.invoice_id)) OR
        ((new_references.invoice_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (((old_references.ORDER_PLACED_BY = new_references.ORDER_PLACED_BY)) OR
        ((new_references.ORDER_PLACED_BY IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.ORDER_PLACED_BY
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    igs_as_doc_details_pkg.get_fk_igs_as_order_hdr (
      old_references.order_number
    );
NULL;
--commented for testing by sjalasut
  END check_child_existance;
  FUNCTION get_pk_for_validation (
    x_order_number                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_as_order_hdr
      WHERE    order_number = x_order_number
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
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
  PROCEDURE get_fk_igs_fi_inv_int (
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_as_order_hdr
      WHERE   ((invoice_id = x_invoice_id));
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_TORD_INVI_FK');
               FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_fi_inv_int;
  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_order_number                      IN     NUMBER      ,
    x_order_status                      IN     VARCHAR2    ,
    x_date_completed                    IN     DATE        ,
    x_person_id                         IN     NUMBER      ,
    x_addr_line_1                       IN     VARCHAR2    ,
    x_addr_line_2                       IN     VARCHAR2    ,
    x_addr_line_3                       IN     VARCHAR2    ,
    x_addr_line_4                       IN     VARCHAR2    ,
    x_city                              IN     VARCHAR2    ,
    x_state                             IN     VARCHAR2    ,
    x_province                          IN     VARCHAR2    ,
    x_county                            IN     VARCHAR2    ,
    x_country                           IN     VARCHAR2    ,
    x_postal_code                       IN     VARCHAR2    ,
    x_email_address                     IN     VARCHAR2    ,
    x_phone_country_code                IN     VARCHAR2    ,
    x_phone_area_code                   IN     VARCHAR2    ,
    x_phone_number                      IN     VARCHAR2    ,
    x_phone_extension                   IN     VARCHAR2    ,
    x_fax_country_code                  IN     VARCHAR2    ,
    x_fax_area_code                     IN     VARCHAR2    ,
    x_fax_number                        IN     VARCHAR2    ,
    x_delivery_fee                      IN     NUMBER      ,
    x_order_fee                         IN     NUMBER      ,
    x_request_type                      IN     VARCHAR2    ,
    x_submit_method                     IN     VARCHAR2    ,
    x_invoice_id                        IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER       ,
    x_order_description                 IN     VARCHAR2    ,
    x_order_placed_by                   IN     NUMBER
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
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
      x_order_status,
      x_date_completed,
      x_person_id,
      x_addr_line_1,
      x_addr_line_2,
      x_addr_line_3,
      x_addr_line_4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_postal_code,
      x_email_address,
      x_phone_country_code,
      x_phone_area_code,
      x_phone_number,
      x_phone_extension,
      x_fax_country_code,
      x_fax_area_code,
      x_fax_number,
      x_delivery_fee,
      x_order_fee,
      x_request_type,
      x_submit_method,
      x_invoice_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_order_description ,
      x_order_placed_by
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.order_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
                 FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
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
             new_references.order_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
                 FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;
  END before_dml;

  PROCEDURE insert_row (
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status			OUT NOCOPY VARCHAR2,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_number                      IN OUT NOCOPY NUMBER,
    x_order_status                      IN     VARCHAR2,
    x_date_completed                    IN     DATE,
    x_person_id                         IN     NUMBER,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_phone_country_code                IN     VARCHAR2,
    x_phone_area_code                   IN     VARCHAR2,
    x_phone_number                      IN     VARCHAR2,
    x_phone_extension                   IN     VARCHAR2,
    x_fax_country_code                  IN     VARCHAR2,
    x_fax_area_code                     IN     VARCHAR2,
    x_fax_number                        IN     VARCHAR2,
    x_delivery_fee                      IN     NUMBER,
    x_order_fee                         IN     NUMBER,
    x_request_type                      IN     VARCHAR2,
    x_submit_method                     IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_order_description                 IN     VARCHAR2 ,
    x_order_placed_by                   IN     NUMBER
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     igs_as_order_hdr
      WHERE    order_number                      = x_order_number;
    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
  BEGIN

-- Initailize the error count, error data etc.
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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;

    END IF;
-- adding this if codition to avoid Lock row problem from self service pages
   IF 	x_order_number IS NULL THEN
    SELECT    igs_as_order_hdr_s.NEXTVAL
    INTO      x_order_number
    FROM      dual;
   END IF;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_order_number                      => x_order_number,
      x_order_status                      => x_order_status,
      x_date_completed                    => x_date_completed,
      x_person_id                         => x_person_id,
      x_addr_line_1                       => x_addr_line_1,
      x_addr_line_2                       => x_addr_line_2,
      x_addr_line_3                       => x_addr_line_3,
      x_addr_line_4                       => x_addr_line_4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_postal_code                       => x_postal_code,
      x_email_address                     => x_email_address,
      x_phone_country_code                => x_phone_country_code,
      x_phone_area_code                   => x_phone_area_code,
      x_phone_number                      => x_phone_number,
      x_phone_extension                   => x_phone_extension,
      x_fax_country_code                  => x_fax_country_code,
      x_fax_area_code                     => x_fax_area_code,
      x_fax_number                        => x_fax_number,
      x_delivery_fee                      => x_delivery_fee,
      x_order_fee                         => x_order_fee,
      x_request_type                      => x_request_type,
      x_submit_method                     => x_submit_method,
      x_invoice_id                        => x_invoice_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_order_description                 => x_order_description,
      x_order_placed_by                   => x_order_placed_by
    );
    INSERT INTO igs_as_order_hdr (
      order_number,
      order_status,
      date_completed,
      person_id,
      addr_line_1,
      addr_line_2,
      addr_line_3,
      addr_line_4,
      city,
      state,
      province,
      county,
      country,
      postal_code,
      email_address,
      phone_country_code,
      phone_area_code,
      phone_number,
      phone_extension,
      fax_country_code,
      fax_area_code,
      fax_number,
      delivery_fee,
      order_fee,
      request_type,
      submit_method,
      invoice_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      order_description   ,
      order_placed_by

    ) VALUES (
      new_references.order_number,
      new_references.order_status,
      new_references.date_completed,
      new_references.person_id,
      new_references.addr_line_1,
      new_references.addr_line_2,
      new_references.addr_line_3,
      new_references.addr_line_4,
      new_references.city,
      new_references.state,
      new_references.province,
      new_references.county,
      new_references.country,
      new_references.postal_code,
      new_references.email_address,
      new_references.phone_country_code,
      new_references.phone_area_code,
      new_references.phone_number,
      new_references.phone_extension,
      new_references.fax_country_code,
      new_references.fax_area_code,
      new_references.fax_number,
      new_references.delivery_fee,
      new_references.order_fee,
      new_references.request_type,
      new_references.submit_method,
      new_references.invoice_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.order_description       ,
      new_references.order_placed_by

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
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status			OUT NOCOPY VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_order_status                      IN     VARCHAR2,
    x_date_completed                    IN     DATE,
    x_person_id                         IN     NUMBER,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_phone_country_code                IN     VARCHAR2,
    x_phone_area_code                   IN     VARCHAR2,
    x_phone_number                      IN     VARCHAR2,
    x_phone_extension                   IN     VARCHAR2,
    x_fax_country_code                  IN     VARCHAR2,
    x_fax_area_code                     IN     VARCHAR2,
    x_fax_number                        IN     VARCHAR2,
    x_delivery_fee                      IN     NUMBER,
    x_order_fee                         IN     NUMBER,
    x_request_type                      IN     VARCHAR2,
    x_submit_method                     IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_order_description                 IN     VARCHAR2 ,
    x_order_placed_by                   IN     NUMBER

  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        order_status,
        date_completed,
        person_id,
        addr_line_1,
        addr_line_2,
        addr_line_3,
        addr_line_4,
        city,
        state,
        province,
        county,
        country,
        postal_code,
        email_address,
        phone_country_code,
        phone_area_code,
        phone_number,
        phone_extension,
        fax_country_code,
        fax_area_code,
        fax_number,
        delivery_fee,
        order_fee,
        request_type,
        submit_method,
        invoice_id,
        order_description                 ,
        order_placed_by

      FROM  igs_as_order_hdr
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN

  -- Initailize the error count, error data etc.
  FND_MSG_PUB.initialize;

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
    CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

     END IF;
    CLOSE c1;
    IF (
        ((tlinfo.order_status = x_order_status) OR ((tlinfo.order_status IS NULL) AND (X_order_status IS NULL)))
        AND ((tlinfo.date_completed = x_date_completed) OR ((tlinfo.date_completed IS NULL) AND (X_date_completed IS NULL)))
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.addr_line_1 = x_addr_line_1)
        AND ((tlinfo.addr_line_2 = x_addr_line_2) OR ((tlinfo.addr_line_2 IS NULL) AND (X_addr_line_2 IS NULL)))
        AND ((tlinfo.addr_line_3 = x_addr_line_3) OR ((tlinfo.addr_line_3 IS NULL) AND (X_addr_line_3 IS NULL)))
        AND ((tlinfo.addr_line_4 = x_addr_line_4) OR ((tlinfo.addr_line_4 IS NULL) AND (X_addr_line_4 IS NULL)))
        AND ((tlinfo.city = x_city) OR ((tlinfo.city IS NULL) AND (X_city IS NULL)))
        AND ((tlinfo.state = x_state) OR ((tlinfo.state IS NULL) AND (X_state IS NULL)))
        AND ((tlinfo.province = x_province) OR ((tlinfo.province IS NULL) AND (X_province IS NULL)))
        AND ((tlinfo.county = x_county) OR ((tlinfo.county IS NULL) AND (X_county IS NULL)))
        AND (tlinfo.country = x_country)
        AND ((tlinfo.postal_code = x_postal_code) OR ((tlinfo.postal_code IS NULL) AND (X_postal_code IS NULL)))
        AND ((tlinfo.email_address = x_email_address) OR ((tlinfo.email_address IS NULL) AND (X_email_address IS NULL)))
        AND ((tlinfo.phone_country_code = x_phone_country_code) OR ((tlinfo.phone_country_code IS NULL) AND (X_phone_country_code IS NULL)))
        AND ((tlinfo.phone_area_code = x_phone_area_code) OR ((tlinfo.phone_area_code IS NULL) AND (X_phone_area_code IS NULL)))
        AND ((tlinfo.phone_number = x_phone_number) OR ((tlinfo.phone_number IS NULL) AND (X_phone_number IS NULL)))
        AND ((tlinfo.phone_extension = x_phone_extension) OR ((tlinfo.phone_extension IS NULL) AND (X_phone_extension IS NULL)))
        AND ((tlinfo.fax_country_code = x_fax_country_code) OR ((tlinfo.fax_country_code IS NULL) AND (X_fax_country_code IS NULL)))
        AND ((tlinfo.fax_area_code = x_fax_area_code) OR ((tlinfo.fax_area_code IS NULL) AND (X_fax_area_code IS NULL)))
        AND ((tlinfo.fax_number = x_fax_number) OR ((tlinfo.fax_number IS NULL) AND (X_fax_number IS NULL)))
        AND ((tlinfo.delivery_fee = x_delivery_fee) OR ((tlinfo.delivery_fee IS NULL) AND (X_delivery_fee IS NULL)))
        AND ((tlinfo.order_fee = x_order_fee) OR ((tlinfo.order_fee IS NULL) AND (X_order_fee IS NULL)))
        AND ((tlinfo.request_type = x_request_type) OR ((tlinfo.request_type IS NULL) AND (X_request_type IS NULL)))
        AND ((tlinfo.submit_method = x_submit_method) OR ((tlinfo.submit_method IS NULL) AND (X_submit_method IS NULL)))
        AND ((tlinfo.invoice_id = x_invoice_id) OR ((tlinfo.invoice_id IS NULL) AND (X_invoice_id IS NULL)))
        AND ((tlinfo.order_description = x_order_description) OR ((tlinfo.order_description IS NULL) AND (x_order_description IS NULL)))
        AND ((tlinfo.order_placed_by   = x_order_placed_by) OR ((tlinfo.order_placed_by IS NULL) AND (x_order_placed_by IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
               FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    RETURN;
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
             FND_MESSAGE.SET_TOKEN('NAME','Lock_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
 RETURN;

  END lock_row;

  PROCEDURE update_row (
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status			OUT NOCOPY VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_order_number                      IN     NUMBER,
    x_order_status                      IN     VARCHAR2,
    x_date_completed                    IN     DATE,
    x_person_id                         IN     NUMBER,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_phone_country_code                IN     VARCHAR2,
    x_phone_area_code                   IN     VARCHAR2,
    x_phone_number                      IN     VARCHAR2,
    x_phone_extension                   IN     VARCHAR2,
    x_fax_country_code                  IN     VARCHAR2,
    x_fax_area_code                     IN     VARCHAR2,
    x_fax_number                        IN     VARCHAR2,
    x_delivery_fee                      IN     NUMBER,
    x_order_fee                         IN     NUMBER,
    x_request_type                      IN     VARCHAR2,
    x_submit_method                     IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_order_description                 IN     VARCHAR2 ,
    x_order_placed_by                   IN     NUMBER,
    p_init_msg_list                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
  BEGIN
  -- Initailize the error count, error data etc.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;
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
               FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_order_number                      => x_order_number,
      x_order_status                      => x_order_status,
      x_date_completed                    => x_date_completed,
      x_person_id                         => x_person_id,
      x_addr_line_1                       => x_addr_line_1,
      x_addr_line_2                       => x_addr_line_2,
      x_addr_line_3                       => x_addr_line_3,
      x_addr_line_4                       => x_addr_line_4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_postal_code                       => x_postal_code,
      x_email_address                     => x_email_address,
      x_phone_country_code                => x_phone_country_code,
      x_phone_area_code                   => x_phone_area_code,
      x_phone_number                      => x_phone_number,
      x_phone_extension                   => x_phone_extension,
      x_fax_country_code                  => x_fax_country_code,
      x_fax_area_code                     => x_fax_area_code,
      x_fax_number                        => x_fax_number,
      x_delivery_fee                      => x_delivery_fee,
      x_order_fee                         => x_order_fee,
      x_request_type                      => x_request_type,
      x_submit_method                     => x_submit_method,
      x_invoice_id                        => x_invoice_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_order_description                 => x_order_description,
      x_order_placed_by                   => x_order_placed_by

    );
    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;
    UPDATE igs_as_order_hdr
      SET
        order_status                      = new_references.order_status,
        date_completed                    = new_references.date_completed,
        person_id                         = new_references.person_id,
        addr_line_1                       = new_references.addr_line_1,
        addr_line_2                       = new_references.addr_line_2,
        addr_line_3                       = new_references.addr_line_3,
        addr_line_4                       = new_references.addr_line_4,
        city                              = new_references.city,
        state                             = new_references.state,
        province                          = new_references.province,
        county                            = new_references.county,
        country                           = new_references.country,
        postal_code                       = new_references.postal_code,
        email_address                     = new_references.email_address,
        phone_country_code                = new_references.phone_country_code,
        phone_area_code                   = new_references.phone_area_code,
        phone_number                      = new_references.phone_number,
        phone_extension                   = new_references.phone_extension,
        fax_country_code                  = new_references.fax_country_code,
        fax_area_code                     = new_references.fax_area_code,
        fax_number                        = new_references.fax_number,
        delivery_fee                      = new_references.delivery_fee,
        order_fee                         = new_references.order_fee,
        request_type                      = new_references.request_type,
        submit_method                     = new_references.submit_method,
        invoice_id                        = new_references.invoice_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
        order_description                 = x_order_description,
        order_placed_by                   = x_order_placed_by

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
             FND_MESSAGE.SET_TOKEN('NAME','Update_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
 RETURN;

  END update_row;

  PROCEDURE add_row (
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status			OUT NOCOPY VARCHAR2,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_number                      IN OUT NOCOPY NUMBER,
    x_order_status                      IN     VARCHAR2,
    x_date_completed                    IN     DATE,
    x_person_id                         IN     NUMBER,
    x_addr_line_1                       IN     VARCHAR2,
    x_addr_line_2                       IN     VARCHAR2,
    x_addr_line_3                       IN     VARCHAR2,
    x_addr_line_4                       IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postal_code                       IN     VARCHAR2,
    x_email_address                     IN     VARCHAR2,
    x_phone_country_code                IN     VARCHAR2,
    x_phone_area_code                   IN     VARCHAR2,
    x_phone_number                      IN     VARCHAR2,
    x_phone_extension                   IN     VARCHAR2,
    x_fax_country_code                  IN     VARCHAR2,
    x_fax_area_code                     IN     VARCHAR2,
    x_fax_number                        IN     VARCHAR2,
    x_delivery_fee                      IN     NUMBER,
    x_order_fee                         IN     NUMBER,
    x_request_type                      IN     VARCHAR2,
    x_submit_method                     IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_order_description                 IN     VARCHAR2 ,
    x_order_placed_by                   IN     NUMBER
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_as_order_hdr
      WHERE    order_number                      = x_order_number;
  BEGIN

  -- Initailize the error count, error data etc.
  FND_MSG_PUB.initialize;

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
	    x_msg_count,
        x_msg_data,
        x_return_status,
        x_rowid,
        x_order_number,
        x_order_status,
        x_date_completed,
        x_person_id,
        x_addr_line_1,
        x_addr_line_2,
        x_addr_line_3,
        x_addr_line_4,
        x_city,
        x_state,
        x_province,
        x_county,
        x_country,
        x_postal_code,
        x_email_address,
        x_phone_country_code,
        x_phone_area_code,
        x_phone_number,
        x_phone_extension,
        x_fax_country_code,
        x_fax_area_code,
        x_fax_number,
        x_delivery_fee,
        x_order_fee,
        x_request_type,
        x_submit_method,
        x_invoice_id,
        x_mode ,
        x_order_description                 ,
        x_order_placed_by
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_msg_count,
      x_msg_data,
      x_return_status,
      x_rowid,
      x_order_number,
      x_order_status,
      x_date_completed,
      x_person_id,
      x_addr_line_1,
      x_addr_line_2,
      x_addr_line_3,
      x_addr_line_4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_postal_code,
      x_email_address,
      x_phone_country_code,
      x_phone_area_code,
      x_phone_number,
      x_phone_extension,
      x_fax_country_code,
      x_fax_area_code,
      x_fax_number,
      x_delivery_fee,
      x_order_fee,
      x_request_type,
      x_submit_method,
      x_invoice_id,
      x_mode ,
      x_order_description                 ,
      x_order_placed_by

    );

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
             FND_MESSAGE.SET_TOKEN('NAME','Add_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
 RETURN;
  END add_row;


  PROCEDURE delete_row (
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2,
    x_return_status			OUT NOCOPY VARCHAR2,
    x_rowid				IN VARCHAR2
  ) AS
  /*
  ||  Created By : sreedhar.jalasutram@oracle.com
  ||  Created On : 25-JAN-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shimitta          5/25/2006        Bug 5076185. OD <=> SF integration
  ||  (reverse chronological order - newest change first)
  */
  l_waiver_amount   NUMBER;
  l_n_invoice_id    NUMBER;
  p_return_status   VARCHAR2 (1);
  CURSOR c_inv
  IS
        SELECT inv.*
          FROM igs_fi_inv_int_v inv
         WHERE inv.invoice_id = old_references.invoice_id;
  rec_c_inv       c_inv%ROWTYPE;
  BEGIN

  -- Initailize the error count, error data etc.
  FND_MSG_PUB.initialize;

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
    IF old_references.invoice_id IS NOT NULL THEN
             OPEN  c_inv;
             FETCH c_inv INTO rec_c_inv;
             CLOSE c_inv;
             IGS_FI_SS_CHARGES_API_PVT.create_charge(
                                p_api_version                   => 2.0,
                                p_init_msg_list                 => 'T',
                                p_commit                        => 'F',
                                p_person_id                     => rec_c_inv.person_id,
                                p_fee_type                      => rec_c_inv.fee_type,
                                p_fee_cat                       => rec_c_inv.fee_cat,
                                p_fee_cal_type                  => rec_c_inv.fee_cal_type,
                                p_fee_ci_sequence_number        => rec_c_inv.fee_ci_sequence_number,
                                p_course_cd                     => NULL,
                                p_attendance_type               => NULL,
                                p_attendance_mode               => NULL,
                                p_invoice_amount                => - (rec_c_inv.invoice_amount),
                                p_invoice_creation_date         => rec_c_inv.invoice_creation_date,
                                p_invoice_desc                  => rec_c_inv.invoice_desc,
                                p_transaction_type              => rec_c_inv.transaction_type,
                                p_currency_cd                   => rec_c_inv.currency_cd,
                                p_exchange_rate                 => rec_c_inv.exchange_rate,
                                p_effective_date                => rec_c_inv.effective_date,
                                p_waiver_flag                   => 'Y',
                                p_waiver_reason                 => 'ORDER_DOCUMENT',
                                p_source_transaction_id         => rec_c_inv.invoice_id,
                                p_invoice_id                    => l_n_invoice_id,
                                x_return_status                 => p_return_status,
                                x_msg_count                     => x_msg_count,
                                x_msg_data                      => x_msg_data,
                                x_waiver_amount                 => l_waiver_amount
                               ) ;
            IF  (p_return_status <> fnd_api.g_ret_sts_success) THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
    END IF;
    DELETE FROM igs_as_order_hdr
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
             FND_MESSAGE.SET_TOKEN('NAME','Delete_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
 RETURN;
  END delete_row;
END Igs_As_Order_Hdr_Pkg;

/
