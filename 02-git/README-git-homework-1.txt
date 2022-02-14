# devops-netology homework 2021-11-08
#инструменты git.
Для выполнения заданий в этом разделе давайте склонируем репозиторий с исходным кодом терраформа https://github.com/hashicorp/terraform

В виде результата напишите текстом ответы на вопросы и каким образом эти ответы были получены.

-    Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

git show aefea
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
    Update CHANGELOG.md

-    Какому тегу соответствует коммит 85024d3?
git show 85024d3
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
tag: v0.12.23

-    Сколько родителей у коммита b8d720? Напишите их хеши.
git show b8d720
Merge: 56cd7859e 9ea88f22f
2 родителя
git show 56cd7859e 9ea88f22f
commit 56cd7859e05c36c06b56d013b55a252d0bb7e158
commit 9ea88f22fc6269854151c571162c5bcf958bee2b


-    Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

git log --oneline v0.12.23..v0.12.24
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release

-    Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).

git grep 'func providerSource'
provider_source.go:func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {

git log -L :providerSource:provider_source.go
................
commit 8c928e83589d90a031f811fae52a81be7153e82f
................
diff --git a/provider_source.go b/provider_source.go
--- /dev/null
+++ b/provider_source.go
@@ -0,0 +19,5 @@
+func providerSource(services *disco.Disco) getproviders.Source {
+       // We're not yet using the CLI config here because we've not implemented
+       // yet the new configuration constructs to customize provider search
+       // locations. That'll come later.
+       // For now, we have a fixed set of search directories:

-    Найдите все коммиты в которых была изменена функция globalPluginDirs.
git grep 'globalPluginDirs'
commands.go:            GlobalPluginDirs: globalPluginDirs(),
commands.go:    helperPlugins := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
internal/command/cliconfig/config_unix.go:              // FIXME: homeDir gets called from globalPluginDirs during init, before
plugins.go:// globalPluginDirs returns directories that should be searched for
plugins.go:func globalPluginDirs() []string {


git log -L :globalPluginDirs:plugins.go
git log -L :globalPluginDirs:plugins.go -s --oneline
78b122055 Remove config.go and update things using its aliases
52dbf9483 keep .terraform.d/plugins for discovery
41ab0aef7 Add missing OS_ARCH dir to global plugin paths
66ebff90c move some more plugin search path logic to command
8364383c3 Push plugin discovery down into command package

-    Кто автор функции synchronizedWriters?
Martin Atkins

git log -SsynchronizedWriters
ищем первый коммит 5ac311e2a91e381e2f52234668b49ba670aa0fe5 , создание файла synchronized_writers.go
git checkout 5ac311e2a91e381e2f52234668b49ba670aa0fe5
git blame -C -L 15,25 synchronized_writers.go
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 15) func synchronizedWriters(targets ...io.Writer) []io.Writer {
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 16)         mutex := &sync.Mutex{}
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 17)         ret := make([]io.Writer, len(targets))
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 18)         for i, target := range targets {
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 19)                 ret[i] = &synchronizedWriter{
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 20)                         Writer: target,
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 21)                         mutex:  mutex,
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 22)                 }
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 23)         }
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 24)         return ret
5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 25) }


