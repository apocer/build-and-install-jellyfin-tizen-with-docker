import secretstorage
bus = secretstorage.dbus_init()
collection = secretstorage.get_default_collection(bus)
for item in collection.get_all_items():
    print(item.get_label())
    print(item.get_attributes())