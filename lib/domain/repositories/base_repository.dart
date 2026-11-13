abstract class BaseRepository<E, ID> {
  Future<E> create(E entity);
  Future<E?> getById(ID id);
  Future<List<E>> getAll({int? limit, int? offset, String? orderBy});
  Future<void> update(E entity);
  Future<void> delete(ID id);
}
