--------------------------------------------------------
--  DDL for Package Body PON_VENDOR_PURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_VENDOR_PURGE_GRP" as
-- $Header: PONVDPGB.pls 120.0 2005/06/01 15:11:05 appldev noship $


-- returns 'Y' if the vendor can be purged
-- returns 'N' if the vendor should not be purged
function validate_vendor_purge (
  p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_vendor_id 	  IN	     NUMBER)
RETURN VARCHAR2 IS

l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(50) := 'validate_po_purge';
l_vendor_tp_id  NUMBER;
l_vendor_refs	NUMBER;

BEGIN
  -- initialize return for unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  select count(*)
  into l_vendor_refs
  from pon_bid_headers
  where vendor_id = p_vendor_id;

  if (l_vendor_refs > 0) then
    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
                     'pon.vendor_purge',
                     'validation failed in pon_bid_headers');
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    return 'N';
  end if;

  -- don't bother to check in pon_bid_item_prices
  -- since you must have a header to have an item

  -- also ignore vendor references in pon_acknowledgements
  -- the caller knows that he may be eliminating a supplier who intends
  -- to participate in a sourcing event

  l_vendor_tp_id := POS_VENDOR_UTIL_PKG.get_party_id_for_vendor(p_vendor_id);

  select count(*)
  into l_vendor_refs
  from pon_bidding_parties
  where trading_partner_id = l_vendor_tp_id;

  x_return_status := fnd_api.g_ret_sts_success;

  if (l_vendor_refs > 0) then
    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
                     'pon.vendor_purge',
                     'validation failed in pon_bidding_parties');
    end if;

    return 'N';
  else
    return 'Y';
  end if;

END validate_vendor_purge;


-- this is a placeholder for future code.
-- this is not even called by AP
procedure vendor_purge (
  p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_vendor_id 	IN	     NUMBER) IS

l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(50) := 'validate_po_purge';
l_vendor_tp_id  NUMBER;
l_vendor_refs	NUMBER;

BEGIN
  -- initialize return for unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  -- since we never validate a vendor purge with a reference in sourcing,
  -- there is nothing to do here

  x_return_status := fnd_api.g_ret_sts_success;

  if (p_commit = fnd_api.g_true) then
    commit;
  end if;

end vendor_purge;

end PON_VENDOR_PURGE_GRP;

/
