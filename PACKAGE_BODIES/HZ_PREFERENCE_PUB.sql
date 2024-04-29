--------------------------------------------------------
--  DDL for Package Body HZ_PREFERENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PREFERENCE_PUB" AS
/*$Header: ARHPREFB.pls 120.9 2006/01/05 17:07:59 vravicha noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_PREFERENCE_PUB';
G_PPREF_ID          NUMBER;

-- private procedure for common validations
PROCEDURE validate(
        p_party_id              IN      NUMBER,
        p_category              IN      VARCHAR2,
        p_preference_code       IN      VARCHAR2,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

-- private procedure to denormalize preferred contact method
PROCEDURE denorm_pref_contact_method (
    p_party_id                    IN     NUMBER,
    p_value_varchar2              IN     VARCHAR2
);

-- private function for checking value_varchar2 presence
FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_varchar2_o    VARCHAR2 := FND_API.G_MISS_CHAR
) RETURN VARCHAR2
AS
  l_dummy               NUMBER;
  l_return_status       VARCHAR2(1);
BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  SELECT  1
  INTO    l_dummy
  FROM    HZ_PARTY_PREFERENCES
  WHERE   CATEGORY = p_category
  AND     PREFERENCE_CODE = p_preference_code
  AND     PARTY_ID = p_party_id
  AND     VALUE_VARCHAR2 = p_value_varchar2_o
  AND     ROWNUM = 1;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Contains_Value;


FUNCTION Contains_Preference(
  p_party_id                NUMBER
, p_category                VARCHAR2
, p_preference_code         VARCHAR2
) RETURN VARCHAR2 AS

  l_dummy           NUMBER;
  l_return_status   VARCHAR2(1);

BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  SELECT  1
  INTO    l_dummy
  FROM    HZ_PARTY_PREFERENCES
  WHERE   CATEGORY = p_category
  AND     PREFERENCE_CODE = p_preference_code
  AND     PARTY_ID = p_party_id
  AND     ROWNUM = 1;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Contains_Preference;


FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_varchar2      VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number        NUMBER   := FND_API.G_MISS_NUM
, p_value_date          DATE     := FND_API.G_MISS_DATE
) RETURN VARCHAR2 AS

  l_dummy           NUMBER;
  l_value_varchar2  VARCHAR2(50);
  l_value_number    NUMBER;
  l_value_date      DATE;
  l_ret             VARCHAR2(1);
  l_return_status   VARCHAR2(1);

BEGIN

  -- do additional validations
  -- if none of the preference values passed then it is an error
  if (p_value_varchar2 = FND_API.G_MISS_CHAR OR
      p_value_varchar2 IS NULL) and
     (p_value_number = FND_API.G_MISS_NUM OR
      p_value_number IS NULL) and
     (p_value_date = FND_API.G_MISS_DATE OR
      p_value_date IS NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_NO_PREFERENCE');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if more than one preference values passed, then it is an error
  if (p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL AND
      p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL) OR
     (p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL AND
      p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL) OR
     (p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL AND
      p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_MULTIPLE_PREFERENCES');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  if p_value_varchar2 <> FND_API.G_MISS_CHAR and
     p_value_varchar2 is not null then
    l_ret := Contains_Value(p_party_id, p_category, p_preference_code, p_value_varchar2_o => p_value_varchar2);
  end if;

  if p_value_number <> FND_API.G_MISS_NUM and
     p_value_number is not null then
    l_ret := Contains_Value(p_party_id, p_category, p_preference_code, p_value_number);
  end if;

  if p_value_date <> FND_API.G_MISS_DATE and
     p_value_date is not null then
    l_ret := Contains_Value(p_party_id, p_category, p_preference_code, p_value_date);
  end if;

  RETURN l_ret;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Contains_Value;


PROCEDURE  Add(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
, p_value_name            VARCHAR2 := FND_API.G_MISS_CHAR
, p_module                VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value1     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value2     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value3     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value4     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value5     VARCHAR2 := FND_API.G_MISS_CHAR
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_object_version_number OUT NOCOPY NUMBER
) AS

  cursor c_tag is
    select tag
    from   fnd_lookup_values
    where  lookup_type = 'HZ_PREFERENCE'
    and    lookup_code = p_preference_code;

  l_party_preference_id     NUMBER;
  l_rowid                   ROWID;
  l_return_status           VARCHAR2(1);
  l_multiple_value_flag     VARCHAR2(1);
  l_object_version_number   NUMBER := 1;

BEGIN

  -- standard start of API savepoint
  SAVEPOINT add_preference;

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if none of the preference values passed then it is an error
  if (p_value_varchar2 = FND_API.G_MISS_CHAR OR
      p_value_varchar2 IS NULL) AND
     (p_value_number = FND_API.G_MISS_NUM OR
      p_value_number IS NULL) AND
     (p_value_date = FND_API.G_MISS_DATE OR
      p_value_date IS NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_NO_PREFERENCE');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if more than one preference values passed, then it is an error
  if (p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL AND
      p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL) OR
     (p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL AND
      p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL) OR
     (p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL AND
      p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_MULTIPLE_PREFERENCES');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if there is already some value set for the preference
  -- and the preference is single-value type, then error
  open c_tag;
  fetch c_tag into l_multiple_value_flag;
  close c_tag;

  if l_multiple_value_flag = 'N' then    -- single-value preference
    if Contains_Preference(p_party_id,
                           p_category,
                           p_preference_code) = 'Y' then   -- already one preference value set
      FND_MESSAGE.SET_NAME('AR', 'HZ_SINGLE_VALUE_PREFERENCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  IF (Contains_Value(
        p_party_id
      , p_category
      , p_preference_code
      , p_value_varchar2
      , p_value_number
      , p_value_date) = 'N')
  THEN
    -- the current preference value does not exist, so create
    -- generate the party preference id from sequence
    select hz_party_preferences_s.nextval into l_party_preference_id from dual;

    -- record the party_preference_id for integration service to call populate function
    G_PPREF_ID := l_party_preference_id;

    -- call table handler to insert preference record
    HZ_PARTY_PREFERENCES_PKG.insert_row
    (X_ROWID                 => l_rowid,
     X_PARTY_PREFERENCE_ID   => l_party_preference_id,
     X_PARTY_ID              => p_party_id,
     X_MODULE                => p_module,
     X_CATEGORY              => p_category,
     X_PREFERENCE_CODE       => p_preference_code,
     X_VALUE_VARCHAR2        => p_value_varchar2,
     X_VALUE_NUMBER          => p_value_number,
     X_VALUE_DATE            => p_value_date,
     X_VALUE_NAME            => p_value_name,
     X_ADDITIONAL_VALUE1     => p_additional_value1,
     X_ADDITIONAL_VALUE2     => p_additional_value2,
     X_ADDITIONAL_VALUE3     => p_additional_value3,
     X_ADDITIONAL_VALUE4     => p_additional_value4,
     X_ADDITIONAL_VALUE5     => p_additional_value5,
     X_OBJECT_VERSION_NUMBER => l_object_version_number,
     X_CREATED_BY            => hz_utility_pub.CREATED_BY,
     X_CREATION_DATE         => hz_utility_pub.CREATION_DATE,
     X_LAST_UPDATED_BY       => hz_utility_pub.LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE      => hz_utility_pub.LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN     => hz_utility_pub.LAST_UPDATE_LOGIN
    );

    IF p_category = 'COMMUNICATION_PREFERENCE' AND
       p_preference_code = 'PREFERRED_CONTACT_METHOD'
    THEN
      denorm_pref_contact_method(p_party_id, p_value_varchar2);
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_object_version_number := l_object_version_number;

  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO add_preference;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO add_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO add_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Add;

PROCEDURE Put(
  p_party_id                 NUMBER
, p_category                 VARCHAR2
, p_preference_code          VARCHAR2
, p_value_varchar2           VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number             NUMBER   := FND_API.G_MISS_NUM
, p_value_date               DATE     := FND_API.G_MISS_DATE
, p_value_name               VARCHAR2 := FND_API.G_MISS_CHAR
, p_module                   VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value1        VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value3        VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value4        VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value5        VARCHAR2 := FND_API.G_MISS_CHAR
, p_object_version_number IN OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
) AS

  cursor c_tag is
    select tag
    from   fnd_lookup_values
    where  lookup_type = 'HZ_PREFERENCE'
    and    lookup_code = p_preference_code;

  l_rowid                    ROWID;
  l_return_status            VARCHAR2(1);
  l_exists                   VARCHAR2(1);
  l_party_preference_id      NUMBER;
  l_object_version_number    NUMBER := 1;
  o_object_version_number    NUMBER;
  l_multiple_preference_flag VARCHAR2(1);
  l_op                       VARCHAR2(1);
  l_ppref_id                 NUMBER;
BEGIN

  -- standard start of API savepoint
  SAVEPOINT put_preference;

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if none of the preference values passed then it is an error
  if (p_value_varchar2 = FND_API.G_MISS_CHAR OR
      p_value_varchar2 IS NULL) AND
     (p_value_number = FND_API.G_MISS_NUM OR
      p_value_number IS NULL) AND
     (p_value_date = FND_API.G_MISS_DATE OR
      p_value_date IS NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_NO_PREFERENCE');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if more than one preference values passed, then it is an error
  if (p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL AND
      p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL) OR
     (p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL AND
      p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL) OR
     (p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL AND
      p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_MULTIPLE_PREFERENCES');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- check if there is already an existing preference value
  l_exists := Contains_Value(
        p_party_id
      , p_category
      , p_preference_code
      , p_value_varchar2
      , p_value_number
      , p_value_date);

  -- if the preference value does not exist then create one
  -- for multiple-value preference or update single-value
  -- preference with the new value if preference exists
  -- else update the existing preference
  IF l_exists = 'N'
  THEN

    -- check the multiple_value_flag for the preference
    open c_tag;
    fetch c_tag into l_multiple_preference_flag;
    close c_tag;

    if l_multiple_preference_flag = 'Y' then
      -- this is multiple value preference, so create the preference value
      -- call Add api to create the preference
      Add(
          p_party_id            => p_party_id
        , p_category            => p_category
        , p_preference_code     => p_preference_code
        , p_value_varchar2      => p_value_varchar2
        , p_value_number        => p_value_number
        , p_value_date          => p_value_date
        , p_value_name          => p_value_name
        , p_module              => p_module
        , p_additional_value1   => p_additional_value1
        , p_additional_value2   => p_additional_value2
        , p_additional_value3   => p_additional_value3
        , p_additional_value4   => p_additional_value4
        , p_additional_value5   => p_additional_value5
        , x_return_status       => x_return_status
        , x_msg_count           => x_msg_count
        , x_msg_data            => x_msg_data
        , x_object_version_number => p_object_version_number
       );
    else
      -- this is a single value preference, so update the value
      -- if preference entry exists, otherwise add a record
      if Contains_Preference(p_party_id,
                           p_category,
                           p_preference_code) = 'Y' then   -- already one preference value set
        -- first we have to identify which record should
        -- be updated based on what value was passed.
        select party_preference_id, object_version_number
        into   l_party_preference_id, o_object_version_number
        from   hz_party_preferences
        where  party_id = p_party_id
        and    category = p_category
        and    preference_code = p_preference_code
        for update nowait;

        -- check if the object_version_numbers match
        if o_object_version_number <> p_object_version_number
        then
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
          FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_PREFERENCES');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        end if;
        l_object_version_number := o_object_version_number + 1;

        -- now call the update table handler to
        -- update the record
        HZ_PARTY_PREFERENCES_PKG.update_row
        (X_PARTY_PREFERENCE_ID    => l_party_preference_id
        ,X_PARTY_ID               => p_party_id
        ,X_MODULE                 => p_module
        ,X_CATEGORY               => p_category
        ,X_PREFERENCE_CODE        => p_preference_code
        ,X_VALUE_VARCHAR2         => p_value_varchar2
        ,X_VALUE_NUMBER           => p_value_number
        ,X_VALUE_DATE             => p_value_date
        ,X_VALUE_NAME             => p_value_name
        ,X_ADDITIONAL_VALUE1      => p_additional_value1
        ,X_ADDITIONAL_VALUE2      => p_additional_value2
        ,X_ADDITIONAL_VALUE3      => p_additional_value3
        ,X_ADDITIONAL_VALUE4      => p_additional_value4
        ,X_ADDITIONAL_VALUE5      => p_additional_value5
        ,X_OBJECT_VERSION_NUMBER  => l_object_version_number
        ,X_LAST_UPDATED_BY        => hz_utility_pub.last_updated_by
        ,X_LAST_UPDATE_DATE       => hz_utility_pub.last_update_date
        ,X_LAST_UPDATE_LOGIN      => hz_utility_pub.last_update_login
        );

        IF p_category = 'COMMUNICATION_PREFERENCE' AND
           p_preference_code = 'PREFERRED_CONTACT_METHOD'
        THEN
          denorm_pref_contact_method(p_party_id, p_value_varchar2);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        p_object_version_number := l_object_version_number;
      else
        Add(
            p_party_id            => p_party_id
          , p_category            => p_category
          , p_preference_code     => p_preference_code
          , p_value_varchar2      => p_value_varchar2
          , p_value_number        => p_value_number
          , p_value_date          => p_value_date
          , p_value_name          => p_value_name
          , p_module              => p_module
          , p_additional_value1   => p_additional_value1
          , p_additional_value2   => p_additional_value2
          , p_additional_value3   => p_additional_value3
          , p_additional_value4   => p_additional_value4
          , p_additional_value5   => p_additional_value5
          , x_return_status       => x_return_status
          , x_msg_count           => x_msg_count
          , x_msg_data            => x_msg_data
          , x_object_version_number => p_object_version_number
         );
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      end if;
    end if;
  ELSIF l_exists = 'Y'
  THEN
    -- update the preference
    -- first we have to identify which record should
    -- be updated based on what value was passed.
    if p_value_varchar2 <> FND_API.G_MISS_CHAR AND
       p_value_varchar2 IS NOT NULL
    then
      select party_preference_id, object_version_number
      into   l_party_preference_id, o_object_version_number
      from   hz_party_preferences
      where  party_id = p_party_id
      and    category = p_category
      and    preference_code = p_preference_code
      and    value_varchar2 = p_value_varchar2
      for update nowait;
    elsif p_value_number <> FND_API.G_MISS_NUM AND
          p_value_number IS NOT NULL
    then
      select party_preference_id, object_version_number
      into   l_party_preference_id, o_object_version_number
      from   hz_party_preferences
      where  party_id = p_party_id
      and    category = p_category
      and    preference_code = p_preference_code
      and    value_number = p_value_number
      for update nowait;
    elsif p_value_date <> FND_API.G_MISS_DATE AND
          p_value_date IS NOT NULL
    then
      select party_preference_id, object_version_number
      into   l_party_preference_id, o_object_version_number
      from   hz_party_preferences
      where  party_id = p_party_id
      and    category = p_category
      and    preference_code = p_preference_code
      and    value_date = p_value_date
      for update nowait;
    end if;

    -- check if the object_version_numbers match
    if o_object_version_number <> p_object_version_number
    then
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_PREFERENCES');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    l_object_version_number := o_object_version_number + 1;

    -- now call the update table handler to
    -- update the record
    HZ_PARTY_PREFERENCES_PKG.update_row
    (X_PARTY_PREFERENCE_ID    => l_party_preference_id
    ,X_PARTY_ID               => p_party_id
    ,X_MODULE                 => p_module
    ,X_CATEGORY               => p_category
    ,X_PREFERENCE_CODE        => p_preference_code
    ,X_VALUE_VARCHAR2         => p_value_varchar2
    ,X_VALUE_NUMBER           => p_value_number
    ,X_VALUE_DATE             => p_value_date
    ,X_VALUE_NAME             => p_value_name
    ,X_ADDITIONAL_VALUE1      => p_additional_value1
    ,X_ADDITIONAL_VALUE2      => p_additional_value2
    ,X_ADDITIONAL_VALUE3      => p_additional_value3
    ,X_ADDITIONAL_VALUE4      => p_additional_value4
    ,X_ADDITIONAL_VALUE5      => p_additional_value5
    ,X_OBJECT_VERSION_NUMBER  => l_object_version_number
    ,X_LAST_UPDATED_BY        => hz_utility_pub.last_updated_by
    ,X_LAST_UPDATE_DATE       => hz_utility_pub.last_update_date
    ,X_LAST_UPDATE_LOGIN      => hz_utility_pub.last_update_login
    );

    IF p_category = 'COMMUNICATION_PREFERENCE' AND
       p_preference_code = 'PREFERRED_CONTACT_METHOD'
    THEN
      denorm_pref_contact_method(p_party_id, p_value_varchar2);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_object_version_number := l_object_version_number;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      IF(l_exists = 'Y') THEN
        l_op := 'U';
        l_ppref_id := l_party_preference_id;
      ELSE
        l_op := 'I';
        l_ppref_id := G_PPREF_ID;
      END IF;
      HZ_POPULATE_BOT_PKG.pop_hz_party_preferences(
        p_operation           => l_op,
        p_party_preference_id => l_ppref_id);
    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO put_preference;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO put_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO put_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Put;

PROCEDURE Remove(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
, p_object_version_number NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
) AS

  l_return_status       VARCHAR2(1);

BEGIN

  -- standard start of API savepoint
  SAVEPOINT remove_preference;

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  x_return_status := l_return_status;

  -- if more than one preference values passed, then it is an error
  if (p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL AND
      p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL) OR
     (p_value_number <> FND_API.G_MISS_NUM AND
      p_value_number IS NOT NULL AND
      p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL) OR
     (p_value_date <> FND_API.G_MISS_DATE AND
      p_value_date IS NOT NULL AND
      p_value_varchar2 <> FND_API.G_MISS_CHAR AND
      p_value_varchar2 IS NOT NULL)
  then
    FND_MESSAGE.SET_NAME('AR', 'HZ_MULTIPLE_PREFERENCES');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  -- if none of the values is specified, delete all
  -- preferences for given party, category, preference_code
  if (p_value_varchar2 = FND_API.G_MISS_CHAR OR
      p_value_varchar2 IS NULL) AND
     (p_value_number = FND_API.G_MISS_NUM OR
      p_value_number IS NULL) AND
     (p_value_date = FND_API.G_MISS_DATE OR
      p_value_date IS NULL)
  then
    DELETE FROM hz_party_preferences
    WHERE  party_id = p_party_id
    AND    category = p_category
    AND    preference_code = p_preference_code;

    IF p_category = 'COMMUNICATION_PREFERENCE' AND
       p_preference_code = 'PREFERRED_CONTACT_METHOD'
    THEN
      denorm_pref_contact_method(p_party_id, null);
    END IF;

  elsif (p_value_varchar2 <> FND_API.G_MISS_CHAR AND
         p_value_varchar2 IS NOT NULL) AND
        (p_value_number = FND_API.G_MISS_NUM OR
         p_value_number IS NULL) AND
        (p_value_date = FND_API.G_MISS_DATE OR
         p_value_date IS NULL)
  then
    DELETE FROM hz_party_preferences
    WHERE  party_id = p_party_id
    AND    category = p_category
    AND    preference_code = p_preference_code
    AND    value_varchar2 = p_value_varchar2
    AND    object_version_number = p_object_version_number;

    IF p_category = 'COMMUNICATION_PREFERENCE' AND
       p_preference_code = 'PREFERRED_CONTACT_METHOD'
    THEN
      denorm_pref_contact_method(p_party_id, null);
    END IF;

  elsif (p_value_varchar2 = FND_API.G_MISS_CHAR OR
         p_value_varchar2 IS NULL) AND
        (p_value_number <> FND_API.G_MISS_NUM AND
         p_value_number IS NOT NULL) AND
        (p_value_date = FND_API.G_MISS_DATE OR
         p_value_date IS NULL)
  then
    DELETE FROM hz_party_preferences
    WHERE  party_id = p_party_id
    AND    category = p_category
    AND    preference_code = p_preference_code
    AND    value_number = p_value_number
    AND    object_version_number = p_object_version_number;

  elsif (p_value_varchar2 = FND_API.G_MISS_CHAR OR
         p_value_varchar2 IS NULL) AND
        (p_value_number = FND_API.G_MISS_NUM OR
         p_value_number IS NULL) AND
        (p_value_date <> FND_API.G_MISS_DATE AND
         p_value_date IS NOT NULL)
  then
    DELETE FROM hz_party_preferences
    WHERE  party_id = p_party_id
    AND    category = p_category
    AND    preference_code = p_preference_code
    AND    value_date = p_value_date
    AND    object_version_number = p_object_version_number;

  end if;

  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO remove_preference;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remove_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO remove_preference;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Remove;


PROCEDURE Retrieve(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, x_preference_value    OUT NOCOPY ref_cursor_typ
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
) AS

  l_return_status       VARCHAR2(1);

BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  x_return_status := l_return_status;

  OPEN x_preference_value FOR
    SELECT  *
    FROM    HZ_PARTY_PREFERENCES
    WHERE   CATEGORY = p_category
    AND     PREFERENCE_CODE = p_preference_code
    AND     PARTY_ID = p_party_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Retrieve;


FUNCTION Value_Varchar2(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN VARCHAR2
AS
  CURSOR  c_pref(pty NUMBER, cat VARCHAR2, pref VARCHAR2) IS
    SELECT  VALUE_VARCHAR2
    FROM    HZ_PARTY_PREFERENCES
    WHERE   CATEGORY = cat
    AND     PREFERENCE_CODE = pref
    AND     PARTY_ID = pty
    AND     VALUE_VARCHAR2 is not null;

  l_vchar2          VARCHAR2(240);
  l_return_status   VARCHAR2(1);

BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  OPEN c_pref(p_party_id, p_category, p_preference_code);
  FETCH c_pref into l_vchar2;
  IF (c_pref%NOTFOUND) THEN
    RETURN NULL;
  END IF;
  CLOSE c_pref;

  RETURN l_vchar2;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN NULL;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN NULL;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN NULL;

END;


FUNCTION Value_Number(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN NUMBER
AS
  CURSOR  c_pref(pty NUMBER, cat VARCHAR2, pref VARCHAR2) IS
    SELECT  VALUE_NUMBER
    FROM    HZ_PARTY_PREFERENCES
    WHERE   CATEGORY = cat
    AND     PREFERENCE_CODE = pref
    AND     PARTY_ID = pty
    AND     VALUE_NUMBER is not null;

  l_num               NUMBER;
  l_return_status     VARCHAR2(1);
BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  OPEN c_pref(p_party_id, p_category, p_preference_code);
  FETCH c_pref into l_num;
  IF (c_pref%NOTFOUND) THEN
    RETURN NULL;
  END IF;
  CLOSE c_pref;

  RETURN l_num;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN NULL;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN NULL;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN NULL;

END;


FUNCTION Value_Date(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN DATE
AS
  CURSOR  c_pref(pty NUMBER, cat VARCHAR2, pref VARCHAR2) IS
    SELECT  VALUE_DATE
    FROM    HZ_PARTY_PREFERENCES
    WHERE   CATEGORY = cat
    AND     PREFERENCE_CODE = pref
    AND     PARTY_ID = pty
    AND     VALUE_DATE is not null;

  l_date             DATE;
  l_return_status    VARCHAR2(1);

BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  OPEN c_pref(p_party_id, p_category, p_preference_code);
  FETCH c_pref into l_date;
  IF (c_pref%NOTFOUND) THEN
    RETURN NULL;
  END IF;
  CLOSE c_pref;

  RETURN l_date;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN NULL;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN NULL;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN NULL;

END;



FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_number        NUMBER     --:= FND_API.G_MISS_NUM
) RETURN VARCHAR2
AS
  l_dummy               NUMBER;
  l_return_status   VARCHAR2(1);
BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  SELECT  1
  INTO    l_dummy
  FROM    HZ_PARTY_PREFERENCES
  WHERE   CATEGORY = p_category
  AND     PREFERENCE_CODE = p_preference_code
  AND     PARTY_ID = p_party_id
  AND     VALUE_NUMBER = p_value_number
  AND     ROWNUM = 1;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Contains_Value;



FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_date          DATE      --:= FND_API.G_MISS_DATE
) RETURN VARCHAR2
AS
  l_dummy               NUMBER;
  l_return_status   VARCHAR2(1);
BEGIN

  -- call validation of the info passed
  validate(p_party_id
          ,p_category
          ,p_preference_code
          ,l_return_status
          );

  -- if the validation failed at some point, raise exception
  if l_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  SELECT  1
  INTO    l_dummy
  FROM    HZ_PARTY_PREFERENCES
  WHERE   CATEGORY = p_category
  AND     PREFERENCE_CODE = p_preference_code
  AND     PARTY_ID = p_party_id
  AND     VALUE_DATE = p_value_date
  AND     ROWNUM = 1;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Contains_Value;


procedure validate(
        p_party_id              IN      NUMBER,
        p_category              IN      VARCHAR2,
        p_preference_code       IN      VARCHAR2,
        x_return_status         IN OUT  NOCOPY VARCHAR2
) IS
        l_dummy                 VARCHAR2(1);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check whether party id has been passed in.
  IF p_party_id IS NULL OR
     p_party_id = FND_API.G_MISS_NUM THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
    FND_MESSAGE.SET_TOKEN('COLUMN', 'party id');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- check whether category has been passed in.
  IF p_category IS NULL OR
     p_category = FND_API.G_MISS_CHAR THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
    FND_MESSAGE.SET_TOKEN('COLUMN', 'category');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- check whether preference code has been passed in.
  IF p_preference_code IS NULL OR
     p_preference_code = FND_API.G_MISS_CHAR THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
    FND_MESSAGE.SET_TOKEN('COLUMN', 'preference code');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- check if valid party_id has been passed
  begin
    select 'Y' into l_dummy
    from   hz_parties
    where  party_id = p_party_id;
  exception
    when no_data_found then
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
      FND_MESSAGE.SET_TOKEN('FK', 'party id');
      FND_MESSAGE.SET_TOKEN('COLUMN' ,'party_id');
      FND_MESSAGE.SET_TOKEN('TABLE' ,'HZ_PARTIES');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    when others then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end;

  -- check if valid preference code has been passed
  hz_common_pub.validate_lookup(
    p_lookup_type   => 'HZ_PREFERENCE',
    p_column        => 'preference code',
    p_column_value  => p_preference_code,
    x_return_status => x_return_status);

  if x_return_status = FND_API.G_RET_STS_ERROR then
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;

END validate;

PROCEDURE denorm_pref_contact_method (
    p_party_id                    IN     NUMBER,
    p_value_varchar2              IN     VARCHAR2
) IS

    CURSOR c_party IS
    SELECT 'Y'
    FROM   hz_parties
    WHERE  party_id = p_party_id
    FOR UPDATE NOWAIT;

    l_exists                      VARCHAR2(1);

BEGIN

    --check if party record is locked by any one else.
    BEGIN
      OPEN c_party;
      FETCH c_party INTO l_exists;
      CLOSE c_party;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTIES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    UPDATE hz_parties
    SET    preferred_contact_method = p_value_varchar2
    WHERE  party_id = p_party_id;

END denorm_pref_contact_method;

END HZ_PREFERENCE_PUB;

/
