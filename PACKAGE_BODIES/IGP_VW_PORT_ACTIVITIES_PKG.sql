--------------------------------------------------------
--  DDL for Package Body IGP_VW_PORT_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_VW_PORT_ACTIVITIES_PKG" AS
/* $Header: IGSPVWCB.pls 120.0 2005/06/01 15:02:16 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGP_VW_PORT_ACTIVITIES%ROWTYPE;
  new_references IGP_VW_PORT_ACTIVITIES%ROWTYPE;

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGP_VW_PORT_ACTIVITIES_PKG';
  apps_exception  EXCEPTION ;
  PRAGMA EXCEPTION_INIT(apps_exception, -20001);

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_activity_id                       IN     NUMBER,
    x_portfolio_id                      IN     NUMBER,
    x_org_party_id                      IN     NUMBER,
    x_access_date                       IN     DATE,
    x_note                              IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_pincode                           IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 04-FEB-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGP_VW_PORT_ACTIVITIES
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
    new_references.activity_id                       := x_activity_id;
    new_references.portfolio_id                      := x_portfolio_id;
    new_references.org_party_id                      := x_org_party_id;
    new_references.access_date                       := x_access_date;
    new_references.note                              := x_note;
    new_references.object_version_number             := x_object_version_number;
    new_references.pincode                           := x_pincode;
    new_references.party_id                          := x_party_id;
    new_references.ACCESS_TYPE_CODE                  := x_ACCESS_TYPE_CODE;

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
    x_activity_id                       IN     NUMBER,
    x_portfolio_id                      IN     NUMBER,
    x_org_party_id                      IN     NUMBER,
    x_access_date                       IN     DATE,
    x_note                              IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_pincode                           IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 04-FEB-2004
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
      x_activity_id,
      x_portfolio_id,
      x_org_party_id,
      x_access_date,
      x_note,
      x_object_version_number,
      x_pincode,
      x_party_id,
      x_ACCESS_TYPE_CODE,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

  END before_dml;


 PROCEDURE Insert_Row_Pub(
      x_msg_count			  OUT NOCOPY NUMBER,
      x_msg_data			  OUT NOCOPY VARCHAR2,
      x_return_status                     OUT NOCOPY  VARCHAR2,
      x_rowid				  IN OUT NOCOPY VARCHAR2,
      x_activity_id			  IN OUT NOCOPY NUMBER,
      x_portfolio_id                      IN     NUMBER,
      x_access_date                       IN     DATE,
      x_note                              IN     VARCHAR2,
      x_object_version_number             IN     NUMBER,
      x_pincode                           IN     VARCHAR2,
      x_party_id                          IN     NUMBER,
      x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
      x_mode                              IN     VARCHAR2
  ) AS

  CURSOR c_org_party_id (cp_party_id NUMBER,cp_portfolio_id NUMBER) IS
  SELECT org_party_id FROM IGP_US_REG_VIEWERS
  WHERE party_id = cp_party_id AND portfolio_id = cp_portfolio_id;

  l_api_name           CONSTANT VARCHAR2(30)  := 'Insert_Row_Pub';
  l_org_party_id VARCHAR2(30);
  BEGIN

      SAVEPOINT     Insert_comments_Main;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      FND_MSG_PUB.initialize;

      IF x_pincode IS NULL THEN
        OPEN c_org_party_id(x_party_id,x_portfolio_id);
	FETCH c_org_party_id INTO l_org_party_id;
	IF c_org_party_id%NOTFOUND THEN
	  insert_row(
	     x_rowid			=>	 x_rowid,
	     x_activity_id              =>	 x_activity_id,
	     x_portfolio_id		=>	 x_portfolio_id,
	     x_org_party_id		=>	 NULL,
	     x_access_date		=>	 SYSDATE,
	     x_note			=>	 x_note,
	     x_object_version_number	=>	 x_object_version_number,
	     x_pincode			=>	 x_pincode,
	     x_party_id			=>	 x_party_id,
      	     x_ACCESS_TYPE_CODE		=>	 x_ACCESS_TYPE_CODE,
	     x_mode			=>	 x_mode
          );
	--  FOR R_ORG_PARTY_ID IN c_org_party_id(x_party_id,x_portfolio_id)
	ELSE
        LOOP
          BEGIN
	  SAVEPOINT     Insert_comments;

	  insert_row(
	     x_rowid			=>	 x_rowid,
	     x_activity_id              =>	 x_activity_id,
	     x_portfolio_id		=>	 x_portfolio_id,
	     x_org_party_id		=>	 l_org_party_id,
	     x_access_date		=>	 SYSDATE,
	     x_note			=>	 x_note,
	     x_object_version_number	=>	 x_object_version_number,
	     x_pincode			=>	 x_pincode,
	     x_party_id			=>	 x_party_id,
      	     x_ACCESS_TYPE_CODE		=>	 x_ACCESS_TYPE_CODE,
	     x_mode			=>	 x_mode
          );
          EXCEPTION
            WHEN  FND_API.G_EXC_ERROR THEN
               ROLLBACK TO Insert_comments;
                x_return_status := FND_API.G_RET_STS_ERROR;
	  END;
	  FETCH c_org_party_id INTO l_org_party_id;
	  EXIT WHEN c_org_party_id%NOTFOUND;
        END LOOP;
	END IF;
        CLOSE c_org_party_id;
      ELSE
        insert_row(
	     x_rowid			=>	 x_rowid,
	     x_activity_id              =>	 x_activity_id,
	     x_portfolio_id		=>	 x_portfolio_id,
	     x_org_party_id		=>	 NULL,
	     x_access_date		=>	 SYSDATE,
	     x_note			=>	 x_note,
	     x_object_version_number	=>	 x_object_version_number,
	     x_pincode			=>	 x_pincode,
	     x_party_id			=>	 x_party_id,
      	     x_ACCESS_TYPE_CODE		=>	 x_ACCESS_TYPE_CODE,
	     x_mode			=>	 x_mode
          );
      END IF;
        -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
         p_count  => x_msg_count ,
         p_data   => x_msg_data
      );

  EXCEPTION
    WHEN apps_exception THEN
       ROLLBACK TO Insert_comments_Main;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                  p_data  => x_msg_data );
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Insert_comments_Main;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                  p_data  => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Insert_comments_Main;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                   p_data  => x_msg_data );
    WHEN OTHERS THEN
       ROLLBACK TO Insert_comments_Main;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                   p_data  => x_msg_data );

  END Insert_Row_Pub;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_activity_id                       IN OUT NOCOPY NUMBER,
    x_portfolio_id                      IN     NUMBER,
    x_org_party_id                      IN     NUMBER,
    x_access_date                       IN     DATE,
    x_note                              IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_pincode                          IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_ACCESS_TYPE_CODE                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 04-FEB-2004
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
      fnd_message.set_token ('ROUTINE', 'IGP_VW_PORT_ACTIVITIES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_activity_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_activity_id                       => x_activity_id,
      x_portfolio_id                      => x_portfolio_id,
      x_org_party_id                      => x_org_party_id,
      x_access_date                       => x_access_date,
      x_note                              => x_note,
      x_object_version_number             => x_object_version_number,
      x_pincode                           => x_pincode,
      x_party_id                          => x_party_id,
      x_ACCESS_TYPE_CODE                  => x_ACCESS_TYPE_CODE,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO IGP_VW_PORT_ACTIVITIES (
      activity_id,
      portfolio_id,
      org_party_id,
      access_date,
      note,
      object_version_number,
      pincode,
      party_id,
      ACCESS_TYPE_CODE,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      IGP_VW_PORT_ACTIVITIES_S.NEXTVAL,
      new_references.portfolio_id,
      new_references.org_party_id,
      new_references.access_date,
      new_references.note,
      new_references.object_version_number,
      new_references.pincode,
      new_references.party_id,
      new_references.ACCESS_TYPE_CODE,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, activity_id INTO x_rowid, x_activity_id;

  END insert_row;

END IGP_VW_PORT_ACTIVITIES_pkg;

/
