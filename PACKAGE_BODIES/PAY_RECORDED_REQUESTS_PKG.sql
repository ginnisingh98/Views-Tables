--------------------------------------------------------
--  DDL for Package Body PAY_RECORDED_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RECORDED_REQUESTS_PKG" AS
/* $Header: pyrecreq.pkb 115.5 2004/08/05 08:25:34 jford noship $ */

g_package  varchar2(33) := '  pay_recorded_requests_pkg.';  -- Global package name
--

-- ----------------------------------------------------------------------------
-- Name: insert_recorded_request
--
-- Description:
--   This procedure controls the actual dml insert logic.
--   Other than validating teh process against a lookup, no further validation
--   occurs.  Simply an insert in to the table occurs.
--
-- Prerequisites:
--   This is an internal private procedure which is called by the other
--   maintenance procedures held within this package.
--
-- In Parameters:
--   All column values to be inserted in to the table.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   Lookup failure is handled explicitly, all other errors are propogated
--   using usual SQL behaviour.
-- ----------------------------------------------------------------------------


procedure insert_recorded_request( p_process in varchar2,
                    p_recorded_date          in date,
                    p_attribute1         in varchar2 ,
                    p_attribute2         in varchar2 ,
                    p_attribute3         in varchar2 ,
                    p_attribute4         in varchar2 ,
                    p_attribute5         in varchar2 ,
                    p_attribute6         in varchar2 ,
                    p_attribute7         in varchar2 ,
                    p_attribute8         in varchar2 ,
                    p_attribute9         in varchar2 ,
                    p_attribute10        in varchar2 ,
                    p_attribute11        in varchar2 ,
                    p_attribute12        in varchar2 ,
                    p_attribute13        in varchar2 ,
                    p_attribute14        in varchar2 ,
                    p_attribute15        in varchar2 ,
                    p_attribute16        in varchar2 ,
                    p_attribute17        in varchar2 ,
                    p_attribute18        in varchar2 ,
                    p_attribute19        in varchar2 ,
                    p_attribute20        in varchar2 )
as
  l_proc  varchar2(72) := g_package||'insert_recorded_request';
--
BEGIN
  --hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Validate against hr_lookups,
  -- to check request/process has been set up to use mechanism.
  --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => sysdate
      ,p_lookup_type    => 'PAY_RECORDED_REQUESTS'
      ,p_lookup_code    => p_process
      )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 20);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'PAY_RECORDED_REQUESTS');
      fnd_message.set_token('VALUE', p_process);
     fnd_message.raise_error;
    end if;

  INSERT INTO pay_recorded_requests(recorded_request_id,
                    recorded_date,
                    attribute_category,
                    attribute1 ,
                    attribute2 ,
                    attribute3 ,
                    attribute4 ,
                    attribute5 ,
                    attribute6 ,
                    attribute7 ,
                    attribute8 ,
                    attribute9 ,
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
                    attribute20  )
    VALUES     (pay_recorded_requests_s.NEXTVAL,
                    p_recorded_date,
                    p_process,
                    p_attribute1 ,
                    p_attribute2 ,
                    p_attribute3 ,
                    p_attribute4 ,
                    p_attribute5 ,
                    p_attribute6 ,
                    p_attribute7 ,
                    p_attribute8 ,
                    p_attribute9 ,
                    p_attribute10,
                    p_attribute11,
                    p_attribute12,
                    p_attribute13,
                    p_attribute14,
                    p_attribute15,
                    p_attribute16,
                    p_attribute17,
                    p_attribute18,
                    p_attribute19,
                    p_attribute20  );
  --hr_utility.set_location(' Leaving:'||l_proc, 900);

END insert_recorded_request;

-- ----------------------------------------------------------------------------
-- Name: get_recorded_date
--
-- Description:
--   This procedure returns the date that has been recorded against the request
--   identified by the attributes.
--   If no record exists (no row in table) then a row is created and the default
--   hr_api.g_sot is returned.
--
-- Prerequisites:
--   This is a public procedure which allows code as part of the request to access
--   a single recorded date which may be required for future processing.
--
-- In Parameters:
--   All column values that identify the row explicitly, eg request type and parameter
--   values.  The only out parameter is the current date stored against this row.
--
-- Post Success:
--   The specified row's recorded date will be returned.
--
-- Post Failure:
--   Errors are propogated using usual SQL behaviour.
-- ----------------------------------------------------------------------------

procedure get_recorded_date( p_process in varchar2,
                    p_recorded_date out nocopy date ,
                    p_attribute1         in varchar2 ,
                    p_attribute2         in varchar2 ,
                    p_attribute3         in varchar2 ,
                    p_attribute4         in varchar2 ,
                    p_attribute5         in varchar2 ,
                    p_attribute6         in varchar2 ,
                    p_attribute7         in varchar2 ,
                    p_attribute8         in varchar2 ,
                    p_attribute9         in varchar2 ,
                    p_attribute10        in varchar2 ,
                    p_attribute11        in varchar2 ,
                    p_attribute12        in varchar2 ,
                    p_attribute13        in varchar2 ,
                    p_attribute14        in varchar2 ,
                    p_attribute15        in varchar2 ,
                    p_attribute16        in varchar2 ,
                    p_attribute17        in varchar2 ,
                    p_attribute18        in varchar2 ,
                    p_attribute19        in varchar2 ,
                    p_attribute20        in varchar2 )
as

  cursor csr_process_run  IS

    SELECT recorded_date
    FROM   pay_recorded_requests
    WHERE  attribute_category = p_process
    and    attribute1         = p_attribute1
    and    nvl(attribute2,'X')         = nvl(p_attribute2,'X')
    and    nvl(attribute3,'X')         = nvl(p_attribute3,'X')
    and    nvl(attribute4,'X')         = nvl(p_attribute4,'X')
    and    nvl(attribute5,'X')         = nvl(p_attribute5,'X')
    and    nvl(attribute6,'X')         = nvl(p_attribute6,'X')
    and    nvl(attribute7,'X')         = nvl(p_attribute7,'X')
    and    nvl(attribute8,'X')         = nvl(p_attribute8,'X')
    and    nvl(attribute9,'X')         = nvl(p_attribute9,'X')
    and    nvl(attribute10,'X')        = nvl(p_attribute10,'X')
    and    nvl(attribute11,'X')        = nvl(p_attribute11,'X')
    and    nvl(attribute12,'X')        = nvl(p_attribute12,'X')
    and    nvl(attribute13,'X')        = nvl(p_attribute13,'X')
    and    nvl(attribute14,'X')        = nvl(p_attribute14,'X')
    and    nvl(attribute15,'X')        = nvl(p_attribute15,'X')
    and    nvl(attribute16,'X')        = nvl(p_attribute16,'X')
    and    nvl(attribute17,'X')        = nvl(p_attribute17,'X')
    and    nvl(attribute18,'X')        = nvl(p_attribute18,'X')
    and    nvl(attribute19,'X')        = nvl(p_attribute19,'X')
    and    nvl(attribute20,'X')        = nvl(p_attribute20,'X');


  l_recorded_date    DATE;
  l_proc  varchar2(72) := g_package||'get_recorded_date';
--
BEGIN
  --hr_utility.set_location('Entering:'||l_proc, 10);

  --See if we've already got an appropriate row
  open csr_process_run;
  fetch csr_process_run into l_recorded_date;

  if (csr_process_run%NOTFOUND) then
     --no row exists so create one
     l_recorded_date := hr_api.g_sot;
     insert_recorded_request( p_process ,
                    l_recorded_date,
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
                    p_attribute16,
                    p_attribute17,
                    p_attribute18,
                    p_attribute19 ,
                    p_attribute20);
  end if;

  close csr_process_run;

  p_recorded_date := l_recorded_date;
  --hr_utility.set_location('Leaving:'||l_proc, 900);

END get_recorded_date;

-- Variation of above procedure
-- pyccutl.pkb has function to get asg_act_status and this needs
-- to retrieve a date but without any dml because function is called
-- within a view.  This is fine because when a true date needs to be
-- inserted, set_recorded_date can be called at a suitable juncture
--
procedure get_recorded_date_no_ins( p_process in varchar2,
                    p_recorded_date out nocopy date ,
                    p_attribute1         in varchar2 ,
                    p_attribute2         in varchar2 ,
                    p_attribute3         in varchar2 ,
                    p_attribute4         in varchar2 ,
                    p_attribute5         in varchar2 ,
                    p_attribute6         in varchar2 ,
                    p_attribute7         in varchar2 ,
                    p_attribute8         in varchar2 ,
                    p_attribute9         in varchar2 ,
                    p_attribute10        in varchar2 ,
                    p_attribute11        in varchar2 ,
                    p_attribute12        in varchar2 ,
                    p_attribute13        in varchar2 ,
                    p_attribute14        in varchar2 ,
                    p_attribute15        in varchar2 ,
                    p_attribute16        in varchar2 ,
                    p_attribute17        in varchar2 ,
                    p_attribute18        in varchar2 ,
                    p_attribute19        in varchar2 ,
                    p_attribute20        in varchar2 )
as

  cursor csr_process_run  IS

    SELECT recorded_date
    FROM   pay_recorded_requests
    WHERE  attribute_category = p_process
    and    attribute1         = p_attribute1
    and    nvl(attribute2,'X')         = nvl(p_attribute2,'X')
    and    nvl(attribute3,'X')         = nvl(p_attribute3,'X')
    and    nvl(attribute4,'X')         = nvl(p_attribute4,'X')
    and    nvl(attribute5,'X')         = nvl(p_attribute5,'X')
    and    nvl(attribute6,'X')         = nvl(p_attribute6,'X')
    and    nvl(attribute7,'X')         = nvl(p_attribute7,'X')
    and    nvl(attribute8,'X')         = nvl(p_attribute8,'X')
    and    nvl(attribute9,'X')         = nvl(p_attribute9,'X')
    and    nvl(attribute10,'X')        = nvl(p_attribute10,'X')
    and    nvl(attribute11,'X')        = nvl(p_attribute11,'X')
    and    nvl(attribute12,'X')        = nvl(p_attribute12,'X')
    and    nvl(attribute13,'X')        = nvl(p_attribute13,'X')
    and    nvl(attribute14,'X')        = nvl(p_attribute14,'X')
    and    nvl(attribute15,'X')        = nvl(p_attribute15,'X')
    and    nvl(attribute16,'X')        = nvl(p_attribute16,'X')
    and    nvl(attribute17,'X')        = nvl(p_attribute17,'X')
    and    nvl(attribute18,'X')        = nvl(p_attribute18,'X')
    and    nvl(attribute19,'X')        = nvl(p_attribute19,'X')
    and    nvl(attribute20,'X')        = nvl(p_attribute20,'X');


  l_recorded_date    DATE;
  l_proc  varchar2(72) := g_package||'get_recorded_date_no_ins';
--
BEGIN
  --hr_utility.set_location('Entering:'||l_proc, 10);

  --See if we've already got an appropriate row
  open csr_process_run;
  fetch csr_process_run into l_recorded_date;

  if (csr_process_run%NOTFOUND) then
     --no row exists, in this procedure we're not creating a row
     l_recorded_date := hr_api.g_sot;
  end if;

  close csr_process_run;

  p_recorded_date := l_recorded_date;
  --hr_utility.set_location('Leaving:'||l_proc, 900);

END get_recorded_date_no_ins;

-- ----------------------------------------------------------------------------
-- Name: set_recorded_date
--
-- Description:
--   This procedure sets the recorded date against the request
--   identified by the attributes.
--   If no record exists (no row in table) then a row is created and this new date
--   is used.
--
-- Prerequisites:
--   This is a public procedure which allows code as part of the request to set
--   a single recorded date which may be required for future processing.
--
-- In Parameters:
--   All column values that identify the row explicitly, eg request type and parameter
--   values.  Both the old date held for this row, and the new set date are returned.
--
-- Post Success:
--   The specified row's old and new recorded dates will be returned.
--
-- Post Failure:
--   Errors are propogated using usual SQL behaviour.
-- ----------------------------------------------------------------------------

procedure set_recorded_date( p_process   in varchar2,
                    p_recorded_date      in date,
                    p_recorded_date_o    out nocopy date,
                    p_attribute1         in varchar2 ,
                    p_attribute2         in varchar2 ,
                    p_attribute3         in varchar2 ,
                    p_attribute4         in varchar2 ,
                    p_attribute5         in varchar2 ,
                    p_attribute6         in varchar2 ,
                    p_attribute7         in varchar2 ,
                    p_attribute8         in varchar2 ,
                    p_attribute9         in varchar2 ,
                    p_attribute10        in varchar2 ,
                    p_attribute11        in varchar2 ,
                    p_attribute12        in varchar2 ,
                    p_attribute13        in varchar2 ,
                    p_attribute14        in varchar2 ,
                    p_attribute15        in varchar2 ,
                    p_attribute16        in varchar2 ,
                    p_attribute17        in varchar2 ,
                    p_attribute18        in varchar2 ,
                    p_attribute19        in varchar2 ,
                    p_attribute20        in varchar2 )
as

  cursor csr_process_run  IS
    SELECT recorded_date
    FROM   pay_recorded_requests
    WHERE  attribute_category = p_process
    and    attribute1         = p_attribute1
    and    nvl(attribute2,'X')         = nvl(p_attribute2,'X')
    and    nvl(attribute3,'X')         = nvl(p_attribute3,'X')
    and    nvl(attribute4,'X')         = nvl(p_attribute4,'X')
    and    nvl(attribute5,'X')         = nvl(p_attribute5,'X')
    and    nvl(attribute6,'X')         = nvl(p_attribute6,'X')
    and    nvl(attribute7,'X')         = nvl(p_attribute7,'X')
    and    nvl(attribute8,'X')         = nvl(p_attribute8,'X')
    and    nvl(attribute9,'X')         = nvl(p_attribute9,'X')
    and    nvl(attribute10,'X')        = nvl(p_attribute10,'X')
    and    nvl(attribute11,'X')        = nvl(p_attribute11,'X')
    and    nvl(attribute12,'X')        = nvl(p_attribute12,'X')
    and    nvl(attribute13,'X')        = nvl(p_attribute13,'X')
    and    nvl(attribute14,'X')        = nvl(p_attribute14,'X')
    and    nvl(attribute15,'X')        = nvl(p_attribute15,'X')
    and    nvl(attribute16,'X')        = nvl(p_attribute16,'X')
    and    nvl(attribute17,'X')        = nvl(p_attribute17,'X')
    and    nvl(attribute18,'X')        = nvl(p_attribute18,'X')
    and    nvl(attribute19,'X')        = nvl(p_attribute19,'X')
    and    nvl(attribute20,'X')        = nvl(p_attribute20,'X')
    for update of recorded_date;


  l_recorded_date    DATE;
  l_proc  varchar2(72) := g_package||'set_recorded_date';
--
BEGIN
  --hr_utility.set_location('Entering:'||l_proc, 10);

  --Get existing row
  open csr_process_run;
  fetch csr_process_run into l_recorded_date;

    -- Return old date in case required by calling code
    p_recorded_date_o := nvl(l_recorded_date,hr_api.g_sot);


  IF (csr_process_run%NOTFOUND) then
    --no row so make one
    insert_recorded_request(
                    p_process,
                    p_recorded_date,
                    p_attribute1 ,
                    p_attribute2 ,
                    p_attribute3 ,
                    p_attribute4 ,
                    p_attribute5 ,
                    p_attribute6 ,
                    p_attribute7 ,
                    p_attribute8 ,
                    p_attribute9 ,
                    p_attribute10,
                    p_attribute11,
                    p_attribute12,
                    p_attribute13,
                    p_attribute14,
                    p_attribute15,
                    p_attribute16,
                    p_attribute17,
                    p_attribute18,
                    p_attribute19,
                    p_attribute20  );
  ELSE
    -- Update to store new date
    UPDATE pay_recorded_requests
    SET recorded_date = p_recorded_date
    WHERE  attribute_category = p_process
    and    attribute1         = p_attribute1
    and    nvl(attribute2,'X')         = nvl(p_attribute2,'X')
    and    nvl(attribute3,'X')         = nvl(p_attribute3,'X')
    and    nvl(attribute4,'X')         = nvl(p_attribute4,'X')
    and    nvl(attribute5,'X')         = nvl(p_attribute5,'X')
    and    nvl(attribute6,'X')         = nvl(p_attribute6,'X')
    and    nvl(attribute7,'X')         = nvl(p_attribute7,'X')
    and    nvl(attribute8,'X')         = nvl(p_attribute8,'X')
    and    nvl(attribute9,'X')         = nvl(p_attribute9,'X')
    and    nvl(attribute10,'X')        = nvl(p_attribute10,'X')
    and    nvl(attribute11,'X')        = nvl(p_attribute11,'X')
    and    nvl(attribute12,'X')        = nvl(p_attribute12,'X')
    and    nvl(attribute13,'X')        = nvl(p_attribute13,'X')
    and    nvl(attribute14,'X')        = nvl(p_attribute14,'X')
    and    nvl(attribute15,'X')        = nvl(p_attribute15,'X')
    and    nvl(attribute16,'X')        = nvl(p_attribute16,'X')
    and    nvl(attribute17,'X')        = nvl(p_attribute17,'X')
    and    nvl(attribute18,'X')        = nvl(p_attribute18,'X')
    and    nvl(attribute19,'X')        = nvl(p_attribute19,'X')
    and    nvl(attribute20,'X')        = nvl(p_attribute20,'X');

  END IF;

  close csr_process_run;
  --hr_utility.set_location('Leaving:'||l_proc, 900);

END set_recorded_date;


END PAY_RECORDED_REQUESTS_PKG;

/
