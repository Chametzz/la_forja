abstract class BaseRepository<E, ID> {
  Future<void> create(E entity);
  Future<E?> getById(ID id);
  Future<List<E>> getAll();
  Future<void> update(E entity);
  Future<void> delete(ID id);
}
