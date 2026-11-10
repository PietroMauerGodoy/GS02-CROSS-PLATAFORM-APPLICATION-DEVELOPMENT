import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/indicador.dart';

enum TipoGrafico { linha, barras }

/// Gráfico reutilizável de uma série temporal (linha ou barras).
/// A série deve estar ordenada por data e não pode ser vazia.
class SerieChart extends StatelessWidget {
  final List<Indicador> serie;
  final TipoGrafico tipo;
  final Color cor;
  final String unidade;
  final double? referencia;
  final String? rotuloReferencia;
  final String descricao;
  final double altura;

  const SerieChart({
    super.key,
    required this.serie,
    required this.tipo,
    required this.cor,
    required this.unidade,
    required this.descricao,
    this.referencia,
    this.rotuloReferencia,
    this.altura = 220,
  });

  String _dm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _fmt(double v) => v.toStringAsFixed(v.abs() >= 100 ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final estiloEixo =
        Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11);

    final valores = serie.map((e) => e.valor).toList();
    var minV = valores.reduce(min);
    var maxV = valores.reduce(max);
    if (referencia != null) {
      minV = min(minV, referencia!);
      maxV = max(maxV, referencia!);
    }
    final folga = (maxV - minV) == 0 ? 1.0 : (maxV - minV) * 0.15;
    final minY = tipo == TipoGrafico.barras ? 0.0 : minV - folga;
    final maxY = maxV + folga;

    final n = serie.length;
    final passo = max(1, (n / 5).ceil()).toDouble();
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);

    final titulos = FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (v, meta) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(meta.formattedValue,
                style: estiloEixo, textAlign: TextAlign.right),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: passo,
          getTitlesWidget: (v, meta) {
            if (v != v.roundToDouble()) return const SizedBox.shrink();
            final i = v.toInt();
            if (i < 0 || i >= n) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_dm(serie[i].timestamp), style: estiloEixo),
            );
          },
        ),
      ),
    );

    final grade = FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) =>
          FlLine(color: esquema.outlineVariant, strokeWidth: 1),
    );

    final linhaRef = referencia == null
        ? ExtraLinesData()
        : ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: referencia!,
              color: esquema.tertiary,
              strokeWidth: 2,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: rotuloReferencia != null,
                alignment: Alignment.topRight,
                style: TextStyle(
                  color: esquema.tertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                labelResolver: (_) => rotuloReferencia ?? '',
              ),
            ),
          ]);

    const estiloTooltip =
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    final Widget grafico;
    if (tipo == TipoGrafico.linha) {
      grafico = LineChart(LineChartData(
        minX: 0,
        maxX: max(1, n - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: grade,
        borderData: FlBorderData(show: false),
        titlesData: titulos,
        extraLinesData: linhaRef,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${_dm(serie[s.x.toInt()].timestamp)}\n${_fmt(s.y)} $unidade',
                  estiloTooltip,
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].valor),
            ],
            color: cor,
            barWidth: 3,
            isCurved: false,
            dotData: FlDotData(show: n <= 15),
            belowBarData:
                BarAreaData(show: true, color: cor.withValues(alpha: 0.12)),
          ),
        ],
      ));
    } else {
      grafico = BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: 0,
        maxY: maxY,
        gridData: grade,
        borderData: FlBorderData(show: false),
        titlesData: titulos,
        extraLinesData: linhaRef,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${_dm(serie[group.x].timestamp)}\n${_fmt(rod.toY)} $unidade',
              estiloTooltip,
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < n; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: serie[i].valor,
                  width: n <= 17 ? 12 : 6,
                  borderRadius: BorderRadius.circular(3),
                  // dias futuros (previsão) ficam mais claros
                  color: serie[i].timestamp.isAfter(inicioHoje)
                      ? cor.withValues(alpha: 0.45)
                      : cor,
                ),
              ],
            ),
        ],
      ));
    }

    return Semantics(
      label: descricao,
      child: ExcludeSemantics(
        child: SizedBox(height: altura, child: grafico),
      ),
    );
  }
}