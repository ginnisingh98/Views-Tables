--------------------------------------------------------
--  DDL for Package Body CS_KB_SET_RECS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SET_RECS_PKG" AS
/* $Header: cskbsrb.pls 120.0 2005/06/01 14:28:24 appldev noship $ */

  -- **********************************
  -- * Private procedure declarations *
  -- **********************************

  procedure Swap_Recommendation_Order
  ( p_set_rec_id_1 in number,
    p_set_rec_id_2 in number );

  -- ************************************
  -- * Public procedure implementations *
  -- ************************************

  --
  -- Move a Solution up, on the Recommended Solutions list
  --
  PROCEDURE Move_Up_Solution_Rec
  ( p_set_rec_id in number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 )
  is
    l_order number;
    l_prev_order number;
    l_set_rec_id_prev number;
  begin
    -- Validate params
    if(P_SET_REC_ID is null ) then
      x_ret_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    -- Query out the recommendation order of the solution
    -- we want to move up the recommendation list
    begin
      select set_order into l_order from cs_kb_set_recs
      where set_rec_id = p_set_rec_id;
    exception
      when no_data_found then
        x_ret_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data );
        return;
    end;

    -- Query out the order number of the solution
    -- just above this one.
    -- Note: we join the recommended solutions list with the
    -- secure solutions view to filter out any solutions in
    -- the recommended solutions list the user cannot access.
    select sr1.set_rec_id, sr1.set_order into l_set_rec_id_prev, l_prev_order
    from cs_kb_set_recs sr1 where sr1.set_order =
     (select max(sr.set_order)
      from cs_kb_set_recs sr, cs_kb_secure_solutions_view sv
      where sr.set_number = sv.set_number
        and sv.viewable_version_flag = 'Y'
        and sv.status = 'PUB'
        and sr.set_order < l_order );
    if(l_prev_order is null) then
      x_ret_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_KB_C_REC_SET_NO_HIGHER');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
       return;
    end if;

    Swap_Recommendation_Order(l_set_rec_id_prev, p_set_rec_id);

    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;
    return;
  end Move_Up_Solution_Rec;


  --
  -- Move a Solution down, on the Recommended Solutions list
  --
  PROCEDURE Move_Down_Solution_Rec
  ( p_set_rec_id in number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 )
  is
    l_order number;
    l_next_order number;
    l_set_rec_id_next number;
  begin
    -- Validate params
    if(P_SET_REC_ID is null ) then
      x_ret_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    -- Query out the recommendation order of the solution
    -- we want to move down the recommendation list
    begin
      select set_order into l_order from cs_kb_set_recs
      where set_rec_id = p_set_rec_id;
    exception
      when no_data_found then
        x_ret_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data );
        return;
    end;

    -- Query out the order number of the solution
    -- just below this one.
    -- Note: we join the recommended solutions list with the
    -- secure solutions view to filter out any solutions in
    -- the recommended solutions list the user cannot access.
    select sr1.set_rec_id, sr1.set_order into l_set_rec_id_next, l_next_order
    from cs_kb_set_recs sr1 where sr1.set_order =
     (select min(sr.set_order)
      from cs_kb_set_recs sr, cs_kb_secure_solutions_view sv
      where sr.set_number = sv.set_number
        and sv.viewable_version_flag = 'Y'
        and sv.status = 'PUB'
        and sr.set_order > l_order );
    if(l_next_order is null) then
      x_ret_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_KB_C_REC_SET_NO_LOWER');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    Swap_Recommendation_Order(l_set_rec_id_next, p_set_rec_id);

    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;
    return;
  end Move_Down_Solution_Rec;

  /*
   * Create_Set_Rec
   *  Create a solution recommendation record.
   */
  PROCEDURE Create_Set_Rec
  ( P_SET_REC_ID         in NUMBER DEFAULT NULL,
    P_SET_NUMBER         in VARCHAR2,
    P_SET_ORDER          in NUMBER DEFAULT NULL,
    P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE1         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE2         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE3         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE4         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE5         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE6         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE7         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE8         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE9         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE10        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE11        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE12        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE13        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE14        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE15        in VARCHAR2 DEFAULT NULL,
    X_SET_REC_ID         out nocopy NUMBER,
    X_RET_STATUS         out nocopy VARCHAR2,
    X_MSG_COUNT          out nocopy NUMBER,
    X_MSG_DATA           out nocopy VARCHAR2 )
  IS
    l_set_rec_id number;
    l_set_id number;
    l_date  date;
    l_created_by number;
    l_login number;
    l_count number;
    l_set_order number;
    l_set_rec_id_seq_val number;
    l_order_seq_val number;
  BEGIN
    -- initialize default outputs to error
    x_set_rec_id := 0;
    x_ret_status := FND_API.G_RET_STS_ERROR;

    -- Check params
    if(p_set_rec_id is not null ) then
      select count(*) into l_count
        from cs_kb_set_recs
        where set_rec_id = p_set_rec_id;
      if( l_count > 0 ) then
        fnd_message.set_name('CS', 'CS_KB_C_REC_SET_ERR');
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data );
        return;
      end if;

      -- Make sure the id sequence is always higher than the passed
      -- in set rec id such that there will not be duplicate solution
      -- recommendation id's created.
      select cs_kb_set_recs_s.currval into l_set_rec_id_seq_val from dual;
      while ( l_set_rec_id_seq_val < p_set_rec_id ) loop
        select cs_kb_set_recs_s.nextval into l_set_rec_id_seq_val from dual;
      end loop;

      l_set_rec_id := p_set_rec_id;
    else
      select cs_kb_set_recs_s.nextval into l_set_rec_id from dual;
    end if;

    if(P_SET_NUMBER is null) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    -- Find the solution id for latest viewable solution version,
    -- given the solution number.
    begin
      select distinct set_id into l_set_id
      from cs_kb_secure_solutions_view
      where set_number = p_set_number
        and viewable_version_flag = 'Y'
        and status = 'PUB';
    exception
      when no_data_found then
        fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data );
        return;
    end;


    --check for duplicate solution recommendation
    select count(*) into l_count
      from cs_kb_set_recs
      where set_number = p_set_number;
    if(l_count>0) then
      fnd_message.set_name('CS', 'CS_KB_C_REC_SET_EXIST');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;


    -- If the solution recommendation order parameter (p_set_order)
    -- is null, generate a new order number from the sequence.
    -- Otherwise, validate that the passed order is not a duplicate.
    if( p_set_order is null ) then
      select cs_kb_set_rec_order_s.nextval into l_set_order from dual;
    else
      l_set_order := p_set_order;
      select count(*) into l_count from cs_kb_set_recs
      where set_order = l_set_order;
      if( l_count > 0 ) then
        fnd_message.set_name('CS', 'CS_KB_C_REC_SET_INVALID_ORDER');
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data );
        return;
      end if;

      -- Make sure the order sequence is always higher than the passed
      -- in order number such that newly recommended solutions are always
      -- at the end of the recommendation list.
      select cs_kb_set_rec_order_s.currval into l_order_seq_val from dual;
      while ( l_order_seq_val < l_set_order ) loop
        select cs_kb_set_rec_order_s.nextval into l_order_seq_val from dual;
      end loop;
    end if;

    l_date := sysdate;
    l_created_by := fnd_global.user_id;
    l_login := fnd_global.login_id;

    -- Create the solution recommendation row
    insert into CS_KB_SET_RECS
    ( SET_REC_ID,
      SET_ID,
      SET_ORDER,
      SET_NUMBER,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
      ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
      ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15 )
    values
    ( l_set_rec_id,
      l_set_id,
      l_set_order,
      P_SET_NUMBER,
      l_date,
      l_created_by,
      l_date,
      l_created_by,
      l_login,
      P_ATTRIBUTE_CATEGORY,
      P_ATTRIBUTE1, P_ATTRIBUTE2, P_ATTRIBUTE3, P_ATTRIBUTE4, P_ATTRIBUTE5,
      P_ATTRIBUTE6, P_ATTRIBUTE7, P_ATTRIBUTE8, P_ATTRIBUTE9, P_ATTRIBUTE10,
      P_ATTRIBUTE11, P_ATTRIBUTE12, P_ATTRIBUTE13, P_ATTRIBUTE14, P_ATTRIBUTE15);

    -- return success
    x_set_rec_id := l_set_rec_id;
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;
    return;
  exception
    when others then
      x_ret_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('CS', 'CS_KB_C_REC_SET_ERR');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
  END Create_Set_Rec;


  /*
   * Update_Set_Rec
   *  This procedure updates a solution recommendation record.
   *  NOTE: !! Currently this procedure is not being used. !!
   *   !! Needs additial review and some cleanup. !!
   */
  procedure Update_Set_Rec
  ( P_SET_REC_ID         in NUMBER,
    P_SET_NUMBER         in VARCHAR2,
    P_SET_ORDER          in NUMBER,
    P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE1         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE2         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE3         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE4         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE5         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE6         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE7         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE8         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE9         in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE10        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE11        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE12        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE13        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE14        in VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE15        in VARCHAR2 DEFAULT NULL,
    X_RET_STATUS         out nocopy VARCHAR2,
    X_MSG_COUNT          out nocopy NUMBER,
    X_MSG_DATA           out nocopy VARCHAR2 )
  is
  l_date  date;
  l_updated_by number;
  l_login number;
begin

  -- validate params
  if(P_SET_NUMBER is null OR P_SET_ORDER is null) then
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data );
    goto error_found;
  end if;

  -- The set_id stored in the recs table is not necessarily the latest PUB version
  -- that is displayed in the ui. Therefore fetch stored set_id.
/*
  OPEN  GET_STORED_SET(p_set_id);
  FETCH GET_STORED_SET INTO l_stored_set_id;
  CLOSE GET_STORED_SET;
*/

  l_date := sysdate;
  l_updated_by := fnd_global.user_id;
  l_login := fnd_global.login_id;

  update CS_KB_SET_RECS set
    SET_ORDER = P_SET_ORDER,
    LAST_UPDATE_DATE = l_date,
    LAST_UPDATED_BY = l_updated_by,
    LAST_UPDATE_LOGIN = l_login,
    ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    ATTRIBUTE11 = P_ATTRIBUTE11,
    ATTRIBUTE12 = P_ATTRIBUTE12,
    ATTRIBUTE13 = P_ATTRIBUTE13,
    ATTRIBUTE14 = P_ATTRIBUTE14,
    ATTRIBUTE15 = P_ATTRIBUTE15
  WHERE SET_REC_ID = P_SET_REC_ID;
  --where SET_ID = l_stored_set_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  return;

  <<error_found>>
  return;

  exception
  when others then
    return;

end Update_Set_Rec;

  /*
   * Delete_Set_Rec
   *  Delete a solution recommendation record.
   */
  PROCEDURE Delete_Set_Rec
  ( p_set_rec_id in  number,
    x_ret_status out nocopy varchar2,
    x_msg_count  out nocopy number,
    x_msg_data   out nocopy varchar2 )
  is
    l_count number;
  begin
    -- initialize default outputs to error
    x_ret_status := FND_API.G_RET_STS_ERROR;

    -- check params
    if (p_set_rec_id is null) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    -- validate params
    select count(*) into l_count from cs_kb_set_recs
    where set_rec_id = p_set_rec_id;
    if(l_count = 0 ) then
      fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
      fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data );
      return;
    end if;

    -- delete the solution recommendation
    delete from CS_KB_SET_RECS
    where SET_REC_ID = p_set_rec_id;

    -- return success
    x_ret_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;
    return;

  end Delete_Set_Rec;

  -- *************************************
  -- * Private procedure implementations *
  -- *************************************


  -- Swap the recommendation order for 2 recommended solutions
  -- This internal api does not do any validation. Caller must
  -- perform all validations.
  procedure Swap_Recommendation_Order
  ( p_set_rec_id_1 in number,
    p_set_rec_id_2 in number )
  is
    l_order_1 number;
    l_order_2 number;
    l_date  date;
    l_user number;
    l_login number;
   begin
    -- Store the order number for both solution recommendation records
    select set_order into l_order_1
    from cs_kb_set_recs
    where set_rec_id = p_set_rec_id_1;

    select set_order into l_order_2
    from cs_kb_set_recs
    where set_rec_id = p_set_rec_id_2;

    -- Initialize some who column data
    l_date := sysdate;
    l_user := fnd_global.user_id;
    l_login := fnd_global.login_id;

    -- We swap the order number of the solution recommendations.
    update cs_kb_set_recs
    set set_order = -100,
        last_update_date = l_date,
        last_updated_by = l_user,
        last_update_login = l_login
    where set_rec_id = p_set_rec_id_2;

    update cs_kb_set_recs
    set set_order = l_order_2,
        last_update_date = l_date,
        last_updated_by = l_user,
        last_update_login = l_login
    where set_rec_id = p_set_rec_id_1;

    update cs_kb_set_recs
    set set_order = l_order_1,
        last_update_date = l_date,
        last_updated_by = l_user,
        last_update_login = l_login
    where set_rec_id = p_set_rec_id_2;
  end;

end CS_KB_SET_RECS_PKG;

/
