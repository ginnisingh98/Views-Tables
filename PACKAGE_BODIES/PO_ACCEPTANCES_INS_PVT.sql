--------------------------------------------------------
--  DDL for Package Body PO_ACCEPTANCES_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACCEPTANCES_INS_PVT" AS
/* $Header: POXVIACB.pls 115.4 2004/05/09 15:49:40 jmojnida noship $*/

--  Bug 2850566
--  Modified the parameters of the procedure to accomodate new columns
--  and defaulted the parameters to Null.
PROCEDURE insert_row(
                      x_rowid		          IN OUT NOCOPY  ROWID,
		      x_acceptance_id             IN OUT NOCOPY  NUMBER,
                      x_last_update_date          IN OUT NOCOPY  DATE,
                      x_last_updated_by           IN OUT NOCOPY  NUMBER,
                      x_last_update_login         IN OUT NOCOPY  NUMBER,
		      p_creation_date	          IN DATE        DEFAULT NULL,
		      p_created_by	          IN NUMBER      DEFAULT NULL,
		      p_po_header_id	          IN NUMBER      DEFAULT NULL,
		      p_po_release_id	          IN NUMBER      DEFAULT NULL,
		      p_action	                  IN VARCHAR2    DEFAULT NULL,
		      p_action_date               IN DATE        DEFAULT NULL,
		      p_employee_id               IN NUMBER      DEFAULT NULL,
	              p_revision_num              IN NUMBER      DEFAULT NULL,
		      p_accepted_flag             IN VARCHAR2    DEFAULT NULL,
		      p_acceptance_lookup_code    IN VARCHAR2    DEFAULT NULL,
		      p_note                      IN LONG        DEFAULT NULL,
                      p_accepting_party           IN VARCHAR2    DEFAULT NULL,
                      p_signature_flag            IN VARCHAR2    DEFAULT NULL,
                      p_erecord_id                IN NUMBER      DEFAULT NULL,
                      p_role                      IN VARCHAR2    DEFAULT NULL,
		      p_attribute_category        IN VARCHAR2    DEFAULT NULL,
		      p_attribute1                IN VARCHAR2    DEFAULT NULL,
		      p_attribute2                IN VARCHAR2    DEFAULT NULL,
		      p_attribute3                IN VARCHAR2    DEFAULT NULL,
		      p_attribute4                IN VARCHAR2    DEFAULT NULL,
		      p_attribute5                IN VARCHAR2    DEFAULT NULL,
		      p_attribute6                IN VARCHAR2    DEFAULT NULL,
		      p_attribute7                IN VARCHAR2    DEFAULT NULL,
		      p_attribute8                IN VARCHAR2    DEFAULT NULL,
		      p_attribute9                IN VARCHAR2    DEFAULT NULL,
		      p_attribute10               IN VARCHAR2    DEFAULT NULL,
		      p_attribute11               IN VARCHAR2    DEFAULT NULL,
		      p_attribute12               IN VARCHAR2    DEFAULT NULL,
		      p_attribute13               IN VARCHAR2    DEFAULT NULL,
		      p_attribute14               IN VARCHAR2    DEFAULT NULL,
		      p_attribute15               IN VARCHAR2    DEFAULT NULL,
		      p_request_id                IN NUMBER      DEFAULT NULL,
		      p_program_application_id    IN NUMBER      DEFAULT NULL,
		      p_program_id                IN NUMBER      DEFAULT NULL,
		      p_program_update_date       IN DATE        DEFAULT NULL,
                      p_po_line_location_id       IN NUMBER      DEFAULT NULL) IS

  l_id NUMBER;

-- Bug 2850566 RBAIRRAJ
  -- SQL What :selects the rowid from the acceptances table
  -- SQL Why  :To set the output parameter x_rowid
  -- SQL Join :Acceptance_id
  CURSOR c_rowid IS
    SELECT rowid
    FROM   PO_ACCEPTANCES
    WHERE  acceptance_id = l_id;

-- Bug 2850566 RBAIRRAJ
  -- SQL What :selects the next avaiable sequence number from PO_ACCEPTANCES_S sequence
  -- SQL Why  :To insert it as Acceptance_Id in the PO_ACCEPTANCES table
  CURSOR c_next_id IS
    SELECT PO_ACCEPTANCES_S.nextval
    FROM   SYS.DUAL;

BEGIN

  IF (x_acceptance_id IS NULL) THEN
    SELECT PO_ACCEPTANCES_S.nextval
    INTO   l_id
    FROM   SYS.DUAL;
  ELSE
    l_id := x_acceptance_id;
  END IF;

--  Bug 2850566
-- Added this If condition as iSP needs this for carry over acknowledgements
  IF (x_last_updated_by IS NULL) THEN
    x_last_updated_by   := fnd_global.user_id;
  END IF;

  x_last_update_date  := SYSDATE;
  if (x_last_update_login is null) then
     x_last_update_login := fnd_global.login_id;
  end if;

-- Bug 2850566 RBAIRRAJ
  -- SQL What :Inserts a record into PO_ACCEPTANCES table
  -- SQL Why  :This acts as a rowhandler for the PO_ACCEPTANCES table
  INSERT INTO PO_ACCEPTANCES(
	ACCEPTANCE_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	PO_HEADER_ID,
	PO_RELEASE_ID,
	ACTION,
	ACTION_DATE,
	EMPLOYEE_ID,
	REVISION_NUM,
	ACCEPTED_FLAG,
	ACCEPTANCE_LOOKUP_CODE,
	NOTE,
    ACCEPTING_PARTY,
    SIGNATURE_FLAG,
    ERECORD_ID,
    ROLE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    PO_LINE_LOCATION_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE)
  VALUES (
	l_id,
	x_last_update_date,
	x_last_updated_by,
	x_last_update_login,
	p_creation_date,
	p_created_by,
	p_po_header_id,
	p_po_release_id,
	p_action,
	p_action_date,
	p_employee_id,
	p_revision_num,
	p_accepted_flag,
	p_acceptance_lookup_code,
	p_note,
    p_accepting_party,
    p_signature_flag,
    p_erecord_id,
    p_role,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
    p_po_line_location_id,
	p_request_id,
	p_program_application_id,
	p_program_id,
	p_program_update_date);

    x_acceptance_id := l_id;

    OPEN c_rowid;
    FETCH c_rowid INTO x_rowid;
    if (c_rowid%NOTFOUND) then
      CLOSE c_rowid;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE c_rowid;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_row;

END PO_ACCEPTANCES_INS_PVT;

/
